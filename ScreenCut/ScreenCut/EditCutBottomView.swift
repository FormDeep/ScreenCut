//
//  test.swift
//  TestMacApp
//
//  Created by helinyu on 2024/10/25.
//

import SwiftUI

let kAreaSelector: String = "Area Selector"

class EditCutBottomPanel: NSPanel {
    override func mouseDown(with event: NSEvent) {
        return
    }
}

struct EditCutBottomView: View {
    
    @State private var editType:EditCutBottmType = .none

//    @AppStorage("isEditCutSecondShow") var isEditCutSecondShow:Bool = false
    
    @StateObject private var editCutSecondItem = EditCutSecondShowModel()

    func onEditClicked(_ type: EditCutBottmType) {
        print("lt -- type click : \(type)")
        editCutSecondItem.isEditCutSecondShow = true
        if (self.editType == type) {
            return
        }
        
        self.editType = type
        let item = EditCutBottomShareModel()
        item.cutType = type
        NotificationCenter.default.post(name: NSNotification.Name("firstEditType"), object: item)
    }
    
    private func createShapeImageView(for type: EditCutBottmType) -> some View {
        Image(nsImage: NSImage(systemSymbolName: type.imgName, accessibilityDescription: nil) ?? NSImage())
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
            .foregroundColor(editType == type ? Color.black : Color.white)
            .background(editType == type ? Color.white : Color.black)
            .padding(10)
            .cornerRadius(3)
            .tag(type.imgName)
    }
    
    var body: some View {
        VStack {
            HStack {
                ForEach(EditCutBottmType.allCases) { type in
                    createShapeImageView(for: type)
                        .onTapGesture {
                            onEditClicked(type)
                        }
                }
                Divider()
                    .frame(width: 2, height: 30)  // 设置分割线的高度
                    .background(Color.black.opacity(0.3))  // 设置分割线的颜色
                if let xImg = NSImage(systemSymbolName: "xmark", accessibilityDescription: nil) {
                    Image(nsImage: xImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(10)
                        .onTapGesture {
                            for w in NSApplication.shared.windows.filter({ $0.title == kAreaSelector || $0.title == "Start Recording" || $0.title == "编辑图片"}) { w.close() }
                                                        AppDelegate.stopGlobalMouseMonitor()
                        }
                }
                if let downloadImg = NSImage(systemSymbolName: "square.and.arrow.down", accessibilityDescription: nil) {
                    Image(nsImage: downloadImg)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(10)
                        .onTapGesture {
                                    AreaSelector.cutImage()
                            for w in NSApplication.shared.windows.filter({ $0.title == kAreaSelector || $0.title == "Start Recording" || $0.title == "编辑图片"}) { w.close() }
                                                        AppDelegate.stopGlobalMouseMonitor()
                        }
                }
                
            }.frame(height: 40.0)
            if editCutSecondItem.isEditCutSecondShow {
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
    @AppStorage("text-font-size") var selectedNumber: Int = 12
    @AppStorage("text-line-width") var lineWidth: Int = 2
    @AppStorage("text-color") var selectedColor: SelectedColorHandle = .red
    
    func onSecondEditSizeClicked(_ lineWidth: Int) {
        print("lt -- lineWidth click : \(lineWidth)")
        self.lineWidth = lineWidth
        let item = EditCutBottomShareModel()
        item.sizeValue = CGFloat(self.lineWidth)
        NotificationCenter.default.post(name: NSNotification.Name("secondEditSize"), object: item)
    }
    
    func onSecondEditColorClicked(_ selectedColor: SelectedColorHandle) {
        print("lt -- selectedColor click : \(selectedColor)")
        
        self.selectedColor = selectedColor
        let item = EditCutBottomShareModel()
        item.selectColor = selectedColor
        NotificationCenter.default.post(name: NSNotification.Name("secondEditColor"), object: item)
    }
    
    private func createLineWidthImageView(for type: LineWidthType) -> some View {
        HStack {
            Image(nsImage: NSImage(systemSymbolName: "circlebadge.fill", accessibilityDescription: nil) ?? NSImage())
                .resizable()
                .scaledToFit()
                .frame(width: CGFloat(type.rawValue) * 4, height: CGFloat(type.rawValue) * 4)
                .foregroundColor(.white)
                .padding(10)
                .background(lineWidth == type.rawValue ? Color.white.opacity(0.3) : Color.black)
                
        }.frame(width: 25, height: 25).cornerRadius(3, antialiased: true)
    }
    
    private func createColorView(for type: SelectedColorHandle) -> some View {
        type.swiftColor
            .frame(height: 30.0)
            .border(type.swiftColor == selectedColor.swiftColor ? Color.purple: Color.clear, width: 2)
    }
    
    var body: some View {
        HStack {
            if isText {
                HStack {
                    Stepper("文字: \(selectedNumber)", value: $selectedNumber, in: 14...100)
                        .padding()
                        .foregroundColor(.white)
                }.frame(width: 140.0)
            }
            else {
                HStack {
                    ForEach(LineWidthType.allCases) { type in
                        createLineWidthImageView(for: type)
                            .onTapGesture {
                                onSecondEditSizeClicked(type.rawValue)
                            }
                    }
                }.frame(width: 150.0)
            }
            
            HStack {
                ForEach(SelectedColorHandle.allCases) { type in
                    createColorView(for: type)
                        .onTapGesture {
                        self.onSecondEditColorClicked(type)
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


//struct EditCutBottomView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditCutBottomView()
//    }
//}
