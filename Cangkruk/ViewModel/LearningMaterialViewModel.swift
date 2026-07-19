//
//  LearningMaterialViewModel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 18/07/26.
//

import SwiftUI
import SwiftData

@Observable
class LearningMaterialViewModel {
    var llmService: ILLMService?
    var learningMaterial: String?
    var isLoading: Bool = false
    var errorMessage: String?
    var isError = false
    
    init(
        llmService: ILLMService? = APILLMService(
            networkManager: NetworkManager(host: "https://cangkruk.gagas.tech")
        )
    ) {
        self.llmService = llmService
        
        Task {
            do {
                try await self.llmService?.startsession(systemPrompt: "")
            } catch {
                isError = true
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // getTrainingMaterials will get teh materials that been save in the swiftdata
    private func getTrainingMaterials(context: ModelContext) throws -> [String] {
        isLoading = true
        defer { isLoading = false }
        
        let fetchDescriptor = FetchDescriptor<TrainingFile>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let learnMaterials = try context.fetch(fetchDescriptor)
        return learnMaterials.map { $0.extractedText ?? "" }
    }
    
    // extractingText will generate the initial prompt + the training material
    // preparation of the prompt
    func extractingText(context: ModelContext) throws -> String {
        let trainingMaterials = try getTrainingMaterials(context: context)
        let results = trainingMaterials.joined(separator: " ")
        
        let res = PromptEngine.createPrompt(for: results)
        return res
    }
    
    // startGenerateMaterials will generate the learning material
    // will call using llmService
    func startGenerateMaterials(materials: String) async throws -> [LevelMaterialResponse]? {
        isError = false
        guard let llmService else { return nil }
        do {
            let res = try await llmService.generateLevelMaterials(systemPrompt: materials)
            return res
        } catch {
            errorMessage = error.localizedDescription
            isError = true
            return nil
        }
    }
    
    // saveMaterials will be executed by manager when uploading the file & simpan
    // it will insert the llmService response and save into swiftdata storage
    func saveMaterials(context: ModelContext, materials: [LevelMaterialResponse]?) throws {
        isError = false
        guard let materials else { return }
        
        do {
            try context.delete(model: LevelMaterial.self)
            
            for material in materials {
                let material = LevelMaterial(level: material.level, title: material.title, body: material.body)
                context.insert(material)
            }
            
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
            isError = true
            return
        }
    }
}
