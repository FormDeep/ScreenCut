//
//  ContentView.swift
//  TestMacApp
//
//  Created by helinyu on 2024/10/24.
//

import SwiftUI
import FileKit

struct ContentView: View {
    var body: some View {
        VStack {
            Button("保存图片") {
                Task {
//                    await ScreenCut().captureScreenImage()
                }
            }
            
            Button("显示蒙版") {
                Task {
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
