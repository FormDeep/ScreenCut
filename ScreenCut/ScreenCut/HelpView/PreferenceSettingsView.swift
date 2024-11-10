//
//  SwiftUIView.swift
//  ScreenCut
//
//  Created by helinyu on 2024/10/26.
//

import SwiftUI
import KeyboardShortcuts
import Sparkle

let kLeftTextWidth = 120.0
let kRightFirstSpaceWidth = 20.0
let kDesktoptext = "桌面"
let kDocumentText = "文档"
let kImageText = "图片"
let kOtherText = "其他"
let kDefaultText = "ScreenCut"


struct PreferenceSettingsView: View {
    
    enum PathSelectionThpe: String, CaseIterable {
        case defaultS, desktopS, documentS, imageS
        var id: Self { self }
        //        static var allCases: [PathSelectionThpe] = [defaultS, desktopS, documentS, imageS]
        
        var path: String {
            switch self {
            case .defaultS:
                return defaultSavepath
            case .desktopS:
                return FileManager.default.urls(for:.desktopDirectory, in:.userDomainMask).first?.path ?? ""
            case .documentS:
                return FileManager.default.urls(for:.documentDirectory, in:.userDomainMask).first?.path ?? ""
            case .imageS:
                return FileManager.default.urls(for:.picturesDirectory, in:.userDomainMask).first?.path ?? ""
            }
        }
        
        var name: String {
            switch self {
            case .defaultS:
                return "ScreenCut"
            case .desktopS:
                return kDesktoptext
            case .documentS:
                return kDocumentText
            case .imageS:
                return kImageText
            }
        }
    }
    
    @AppStorage(kplayAudioOfFinished) private var playAudioOfFinished: Bool = false // 截图完成播放音效
    @AppStorage(ksavePasteboardSameTime) private var savePasteboardSameTime: Bool = true // 同时拷贝到粘贴版
    @AppStorage(konlySaveInPasteBoard) private var onlySaveInPasteBoard: Bool = false // 只是拷贝到粘地板
    @AppStorage(kautoUpdate) private var autoUpdate: Bool = false // 自动更新
    @AppStorage(kautoLaunchByComputer) private var autoLaunchByComputer: Bool = false // 根据电脑自动启动
    @AppStorage(kSelectedSavePath) private var lastSelectedPath: String = defaultSavepath
    
    @State private var selectOption:PathSelectionThpe = .defaultS
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Spacer().frame(width: 20)
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
            .frame(height: 80.0)
            .background(.black)
            .foregroundColor(.white)
            VStack (alignment: .leading){
                HStack() {
                    Text("全屏截图快捷键: ")
                        .frame(width: kLeftTextWidth, alignment: .trailing)
                    KeyboardShortcuts.Recorder("", name: .fullScreenCut)
                }
                HStack() {
                    Text("区域截图快捷键: ")
                        .frame(width: kLeftTextWidth, alignment: .trailing)
                    KeyboardShortcuts.Recorder("", name: .selectedAreaCut)
                }
                HStack(alignment: .top) {
                    Text("截屏时: ")
                        .frame(width: kLeftTextWidth, alignment: .trailing)
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer().frame(width: kRightFirstSpaceWidth)
                            Toggle("截图完成后播放声音", isOn: $playAudioOfFinished)
                                .toggleStyle(CheckboxToggleStyle())
                        }
                        //                         滚动截屏
                        //                        HStack {
                        //                            Spacer().frame(width: kRightFirstSpaceWidth)
                        //                            Toggle("启动滚动截屏", isOn: $playAudioOfFinished)
                        //                                .toggleStyle(CheckboxToggleStyle())
                        //                        }
                    }
                }
                //                Divider()
                //                Spacer().frame(height: 10.0)
                //                HStack {
                //                    Text("图片大小: ")
                //                        .frame(width: kLeftTextWidth, alignment: .trailing)
                //                        .background(.purple)
                //                    HStack {
                //                        Spacer().frame(width: kRightFirstSpaceWidth)
                //                        Toggle("高清屏幕(Retina)下载取1x大小图片", isOn: $playAudioOfFinished)
                //                            .toggleStyle(CheckboxToggleStyle())
                //                    }
                //                }
                //                Spacer().frame(height: 10.0)
                Divider()
                Spacer().frame(height: 10.0)
                HStack(alignment: .top) {
                    Text("图片保存的位置:")
                        .frame(width: kLeftTextWidth, alignment: .trailing)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(self.lastSelectedPath)
                            Button("修改") {
                                let openPanel = NSOpenPanel()
                                openPanel.canChooseFiles = false
                                openPanel.canChooseDirectories = true
                                openPanel.allowedContentTypes = []
                                openPanel.allowsOtherFileTypes = false
                                if openPanel.runModal() == NSApplication.ModalResponse.OK {
                                    if let path = openPanel.urls.first?.path {
                                        self.lastSelectedPath = path
                                    }
                                }
                            }
                        }
                        Toggle("同时保存在粘贴版", isOn: $savePasteboardSameTime)
                            .toggleStyle(CheckboxToggleStyle())
                        Toggle("只保存到粘贴版", isOn: $onlySaveInPasteBoard)
                            .toggleStyle(CheckboxToggleStyle())
                    }
                }
                Spacer().frame(height: 10.0)
                Divider()
                Spacer().frame(height: 10.0)
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer().frame(width: kLeftTextWidth)
                            Spacer().frame(width: kRightFirstSpaceWidth)
                            Toggle("开机自动启动", isOn: $autoLaunchByComputer)
                                .toggleStyle(CheckboxToggleStyle())
                        }
                        HStack {
                            Spacer().frame(width: kLeftTextWidth)
                            Spacer().frame(width: kRightFirstSpaceWidth)
                            Toggle("自动检查更新", isOn: $autoUpdate)
                                .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                }
                HStack {
                    Spacer().frame(width: kLeftTextWidth)
                    Spacer().frame(width: kRightFirstSpaceWidth)
                    Button {
                        NotificationCenter.default.post(name: Notification.Name("update.app.noti"), object: "")
                    } label: {
                        Text("检查更新")
                    }
                }
                
                Spacer().frame(height: 30.0)
            }.padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 0))
        }
    }
}


class PreferenceSettingsViewController: NSWindowController {
    
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window.center()
        window.setFrameAutosaveName("偏好设置")
        window.level = .normal + 1
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
