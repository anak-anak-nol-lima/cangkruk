//
//  TextToSpeechViewModelTests.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 12/07/26.
//

import Testing

@testable import Cangkruk


@MainActor
struct TextToSpeechViewModelTests {
    @Test("speak is called correctly")
    func speak() async {
        let fakeTextToSpeech = FakeTextToSpeech()
        let vm = TextToSpeechViewModel(textToSpeech: fakeTextToSpeech)
        
        await vm.speak("hello world")
        
        #expect(fakeTextToSpeech.speakCalled == 1)
        #expect(vm.errorMessage == "")
    }
    
    
    @Test("speakError is returning error")
    func speakError() async {
        let fakeTextToSpeech = FakeTextToSpeech()
        let vm = TextToSpeechViewModel(textToSpeech: fakeTextToSpeech)
        
        fakeTextToSpeech.speakError = FakeError("error when calling")
        await vm.speak("error woi")
        
        #expect(fakeTextToSpeech.speakCalled == 1)
        #expect(vm.errorMessage?.isEmpty == false)
    }
}
