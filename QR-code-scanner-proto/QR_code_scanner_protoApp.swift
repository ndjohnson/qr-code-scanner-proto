//
//  QR_code_scanner_protoApp.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/15/23.
//

import SwiftUI

var activeCamera:String = ""
var activePage:ActivePage = .home

@main
struct QR_code_scanner_protoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        WindowGroup(id: "ScanWindow") {
            ScanViewFixed()
        }
    }
}
