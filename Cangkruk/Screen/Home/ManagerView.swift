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
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()

    @State private var importTarget: TrainingFileSection?
    @State private var isImporterPresented = false
    @State private var showUnsupportedFileAlert = false

    var body: some View {
        ZStack(alignment: .top) {
            Color("Background")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Image("uploadFileTitle")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 30)
                        .padding(.top, 12)

                    sectionCard(titleAsset: "sopSectionTitle", target: .sop, files: sopFiles)
                    sectionCard(titleAsset: "menuSectionTitle", target: .resep, files: resepFiles)
                }
                .padding(20)
                .padding(.bottom, 220)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.primary)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
            .padding(20)
        }
        .overlay(alignment: .bottom) {
            // Floating Lottie + Simpan button — stays pinned to the bottom regardless of scroll content
            VStack(spacing: -193) {
                AppLottie(animation: "CangkrukLay")
                    .frame(height: 500)
                    .frame(maxWidth: .infinity, alignment: .center)

                AppImageButton(imageName: "simpanButton") {
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
            // TODO: adjust horizontal/bottom position of the floating button here
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: Self.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .alert("File tidak didukung", isPresented: $showUnsupportedFileAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Hanya mendukung file PDF dan Docs.")
        }
    }

    @ViewBuilder
    private func sectionCard(
        titleAsset: String,
        target: TrainingFileSection,
        files: [TrainingFile]
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            UploadFieldView(titleAsset: titleAsset) {
                importTarget = target
                isImporterPresented = true
            }

            List {
                ForEach(files) { file in
                    FileRowView(fileName: file.name, date: Self.dateFormatter.string(from: file.date))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(file)
                            } label: {
                                Label("Hapus", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollDisabled(true)
            .frame(height: CGFloat(files.count) * 56)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.black, lineWidth: 2)
        )
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
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
                let file = TrainingFile(name: url.lastPathComponent, section: target, storedFileName: storedFileName)
                modelContext.insert(file)
            } catch {
                showUnsupportedFileAlert = true
            }

        case .failure:
            showUnsupportedFileAlert = true
        }
    }

    private func delete(_ file: TrainingFile) {
        FileStorageManager.delete(storedFileName: file.storedFileName)
        modelContext.delete(file)
    }
}

#Preview {
    ManagerView()
        .modelContainer(for: TrainingFile.self, inMemory: true)
}
