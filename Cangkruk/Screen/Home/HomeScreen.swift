//
//  HomeScreen.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 07/07/26.
//

import SwiftUI
import SwiftData

struct LevelInfo {
    var level: Int
    var description: String
    var isLock: Bool
}

struct HomeScreen: View {
    // MARK: - Storage
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - ViewModel
    @Environment(RouterViewModel.self) private var router
    @Environment(AuthenticationViewModel.self) private var authVM
    
    // MARK: - Storage Query
    @Query private var allFiles: [TrainingFile]
    @Query private var materials: [LevelMaterial]
    @State private var levelInfo: [LevelInfo] = [
        LevelInfo(level: 1, description: "Pengetahuan akan produk", isLock: false),
        LevelInfo(level: 2, description: "Memahami kebutuhan pelanggan", isLock: true),
        LevelInfo(level: 3, description: "Menangani komplain dan situasi sulit", isLock: true),
        LevelInfo(level: 4, description: "Membangun hubungan baik dengan pelanggan", isLock: true)
    ]
    @State private var user: User?
    @State private var isSOPOpen: Bool = false
    
    var body: some View {
        @Bindable var router = router
        
        ZStack(alignment: .top) {
            Color("Background")
                .ignoresSafeArea()
            
            VStack {
                if router.isManagerUnlocked {
                    ZStack {
                        Image("tantanganTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 12)
                            .accessibilityLabel(Text("Halaman Manager"))
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "book.badge.plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color("lightBackground"))
                                .offset(x: -1, y: 2)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color("Primary"))
                                )
                                .onTapGesture {
                                    isSOPOpen = true
                                }
                                .accessibilityLabel(Text("Unggah File SOP dan Menu"))
                        }
                    }
                    .screenPadding() //padding untuk button di top leading
                    .padding(.top, 10)
                } else {
                    ZStack {
                        Image("tantanganTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 12)
                            .accessibilityLabel(Text("Halaman Tantangan Barista"))
                        
                        HStack {
                            Spacer()
                            
                            if authVM.isLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "lock.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 40)
                                    .foregroundStyle(Color("Primary"))
                                    .onTapGesture {
                                        router.push(.login)
                                    }
                                    .accessibilityLabel(Text("Masuk sebagai Manager"))
                            }
                        }
                    }
                    .screenPadding() //padding untuk button di top leading
                    .padding(.top, 10)
                }
                
                VStack(spacing: 12) {
                    if materials.isEmpty{
                        VStack(spacing: 12) {
                                AppLottie(animation: "CangkrukMeditate")
                                    .frame(height: 180)
                                Text("Belum ada materi.\nMinta manajermu upload SOP & menu dulu ya!")
                                    .font(.shakyComicBold(size: 18))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color("Secondary"))
                            }
                            .padding(.top, 40)
                    } else {
                        ForEach(levelInfo.indices, id: \.self) { idx in
                            let level = levelInfo[idx]
                            
                            AppLevel(
                                level: level.level,
                                description: level.description,
                                isLock: level.isLock,
                                isManager: router.isManagerUnlocked
                            ) {
                                levelInfo[idx].isLock.toggle()
                                let unlocked = levelInfo.filter {
                                    !$0.isLock}.map(\.level)
                                UserDefaults.standard.set(unlocked,forKey: "unlockedLevels")
                            } onClick: {
                                router.push(.level(level.level))
                            }
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                if router.isManagerUnlocked {
                    AppButton(
                        label: "Keluar",
                        isLoading: authVM.isLoading,
                        action: {
                            authVM.logout()
                            router.isManagerUnlocked = false
                        }
                    )
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .sheet(isPresented: $isSOPOpen) {
            ManagerView()
        }
        .onAppear {
            let unlocked = UserDefaults.standard.array(forKey: "unlockedLevels") as? [Int] ?? [1]
            for i in levelInfo.indices { levelInfo[i].isLock = !unlocked.contains(levelInfo[i].level) }
            self.user = authVM.getLastUser(context: modelContext)
            self.isSOPOpen = router.isManagerUnlocked && allFiles.isEmpty
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
        .environment(AuthenticationViewModel())
}

// Preview untuk Manager Page
//#Preview {
//    let mockRouter = RouterViewModel()
//    let _ = {
//        mockRouter.isManagerUnlocked = true
//    }()
//    
//    HomeScreen()
//        .environment(mockRouter)
//        .environment(AuthenticationViewModel())
//}
