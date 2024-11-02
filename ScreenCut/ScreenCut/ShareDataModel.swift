

//
//  ShareDataModel.swift
//  TestMap
//
//  Created by helinyu on 2024/10/26.
//
import Foundation
import AppKit
import Combine


let kCutTypeChange = "kCutTypeChange"

class EditCutBottomShareModel: ObservableObject {
    static let shared = EditCutBottomShareModel(cutType: .none, sizeType: .Two, lineSize: 12, selectColor: .red)
    
//    private var cancellables = Set<AnyCancellable>()

    init(cutType: EditCutBottmType, sizeType: LineWidthType, lineSize: Int, selectColor: SelectedColorHandle) {
        self.cutType = cutType
        self.sizeType = sizeType
        self.lineSize = lineSize
        self.selectColor = selectColor
        
//            $cutType
//                .sink { newValue in
////                    EditCutBottomShareModel.shared.cutType = newValue
////                    self.cutType = newValue
//                    print("lt -- new value : \(newValue)")
//                    NotificationCenter.default.post(name: Notification.Name(kCutTypeChange), object: newValue)
//                }
//                .store(in: &cancellables)
    }
    
    @Published var cutType: EditCutBottmType = .none {
        didSet {
            NotificationCenter.default.post(name: Notification.Name(kCutTypeChange), object: cutType)
        }
    }
    @Published var sizeType: LineWidthType = .Two // 用来设置绘制的宽度大小，也可能是字体大小
    @Published var lineSize: Int = 12 { // 写字的颜色
        didSet {
            NotificationCenter.default.post(name: Notification.Name("text.size.font.change"), object: "")
        }
    }
    @Published var selectColor: SelectedColorHandle = .red {
        didSet {
            NotificationCenter.default.post(name: Notification.Name("text.color.change"), object: "")
        }
    }
}
