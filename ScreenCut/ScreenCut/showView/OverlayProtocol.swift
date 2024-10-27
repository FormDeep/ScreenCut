//
//  OverlayProtocol.swift
//  TestMap
//
//  Created by helinyu on 2024/10/27.
//

import AppKit
import Foundation
import SwiftUI

protocol OverlayProtocol {
    var selectedColor: NSColor { get set }
    var lineWidth: CGFloat { get set }
}
