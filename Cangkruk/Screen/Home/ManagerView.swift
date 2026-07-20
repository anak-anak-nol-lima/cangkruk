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
    @State private var isExtractingText = false
    
    // Variabel antrean aksi (Dari branch kamu)
    @State private var filesToAdd: [TrainingFile] = []
    @State private var filesToDelete: [TrainingFile] = []

    @State private var showDeleteAlert = false
    @State private var fileToConfirmDelete: TrainingFile? = nil

    // Summarize (map-reduce) di layar Manajer
    @State private var isSummarizing = false
    @State private var summarizeStatusMessage = ""
    @State private var summarizeTask: Task<Void, Never>?
    @State private var summarizeErrorMessage: String?

    private var isBusy: Bool {
        isExtractingText || isSummarizing
    }

    /// List SOP dari SwiftData + file pending add, tanpa yang menunggu dihapus.
    private var displayedSopFiles: [TrainingFile] {
        displayedFiles(
            from: sopFiles,
            section: .sop
        )
    }

    /// List Pengetahuan Menu dari SwiftData + file pending add, tanpa yang menunggu dihapus.
    private var displayedResepFiles: [TrainingFile] {
        displayedFiles(
            from: resepFiles,
            section: .resep
        )
    }
    
    var body: some View {
        ZStack {
            ZStack(alignment: .top) {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("UNGGAH FILE")
                            .font(.shakyComicBold(size: 45))
                            .bold()
                            .foregroundStyle(Color("Primary"))
                        
                        Spacer()
                        
                        Button {
                            guard !isBusy else { return }
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
                                .foregroundStyle(Color("Primary"))
                                .padding(.bottom, 10)
                                .opacity(isBusy ? 0.35 : 1)
                        }
                        .disabled(isBusy)
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
                                guard !isBusy else { return }
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
                            .disabled(isBusy)
                        }
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(displayedSopFiles) { file in
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
                                guard !isBusy else { return }
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
                            .disabled(isBusy)
                        }
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(displayedResepFiles) { file in
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
                    AppButton(label: "SIMPAN", isLoading: isBusy) {
                        startSaveAndSummarize()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(isBusy)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
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
        }
        
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: Self.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            Task {
                await handleImportResult(result)
            }
        }
        .alert("File tidak didukung", isPresented: $showUnsupportedFileAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Hanya mendukung file PDF dan DOCX.")
        }
        .alert("Gagal merangkum", isPresented: Binding(
            get: { summarizeErrorMessage != nil },
            set: { if !$0 { summarizeErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { summarizeErrorMessage = nil }
        } message: {
            Text(summarizeErrorMessage ?? "")
        }
        .overlay {
            if isExtractingText {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    ProgressView("Memproses file...")
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } else if isSummarizing {
                summarizeBlockingOverlay
            }
        }
        .interactiveDismissDisabled(isBusy || !filesToAdd.isEmpty || !filesToDelete.isEmpty)
    }

    @ViewBuilder
    private var summarizeBlockingOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .allowsHitTesting(true)

            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                    .tint(Color("Primary"))

                Text("Merangkum materi dengan AI")
                    .font(.headline)
                    .foregroundStyle(Color("Secondary"))
                    .multilineTextAlignment(.center)

                Text(summarizeStatusMessage.isEmpty ? "Menyiapkan dokumen…" : summarizeStatusMessage)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.black.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: summarizeStatusMessage)
                    .frame(maxWidth: .infinity)

                Text("Jangan tutup aplikasi sampai proses selesai.")
                    .font(.caption)
                    .foregroundStyle(.black.opacity(0.5))
                    .multilineTextAlignment(.center)

                Button("Batal") {
                    cancelSummarize()
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("Primary"))
                .padding(.top, 4)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(Color("lightBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 12, y: 4)
        }
    }

    private func displayedFiles(
        from stored: [TrainingFile],
        section: TrainingFileSection
    ) -> [TrainingFile] {
        let pendingDeleteIDs = Set(filesToDelete.map(\.id))
        let pendingAdds = filesToAdd.filter { $0.section == section.rawValue }
        let existing = stored.filter { !pendingDeleteIDs.contains($0.id) }
        return pendingAdds + existing
    }
    
    @ViewBuilder
    private func fileCard(file: TrainingFile) -> some View {
        HStack(spacing: 8) {
            Text(file.name)
                .font(.system(size: 12))
                .foregroundStyle(Color("Secondary"))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer(minLength: 10)
            
            Text(Self.dateFormatter.string(from: file.date))
                .font(.caption)
                .foregroundStyle(Color("Secondary"))
            
            Button {
                guard !isBusy else { return }
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
            .disabled(isBusy)
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

    private func startSaveAndSummarize() {
        guard !isBusy else { return }

        let pendingAdds = filesToAdd
        let pendingDeletes = filesToDelete

        // Hanya hapus / tidak ada file baru → simpan cepat tanpa AI.
        if pendingAdds.isEmpty {
            applyDeletes(pendingDeletes)
            filesToDelete.removeAll()
            dismiss()
            return
        }

        summarizeTask?.cancel()
        isSummarizing = true
        summarizeStatusMessage = SummarizeProgress.preparing.message

        summarizeTask = Task { @MainActor in
            defer {
                isSummarizing = false
                summarizeStatusMessage = ""
                summarizeTask = nil
            }

            do {
                applyDeletes(pendingDeletes)
                filesToDelete.removeAll()

                let manager = TrainingMaterialManager(modelContext: modelContext)
                let total = pendingAdds.count

                for (index, file) in pendingAdds.enumerated() {
                    try Task.checkCancellation()

                    modelContext.insert(file)
                    try modelContext.save()

                    let rawText = file.extractedText?
                        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard !rawText.isEmpty else { continue }

                    let fileLabel = "File \(index + 1) dari \(total)"
                    summarizeStatusMessage = "\(fileLabel): \(SummarizeProgress.preparing.message)"

                    _ = try await manager.summarize(rawText: rawText, into: file) { progress in
                        Task { @MainActor in
                            summarizeStatusMessage = "\(fileLabel): \(progress.message)"
                        }
                    }
                }

                filesToAdd.removeAll()
                dismiss()
            } catch is CancellationError {
                // Dibatalkan manajer — file yang sudah tersimpan tetap ada.
            } catch let error as LLMError {
                if case .cancelled = error { return }
                summarizeErrorMessage = error.localizedDescription
            } catch {
                if !Task.isCancelled {
                    summarizeErrorMessage = error.localizedDescription
                }
            }
        }
    }

    private func cancelSummarize() {
        summarizeTask?.cancel()
        summarizeTask = nil
        isSummarizing = false
        summarizeStatusMessage = ""
    }

    private func applyDeletes(_ files: [TrainingFile]) {
        for file in files {
            FileStorageManager.delete(storedFileName: file.storedFileName)
            modelContext.delete(file)
        }
        try? modelContext.save()
    }
    
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
                
                isExtractingText = true
                let extractedText = await TextExtractionService.extractText(from: url)
                isExtractingText = false
                
                let file = TrainingFile(
                    name: url.lastPathComponent,
                    section: target,
                    storedFileName: storedFileName,
                    extractedText: extractedText
                )
                
                filesToAdd.append(file)
                
            } catch {
                isExtractingText = false
                showUnsupportedFileAlert = true
            }
            
        case .failure:
            showUnsupportedFileAlert = true
        }
    }
    
    private func delete(_ file: TrainingFile) {
        if let pendingIndex = filesToAdd.firstIndex(where: { $0.id == file.id }) {
            let pending = filesToAdd.remove(at: pendingIndex)
            FileStorageManager.delete(storedFileName: pending.storedFileName)
            return
        }
        
        if !filesToDelete.contains(where: { $0.id == file.id }) {
            filesToDelete.append(file)
        }
    }
}

#Preview {
    ManagerView()
        .modelContainer(for: TrainingFile.self, inMemory: true)
        .environment(RouterViewModel())
}
