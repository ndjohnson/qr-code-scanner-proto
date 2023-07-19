//
//  ContentView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 7/15/23.
//

import SwiftUI
import CodeScanner

enum ActivePage {
    case home
    case scan
    case selectCamera
}


struct ContentView: View {
    @State var activePage:ActivePage = .home
    @State var activeCamera:String = ""
    
    var body: some View {
        switch activePage {
        case .home:
            VStack {
                Button ("Select Camera") { activePage = .selectCamera }
                Button ("Scan") { activePage = .scan }
                Button ("Done") { exit(0) }
            }
        case .scan:
            ScanView(page: $activePage, camera: activeCamera)
            
        case .selectCamera:
            SelectCameraView(page: $activePage, activeCamera: $activeCamera)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
