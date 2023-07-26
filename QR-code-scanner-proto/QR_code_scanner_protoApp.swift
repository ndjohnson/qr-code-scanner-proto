//
//  QR_code_scanner_protoApp.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/15/23.
//

import SwiftUI

var entry = Boats([Boat("139"), Boat("140"), Boat("141")])

@main
struct QR_code_scanner_protoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(entry)
        }
    }
}
