//
//  RoleplayViewModelTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 16/07/26.
//

import Testing

@testable import Cangkruk

@MainActor
struct RoleplayViewModelTests {
    
    @Test("running generate chat from handleBaristaSpeech")
    func handleBaristaSpeech() async {
        let networkManager = FakeNetworkManager()
        let llmService = APILLMService(networkManager: networkManager)
        
        let vm = RolePlayViewModel(
            scenario: RolePlayScenario(
                name: "Pelanggan Ramah",
                persona: "Pelanggan santai dan ramah yang baru pertama kali datang. Kamu penasaran dengan menu dan suka bertanya rekomendasi.",
                difficulty: 1
            ),
            llm: llmService,
        )
        
        await vm.startSession()
        
        #expect(vm.isSessionOver == false)
        #expect(vm.isThinking == false)
        
        await vm.handleBaristaSpeech("Hello world")
        
        #expect(vm.messages.count == 2)
        #expect(networkManager.isPostCalled == 1)
    }
    
    
    @Test("running generate feedback from finishSession")
    func finishSession() async {
        let networkManager = FakeNetworkManager()
        let llmService = APILLMService(networkManager: networkManager)
        
        let vm = RolePlayViewModel(
            scenario: RolePlayScenario(
                name: "Pelanggan Ramah",
                persona: "Pelanggan santai dan ramah yang baru pertama kali datang. Kamu penasaran dengan menu dan suka bertanya rekomendasi.",
                difficulty: 1
            ),
            llm: llmService,
        )
        
        await vm.startSession()
        
        #expect(vm.isSessionOver == false)
        #expect(vm.isThinking == false)
        
        await vm.handleBaristaSpeech("Hello world")
        
        #expect(vm.messages.count == 2)
        #expect(networkManager.isPostCalled == 1)
        
        await vm.finishSession()
        #expect(vm.isSessionOver == true)
        #expect(networkManager.isPostCalled == 2)
    }
}
