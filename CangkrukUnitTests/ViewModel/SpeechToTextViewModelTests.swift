//
//  SpeechToTextViewModelTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing

@testable import Cangkruk

@MainActor
struct SpeechToTextViewModelTests {
    
    @Test("requestPermission to get proper permission", arguments: [
        (mic: true, speech: true, expected: true),
        (mic: true, speech: false, expected: false),
        (mic: false, speech: true, expected: false),
        (mic: false, speech: false, expected: false),
    ])
    func requestPermission(mic: Bool, speech: Bool, expected: Bool) async {
        let audioManager = FakeAudioEngineManager()
        audioManager.permission = mic
        
        let transcriptionManager = FakeTanscriptionManager()
        transcriptionManager.permission = speech
        
        let vm = SpeechToTextViewModel(audioEngineManager: audioManager, transcriptionManager: transcriptionManager)
        let result = await vm.requestPermission()
        
        #expect(result == expected)
    }
    
    
    @Test("processMicStart to assure the startPlaying will run")
    func processMicStart() async {
        let audioManager = FakeAudioEngineManager()
        let transcriptionManager = FakeTanscriptionManager()
        let isPlaying = false // this will be false since it's from "non-play" state
        
        let vm = SpeechToTextViewModel(
            audioEngineManager: audioManager,
            transcriptionManager: transcriptionManager,
            isPlaying: isPlaying
        )
        
        
        await vm.processMic()
        
        #expect(vm.isPlaying == true) // when mic processed, the isPlaying will become true
        
        // check if audioManager triggered
        #expect(audioManager.setupAudioSessionCalled == 1)
        #expect(audioManager.startAudioEngineCalled == 1)
        #expect(audioManager.stopAudioEngineCalled == 0)
        
        // check if transcriptionManager triggered
        #expect(transcriptionManager.startTranscribeCalled == 1)
        #expect(transcriptionManager.stopTranscribeCalled == 0)
        
        
        // check that the text is updated on vm property
        transcriptionManager.fakeOnResult?(.success(("h", false)))
        #expect(vm.currentText == "h")
        
        transcriptionManager.fakeOnResult?(.success(("hello world", true)))
        #expect(vm.result[0] == "hello world")
        #expect(vm.currentText == "")
    }
    
    
    @Test("processMicStop to assure the micStop will be triggered")
    func processMicStop() async {
        let audioManager = FakeAudioEngineManager()
        let transcriptionManager = FakeTanscriptionManager()
        let isPlaying = true // since the isPlaying status will be true "on-condition"
        
        let vm = SpeechToTextViewModel(
            audioEngineManager: audioManager,
            transcriptionManager: transcriptionManager,
            isPlaying: isPlaying
        )
        
        await vm.processMic()
        
        
        #expect(vm.isPlaying == false) // isPlaying will triggered to false when this is run
        
        // check if audioManager triggered
        #expect(audioManager.stopAudioEngineCalled == 1)
        #expect(audioManager.startAudioEngineCalled == 0)
        
        // check if transcriptionManager triggered
        #expect(transcriptionManager.stopTranscribeCalled == 1)
        #expect(transcriptionManager.startTranscribeCalled == 0)
    }
}
