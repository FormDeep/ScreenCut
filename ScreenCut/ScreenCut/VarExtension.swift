//
//  DateExtension.swift
//  TestMacApp
//
//  Created by helinyu on 2024/10/24.
//

import Foundation
import SwiftUI
import FileKit
import ScreenCaptureKit

class VarExtension {
    
    static func getTargetName() -> String {
        guard let targetName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return ""
        }
        return targetName
    }
    
    @MainActor static func createTargetDirIfNotExit() -> String {
        let downLoadPath = Path.userDownloads + self.getTargetName()
        self.createDirIfNotExit(downLoadPath.rawValue)
        return downLoadPath.rawValue
    }
    
    @MainActor static func createDirIfNotExit(_ atPath: String) {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: atPath, isDirectory: &isDirectory) {
            if !isDirectory.boolValue {
                _ = UI.createAlert(title: "Failed to Record", message: "The output path is a file instead of a folder!", button1: "OK").runModal()
                return
            }
        } else {
            do {
                try fileManager.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                _ = UI.createAlert(title: "Failed to Record", message: "Unable to create output folder!", button1: "OK").runModal()
                return
            }
        }
    }
    
}

extension Date {
    static func getNameByDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd HH.mm.ss"
         return dateFormatter.string(from: Date())
    }
}


class Auth {
    static func requestPermissions() {
        DispatchQueue.main.async {
            let alert = UI.createAlert(title: "Permission Required",
                                                       message: "VCB needs screen recording permissions, even if you only intend on recording audio.",
                                                       button1: "Open Settings",
                                                       button2: "Quit")
            if alert.runModal() == .alertFirstButtonReturn {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
            }
            NSApp.terminate(NSApplication.shared)
        }
    }
}

class UI {
    @MainActor static func createAlert(title: String, message: String, button1: String, button2: String = "") -> NSAlert {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: button1)
        if button2 != "" {
            alert.addButton(withTitle: button2)
        }
        alert.alertStyle = .critical
        return alert
    }
}

