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
    @State private var showManagerView = false
    @Query private var allFiles: [TrainingFile]
    
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
        
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                
                if router.isManagerUnlocked {
                    HStack {
                        Image("tantanganTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 12)
                        
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
                            .padding(.top, 10)
                            .padding(.leading, 8)
                            .onTapGesture {
                                showManagerView = true
                            }
                        
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Color("lightBackground"))
                            .offset(x: 2, y: 1)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color("Primary"))
                            )
                            .padding(.top, 10)
                            .padding(.leading, 8)
                            .onTapGesture {
                                router.isManagerUnlocked = false
                            }
                    }
                    .padding(10)
                } else {
                    HStack {
                        Image("tantanganTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 50)
                            .padding(.vertical, 12)
                        
                        Spacer()
                        
                        // --- HASIL MERGE LOGIKA TEMANMU MASUK DI SINI ---
                        if authVM.isLoading {
                            ProgressView()
                                .padding(.top, 10)
                        } else {
                            Image(systemName: "lock.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .foregroundStyle(Color("Primary"))
                                .padding(.top, 10)
                                .onTapGesture {
                                    // Logika routing dari temanmu (Bukan sekadar push .register lagi)
                                    router.push(user == nil ? .register : .login)
                                }
                        }
                        // ------------------------------------------------
                    }
                    .padding(10)
                }
                
                VStack(spacing: 10) {
                    ForEach(levelInfo.indices, id: \.self) { idx in
                        let level = levelInfo[idx]
                        
                        AppLevel(
                            level: level.level,
                            description: level.description,
                            isLock: level.isLock,
                            isManager: router.isManagerUnlocked
                        ) {
                            levelInfo[idx].isLock.toggle()
                        } onClick: {
                            router.push(.level)
                        }
                    }
                }
                .padding(.top, 10)
                
                HStack(alignment: .center, spacing: -20) {
                    Image("luwak 1")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(x: -1, y: 1)
                    
                    Image("luwak 1")
                        .resizable()
                        .scaledToFit()
                        .offset(y: 20)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)
            
        }
        .sheet(isPresented: $showManagerView) {
            ManagerView()
                .environment(router)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            self.user = authVM.getLastUser(context: modelContext)
            self.isSOPOpen = router.isManagerUnlocked
        }
        // .sheet(isPresented: $isSOPOpen) {
        .sheet(isPresented: $showManagerView) {
            ManagerView()
                .environment(router)
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            if router.isManagerUnlocked && allFiles.isEmpty {
                showManagerView = true
            }
        }
    }
}

#Preview {
    HomeScreen()
        .environment(RouterViewModel())
}
