//
//  AboutView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/10/26.
//

import SwiftUI

//struct AboutView: View {
//    var body: some View {
//        Text("Hello word!")
//    }
//}

struct AboutView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image("logo-img-white")
                VStack(alignment: .leading) {
                    Text("ScreenCut")
                        .fontWeight(.bold)
                        .font(.title)
                    Text("版本 1.0")
                        .font(.system(size: 14))
                }
                Spacer()
            }
                .frame(width: 540, height: 80.0)
                .background(.black)
                .foregroundColor(.white)
            
            VStack(alignment: .leading ) {
                Text("你所使用的版本是最新版本")
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                Text("使用本软件意味着你了解并同意遵循服务条款")
                Spacer()
                Text("软件使用部分开源代码和公共领域代码，并遵循相应的协议。")
                Spacer()
                Text("helinyu 版权所有 @2024-未来")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
        }
        .frame(width: 540, height: 200)
    }
}

class AboutWindowController: NSWindowController {
    convenience init() {

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.setFrameAutosaveName("About")
        window.level = .screenSaver
        window.contentView = NSHostingView(rootView: AboutView())
        
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
}


#Preview {
    AboutView()
}
