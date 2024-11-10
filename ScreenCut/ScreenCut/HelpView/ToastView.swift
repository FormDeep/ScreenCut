//
//  ToastView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/11/10.
//

import Foundation
import SwiftUI

struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .padding()
            .background(Color.black.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 10)
            .transition(.opacity)
    }
}

struct ShowToastView: View {
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        ZStack {
//            VStack {
//                Text("Hello, SwiftUI!")
//                Button("Show Toast") {
//                    showToastMessage("This is a Toast message!")
//                }
//            }
            
            // 当 showToast 为 true 时显示 Toast
            if showToast {
                ToastView(message: toastMessage)
                    .padding()
                    .onAppear {
                        // 自动隐藏 Toast，延迟2秒
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: showToast)
    }
    
    func showToastMessage(_ message: String) {
        toastMessage = message
        withAnimation {
            showToast = true
        }
    }
}

