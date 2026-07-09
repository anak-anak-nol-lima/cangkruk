//
//  CangkrukApp.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI
import SwiftData

@main
struct CangkrukApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
        .modelContainer(for: TrainingFile.self) // to enable modelContext to be accessed by all view
    }
}
