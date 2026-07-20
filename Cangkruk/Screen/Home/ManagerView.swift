//
//  ManagerView.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 09/07/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ManagerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(RouterViewModel.self) private var router
    @State private var showCancelAlert = false
    
    // MARK: - ViewModel
    @Environment(LearningMaterialViewModel.self) private var learningMaterialVM

    
    @Query(
        filter: #Predicate<TrainingFile> { $0.section == "sop" },
        sort: \TrainingFile.date,
        order: .reverse
    )
    private var sopFiles: [TrainingFile]
    
    @Query(
        filter: #Predicate<TrainingFile> { $0.section == "resep" },
        sort: \TrainingFile.date,
        order: .reverse
    )
    private var resepFiles: [TrainingFile]
    
    private static let allowedExtensions: Set<String> = ["pdf", "doc", "docx"]
    private static let allowedContentTypes: [UTType] = [
        .pdf,
        UTType(filenameExtension: "doc") ?? .data,
        UTType(filenameExtension: "docx") ?? .data
    ]
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter
    }()
    
    @State private var importTarget: TrainingFileSection?
    @State private var isImporterPresented = false
    @State private var showUnsupportedFileAlert = false
    
    // Variabel ekstraksi teks (Dari HEAD)
    @State private var isExtractingText = false
    
    // Variabel antrean aksi (Dari branch kamu)
    @State private var filesToAdd: [TrainingFile] = []
    @State private var filesToDelete: [TrainingFile] = []

    // Variabel tampilan UI
    @State private var localSopFiles: [TrainingFile] = []
    @State private var localResepFiles: [TrainingFile] = []

    // Variabel alert hapus file
    @State private var showDeleteAlert = false
    @State private var fileToConfirmDelete: TrainingFile? = nil
    
    // Loading
    @State private var isLoading: Bool = false
    
    
    // MARK: - Internal function
    private func saveAndDismiss() async {
        isLoading = true
        
        do {
            for file in filesToAdd {
                modelContext.insert(file)
            }
            
            for file in filesToDelete {
                FileStorageManager.delete(storedFileName: file.storedFileName)
                modelContext.delete(file)
            }
            
            filesToAdd.removeAll()
            filesToDelete.removeAll()
            
            // call the model to generate prompt
            let materials = try learningMaterialVM.extractingText(context: modelContext)
            let res = try await learningMaterialVM.startGenerateMaterials(materials: materials)
            try learningMaterialVM.saveMaterials(context: modelContext, materials: res)
            
            isLoading = false
            dismiss()
        } catch {
            isLoading = false
            print("saveAndDismiss Error: \(error)")
        }
    }
    
    var body: some View {
        @Bindable var learningMaterialVM = learningMaterialVM
        ZStack {
            ZStack(alignment: .top) {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("UNGGAH FILE")
                            .font(.shakyComicBold(size: 43))
//                            .bold()
                            .foregroundStyle(Color("Secondary"))
                        
                        Spacer()
                        
                        Button {
                            if filesToAdd.isEmpty && filesToDelete.isEmpty {
                                dismiss()
                            } else {
                                showCancelAlert = true
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .foregroundStyle(Color("Secondary"))
                                .padding(.bottom, 10)
                        }
                    }
                    
                    // SOP
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("SOP")
                                .font(.shakyComicBold(size: 30))
                                .bold()
                                .foregroundStyle(Color("Secondary"))
                            
                            Spacer()
                            
                            Button {
                                importTarget = .sop
                                isImporterPresented = true
                            } label: {
                                Image(systemName: "square.and.arrow.up.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundStyle(Color("Primary"))
                                    .padding(.bottom, 10)
                                    .accessibilityLabel(Text("Unggah File SOP"))
                            }
                        }
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(localSopFiles) { file in
                                    fileCard(file: file)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    .background(Color("lightBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    // Pengetahuan Menu
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("PENGETAHUAN MENU")
                                .font(.shakyComicBold(size: 30))
                                .bold()
                                .foregroundStyle(Color("Secondary"))
                            
                            Spacer()
                            
                            Button {
                                importTarget = .resep
                                isImporterPresented = true
                            } label: {
                                Image(systemName: "square.and.arrow.up.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundStyle(Color("Primary"))
                                    .padding(.bottom, 10)
                                    .accessibilityLabel(Text("Unggah File Menu"))
                            }
                        }
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(localResepFiles) { file in
                                    fileCard(file: file)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    .background(Color("lightBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                }
                .padding(20)
                .padding(.top, 10)
            }
            .overlay(alignment: .bottom) {
                // Floating Lottie + Simpan button
                VStack(spacing: -20) {
                    AppLottie(animation: "CangkrukLay")
                        .frame(height: 190)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .allowsHitTesting(false)
                    AppButton(label: "SIMPAN", isLoading: isLoading) {
                        Task {
                            await saveAndDismiss()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(maxWidth: .infinity)
                .screenPadding()
                .padding(.bottom, 15)
            }
            
            // Lapis 2: Alert Batal
            AppAlert(
                isPresented: $showCancelAlert,
                message: "APAKAH ANDA YAKIN INGIN MEMBATALKAN PERUBAHAN?",
                primaryButtonTitle: "BUANG"
            ) {
                for file in filesToAdd {
                    FileStorageManager.delete(storedFileName: file.storedFileName)
                }
                dismiss()
            }
            
            // Lapis 2: Alert Hapus File
            AppAlert(
                isPresented: $showDeleteAlert,
                message: "APAKAH ANDA YAKIN INGIN MENGHAPUS FILE INI?",
                primaryButtonTitle: "HAPUS"
            ) {
                if let file = fileToConfirmDelete {
                    delete(file)
                }
                fileToConfirmDelete = nil
            }
        } // MARK: Akhir Master ZStack
        
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: Self.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            // Pemanggilan Task dari HEAD untuk support async
            Task {
                await handleImportResult(result)
            }
        }
        .alert("File tidak didukung", isPresented: $showUnsupportedFileAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Hanya mendukung file PDF dan Docs.")
        }
        // Overlay loading dari HEAD
        .overlay {
            if isExtractingText {
                ZStack {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    ProgressView("Memproses file...")
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .overlay(alignment: .bottom) {
            if learningMaterialVM.isError {
                AppSnackbar(errorMessage: learningMaterialVM.errorMessage ?? "", type: .error, isPresented: $learningMaterialVM.isError)
            }
        }
        // Inisialisasi onAppear dari branch kamu
        .onAppear {
            localSopFiles = sopFiles
            localResepFiles = resepFiles
        }
        .interactiveDismissDisabled(!filesToAdd.isEmpty || !filesToDelete.isEmpty)
    }
    
    // UI fileCard milikmu
    @ViewBuilder
    private func fileCard(file: TrainingFile) -> some View {
        HStack(spacing: 8) {
            Text(file.name)
                .font(.subheadline)
                .foregroundStyle(Color("Secondary"))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer(minLength: 10)
            
            Text(Self.dateFormatter.string(from: file.date))
                .font(.subheadline)
                .foregroundStyle(Color("Secondary"))
            
            Button {
                fileToConfirmDelete = file
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color("lightBackground"))
                    .frame(width: 32, height: 32)
                    .background(Color("Primary"))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color("lightBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color("Secondary"), lineWidth: 1.5)
        )
        .padding(.horizontal, 2)
    }
    
    // Logika handle import gabungan (async + queue)
    private func handleImportResult(_ result: Result<[URL], Error>) async {
        guard let target = importTarget else { return }
        
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            guard Self.allowedExtensions.contains(url.pathExtension.lowercased()) else {
                showUnsupportedFileAlert = true
                return
            }
            
            guard url.startAccessingSecurityScopedResource() else {
                showUnsupportedFileAlert = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let storedFileName = try FileStorageManager.save(from: url)
                
                // Menjalankan ekstraksi teks (HEAD)
                isExtractingText = true
                let extractedText = await TextExtractionService.extractText(from: url)
                isExtractingText = false
                
                // Membuat TrainingFile dengan parameter extractedText
                let file = TrainingFile(
                    name: url.lastPathComponent,
                    section: target,
                    storedFileName: storedFileName,
                    extractedText: extractedText
                )
                
                // Memasukkan ke sistem antrean milikmu
                filesToAdd.append(file)
                
                if target == .sop {
                    localSopFiles.insert(file, at: 0)
                } else {
                    localResepFiles.insert(file, at: 0)
                }
                
            } catch {
                isExtractingText = false
                showUnsupportedFileAlert = true
            }
            
        case .failure:
            showUnsupportedFileAlert = true
        }
    }
    
    private func delete(_ file: TrainingFile) {
        filesToDelete.append(file)
        
        if file.section == "sop" {
            localSopFiles.removeAll { $0.id == file.id }
        } else {
            localResepFiles.removeAll { $0.id == file.id }
        }
    }
}

#Preview {
    ManagerView()
        .modelContainer(for: TrainingFile.self, inMemory: true)
        .environment(RouterViewModel())
}
