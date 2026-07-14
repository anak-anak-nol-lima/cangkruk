//
//  AppLevel.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 09/07/26.
//

import SwiftUI

struct AppLevel: View {
    var level: Int
    var description: String
    var isLock: Bool
    var isManager: Bool
    var toggleLock: () -> Void
    var onClick: () -> Void
        
    var body: some View {
        if isManager {
            if isLock {
                levelLockedManager
            } else {
                levelOpenedManager
            }
        } else {
            if isLock {
                levelLocked
            } else {
                levelOpened
            }
        }
    }
    
    @ViewBuilder
    private var levelOpened: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("LEVEL \(level)")
                    .font(.shakyComicBold(size: 25))
                    .foregroundStyle(Color("Secondary"))
                    .padding(.bottom, 2)
                
                Text(description)
                    .foregroundStyle(Color("Secondary"))
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(5)
            .padding(.trailing, 70)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("lightBackground"))
        .overlay(alignment: .trailing) {
            Image("startButtonOrange")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .offset(x: 25)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 5)
        .onTapGesture {
            onClick()
        }
    }
    
    @ViewBuilder
    private var levelOpenedManager: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("LEVEL \(level)")
                    .font(.shakyComicBold(size: 25))
                    .foregroundStyle(Color("Secondary"))
                    .padding(.bottom, 2)
                
                Text(description)
                    .foregroundStyle(Color("Secondary"))
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(5)
            .padding(.trailing, 70)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("lightBackground"))
        .overlay(alignment: .trailing) {
            Image("startButtonOrange")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .offset(x: 25)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 5)
        .onTapGesture {
            toggleLock()
        }
    }
    
    @ViewBuilder
    private var levelLocked: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("LEVEL \(level)")
                    .font(.shakyComicBold(size: 25))
                    .foregroundStyle(Color("Yellow"))
                    .padding(.bottom, 2)
                
                Text(description)
                    .foregroundStyle(Color("Yellow"))
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(5)
            .padding(.trailing, 70)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Secondary"))
        .overlay(alignment: .trailing) {
            Image("startButtonBrown")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .offset(x: 25)
                .opacity(0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 5)
        .opacity(0.5)
    }
    
    @ViewBuilder
    private var levelLockedManager: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("LEVEL \(level)")
                    .font(.shakyComicBold(size: 25))
                    .foregroundStyle(Color("Yellow"))
                    .padding(.bottom, 2)
                
                Text(description)
                    .foregroundStyle(Color("Yellow"))
                    .font(.system(size: 12))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(5)
            .padding(.trailing, 70)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Secondary"))
        .overlay(alignment: .trailing) {
            Image("lockButtonBrown")
                .resizable()
                .scaledToFit()
                .frame(height: 130)
                .offset(x: 25)
                .opacity(0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.bottom, 5)
        .opacity(0.5)
        .onTapGesture {
            toggleLock()
        }
    }
}

#Preview {
    AppLevel(
        level: 4,
        description: "Membangun hubungan baik dengan pelanggan",
        isLock: false,
        isManager: false,
        toggleLock: {},
        onClick: {}
    )
}
