//
//  AppSnackbar.swift
//  Cangkruk
//
//  Created by Bee Wijaya on 10/07/26.
//

import SwiftUI

enum SnackbarType {
    case error
    case success
    
    var background: Color {
        switch self {
        case .error:
            return .red
        case .success:
            return .green
        }
    }
    
    var foreground: Color {
        switch self {
        case .error:
            return .white
        case .success:
            return .white
        }
    }
}


struct AppSnackbar: View {
    var errorMessage: String
    var type: SnackbarType
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(errorMessage)
                    .foregroundStyle(type.foreground)
                
                Spacer()
                
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(type.foreground)
                    .onTapGesture {
                        isPresented = false
                    }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(type.background)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task {
            try? await Task.sleep(for: .seconds(2))
            isPresented = false
        }
    }
}


#Preview {
    AppSnackbar(errorMessage: "Error when calling API", type: .error, isPresented: .constant(false))
}
