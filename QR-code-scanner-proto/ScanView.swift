//
//  ScanView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 19/07/2023.
//

import SwiftUI
import CodeScanner
import AVFoundation

struct ScanViewFixed: View {
    var body: some View {
        Text("Hello from ScanViewFixed")
    }
}

struct ScanViewFixed_Previews: PreviewProvider {
    static var previews : some View {
        ScanViewFixed()
    }
}

struct ScanView: View {
    @Binding var page:ActivePage
    var camera:String
    var isVibrate:Bool
    @State var isScanning = true
    @State var isShowingImage = false
    @State var scannedString:String?
    @State var triggerString:String = ""
    @State var detectedCount = 0
    @EnvironmentObject var entry:Boats

    var body: some View {
        if isScanning {
            ZStack {
                CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, scanInterval: 2.0, shouldVibrateOnSuccess: isVibrate, videoCaptureDevice: AVCaptureDevice(uniqueID: camera)) { response in
                    switch response {
                    case .success(let result):
                        print("detected: \(result.string)\n")
                        
                    case .failure(let error):
                        scannedString = error.localizedDescription
                    }
                    
                }
                VStack (alignment: .leading){
                    Text(triggerString)
                    Button("Reset") { entry.reset() }
                    Button("Stop") { page = .home }
                    Text("Not Started")
                    ForEach(entry.boats) { boat in
                        if boat.state == .notStarted {
                            //detectedCount = boat.track.count
                            Text("\(boat.id): \(boat.track.count)")
                        }
                    }
                    Text("Started")
                    ForEach(entry.boats) { boat in
                        if boat.state == .started {
                            //detectedCount = boat.track.count
                            Text("\(boat.id): \(detectedCount), \(boat.track.count)")
                        }
                    }
                    Text("Finished")
                    ForEach(entry.boats) { boat in
                        if boat.state == .finished {
                            //detectedCount = boat.track.count
                            Text("\(boat.id): \(boat.track.count), \(boat.finishTime)")
                        }
                    }
                }.background(.gray.opacity(0.5))
            }
        } else {
            Text ("Preview")
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(page: .constant(.scan), camera: "previewCamera", isVibrate: false)
    }
}
