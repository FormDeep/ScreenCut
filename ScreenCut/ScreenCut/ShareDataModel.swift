

//
//  ShareDataModel.swift
//  TestMap
//
//  Created by helinyu on 2024/10/26.
//
import Foundation
import AppKit



class EditCutBottomShareModel {
    var cutType: EditCutBottmType = .none
    var sizeValue: CGFloat = 0 // 用来设置绘制的宽度大小，也可能是字体大小
    var selectColor: SelectedColorHandle = .red // 使用什么样的颜色
}

class EditCutSecondShowModel: ObservableObject {
    @Published var isEditCutSecondShow: Bool = false
}



