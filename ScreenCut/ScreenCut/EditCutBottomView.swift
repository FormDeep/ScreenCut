//
//  test.swift
//  TestMacApp
//
//  Created by helinyu on 2024/10/25.
//

import SwiftUI

let kAreaSelector: String = "Area Selector"

class EditCutBottomPanel: NSWindow {

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        isMovable = false
    }

    override func mouseDown(with event: NSEvent) {
        return
    }
}

let FirstIconLength: CGFloat = 15
let FirstIconPadding: CGFloat = 5

struct EditCutBottomView: View {
    
    @StateObject private var bottomEditItem = EditCutBottomShareModel.shared

    private func createShapeImageView(for type: EditCutBottmType) -> some View {
        Image(nsImage: NSImage(systemSymbolName: type.imgName, accessibilityDescription: nil) ?? NSImage())
            .resizable()
            .scaledToFit()
            .frame(width: FirstIconLength, height: FirstIconLength)
            .foregroundColor(bottomEditItem.cutType == type ? Color.black : Color.white)
            .background(bottomEditItem.cutType == type ? Color.white : Color.black)
            .padding(FirstIconPadding)
            .cornerRadius(3)
            .tag(type.imgName)
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(EditCutBottmType.allCases) { type in
                    createShapeImageView(for: type)
                        .onTapGesture {
                            bottomEditItem.cutType = type
                        }
                }
                Divider()
                    .frame(width: 2, height: 30)  // 设置分割线的高度
                    .background(Color.black.opacity(0.3))  // 设置分割线的颜色
                if let xImg = NSImage(systemSymbolName: "xmark", accessibilityDescription: nil) {
                    Image(nsImage: xImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: FirstIconLength, height: FirstIconLength)
                        .foregroundColor(.white)
                        .padding(FirstIconPadding)
                        .onTapGesture {
                            for w in NSApplication.shared.windows.filter({ $0.title == kAreaSelector || $0.title == "Start Recording" || $0.title == "编辑图片"}) { w.close() }
                                                        AppDelegate.stopGlobalMouseMonitor()
                        }
                }
                if let downloadImg = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil) {
                    Image(nsImage: downloadImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: FirstIconLength, height: FirstIconLength)
                        .foregroundColor(.white)
                        .padding(FirstIconPadding)
                        .onTapGesture {
                            ScreenCut.cutImage()
                            for w in NSApplication.shared.windows.filter({ $0.title == kAreaSelector || $0.title == "Start Recording" || $0.title == "编辑图片"}) { w.close() }
                                                        AppDelegate.stopGlobalMouseMonitor()
                        }
                }
                
                if let translateImg = NSImage(systemSymbolName: "text.document", accessibilityDescription: nil) {
                    Image(nsImage: translateImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: FirstIconLength, height: FirstIconLength)
                        .foregroundColor(.white)
                        .padding(FirstIconPadding)
                        .onTapGesture {
                            ScreenCut.showOCR()
                        }
                }
                if let translateImg = NSImage(systemSymbolName: "translate", accessibilityDescription: nil) {
                    Image(nsImage: translateImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: FirstIconLength, height: FirstIconLength)
                        .foregroundColor(.white)
                        .padding(FirstIconPadding)
                        .onTapGesture {
//                            ScreenCut.showOCR()
                            ScreenCut.ocrThenTransRequest()
                        }
                }
                
            }.frame(height: 40.0)
            if bottomEditItem.cutType != .none {
                SecondEditView()
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color.black.opacity(0.7))
            .frame(width: 350.0)
            .frame(maxWidth: .infinity)
    }
}

struct SecondEditView: View {
    var isText: Bool = false
    
    @StateObject private var bottomEditItem = EditCutBottomShareModel.shared

    private func createLineWidthImageView(for type: LineWidthType) -> some View {
        HStack {
            Image(nsImage: NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil) ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(width: CGFloat(type.rawValue) * 4, height: CGFloat(type.rawValue) * 4)
                .foregroundColor(.white)
                .padding(10)
                .background(bottomEditItem.sizeType == type ? Color.white.opacity(0.3) : Color.black)
                
        }.frame(width: 25, height: 25).cornerRadius(3, antialiased: true)
    }
    
    private func createColorView(for type: SelectedColorHandle) -> some View {
        type.swiftColor
            .frame(height: 30.0)
            .border(type == bottomEditItem.selectColor ? Color.purple: Color.clear, width: 2)
    }
    
    var body: some View {
        HStack {
            if bottomEditItem.cutType == .text {
                HStack {
                    Picker("  文字:", selection: $bottomEditItem.lineSize) {
                        ForEach(12...100, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(MenuPickerStyle()) // 使用下拉菜单样式
                    .frame(width: 120)
                    .background(.clear)
                    .cornerRadius(5)
                    .foregroundColor(.white)
                    .padding()
                }.frame(width: 140.0)
            }
            else {
                HStack {
                    ForEach(LineWidthType.allCases) { type in
                        createLineWidthImageView(for: type)
                            .onTapGesture {
                                self.bottomEditItem.sizeType = type
                            }
                    }
                }.frame(width: 150.0)
            }
            
            HStack {
                ForEach(SelectedColorHandle.allCases) { type in
                    createColorView(for: type)
                        .onTapGesture {
                            self.bottomEditItem.selectColor = type
                    }
                }
            }.frame(width: 200.0)
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .background(Color.black.opacity(0.7))
            .frame(width: 350.0 ,height: 40)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    SecondEditView()
}

#Preview {
    EditCutBottomView()
}

