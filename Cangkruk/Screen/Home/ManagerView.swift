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
    @Environment(RouterViewModel.self) private var router
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
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    @State private var importTarget: TrainingFileSection?
    @State private var isImporterPresented = false
    @State private var showUnsupportedFileAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Unggah SOP & Menu")
                    .font(.title2)
                    .bold()

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            List {
                fileSection(title: "SOP", target: .sop, files: sopFiles)
                fileSection(title: "Resep", target: .resep, files: resepFiles)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                router.popToRoot()
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
            VStack(spacing: -193) {
                AppLottie(animation: "CangkrukLay")
                    .frame(height: 500)
                    .frame(maxWidth: .infinity, alignment: .center)

                AppImageButton(imageName: "simpanButton") {
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity)
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
    private func fileSection(
        title: String,
        target: TrainingFileSection,
        files: [TrainingFile]
    ) -> some View {
        Section {
            UploadFieldView(fileName: files.first?.name) {
                importTarget = target
                isImporterPresented = true
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))

            ForEach(files) { file in
                FileRowView(fileName: file.name, date: Self.dateFormatter.string(from: file.date))
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            delete(file)
                        } label: {
                            Label("Hapus", systemImage: "trash")
                        }
                    }
            }
        } header: {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        }
        .listRowBackground(Color.clear)
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
        .environment(RouterViewModel())
        .modelContainer(for: TrainingFile.self, inMemory: true)
}
