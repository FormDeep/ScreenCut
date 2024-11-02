//
//  SwiftUIView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/10/26.
//

import SwiftUI
import KeyboardShortcuts
import Sparkle

struct PreferenceSettingsView: View {
    
    @State private var playAudioOfFinished : Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Image("logo-img-white")
                VStack(alignment: .leading) {
                    Text("偏好设置")
                        .fontWeight(.bold)
                        .font(.title)
                    Text("请使用前完成一下设置")
                        .font(.system(size: 14))
                }
                Spacer()
            }
                .frame(width: 540, height: 80.0)
                .background(.black)
                .foregroundColor(.white)
            VStack {
                HStack {
//                    Form {
                        KeyboardShortcuts.Recorder("选择区域截图", name: .selectedAreaCut)
//                    }
                }
                HStack(alignment: .top) {
                    Text("截屏时:")
                    VStack(alignment: .leading) {
                        Toggle("截图完成后播放声音", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                                      
                        Toggle("启动滚动截屏", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                    }
                }
                Divider()
                HStack {
                    Text("图片大小:")
                    Toggle("高清屏幕(Retina)下载取1x大小图片", isOn: $playAudioOfFinished)
                                   .toggleStyle(CheckboxToggleStyle())
                    
                }
                Divider()
                HStack(alignment: .top) {
                    Text("图片保存的位置:")
                    VStack(alignment: .leading) {
                        Toggle("存储的文件路径", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                                      
                        Toggle("同时保存在粘贴版", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                        Toggle("只保存到粘贴版", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                    }
                }
                Divider()
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Toggle("开机自动启动", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                        Toggle("自动检查更新", isOn: $playAudioOfFinished)
                                       .toggleStyle(CheckboxToggleStyle())
                    }
                }
                Button {
                    NotificationCenter.default.post(name: Notification.Name("update.app.noti"), object: "")
                } label: {
                    Text("检查更新")
                }

                
            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
        
        }
        .background(.red)
    }
}


class PreferenceSettingsViewController: NSWindowController {
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.setFrameAutosaveName("偏好设置")
        window.level = .screenSaver
        window.contentView = NSHostingView(rootView: PreferenceSettingsView())
        
        self.init(window: window)
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
    }
}


#Preview {
    PreferenceSettingsView()
}
