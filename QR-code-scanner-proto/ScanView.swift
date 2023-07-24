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
    @EnvironmentObject var entry:Boats
    @State var snapShot:UIImage?

    var body: some View {
        if isScanning {
            HStack {
                //if let snapShot { Image(uiImage: snapShot) }
                CodeScannerView(codeTypes: [.qr], scanMode: .continuous, scanInterval: 2.0, shouldVibrateOnSuccess: isVibrate, videoCaptureDevice: AVCaptureDevice(uniqueID: camera), multiCompletion: multiComplete) { response in
                    switch response {
                    case .success(let result):
                        let boatId = result.string
                        let c = result.corners
                        let x = (c[0].x + c[1].x + c[2].x + c[3].x) / 4.0
                        print("detected: \(boatId)\n")
                        _ = entry.detected(id: boatId, x: x)
                        
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
                            Text("\(boat.id): \(boat.track.count)")
                        }
                    }
                    Text("Started")
                    ForEach(entry.boats) { boat in
                        if boat.state == .started {
                            Text("\(boat.id): \(boat.track.count)")
                        }
                    }
                    Text("Finished")
                    ForEach(entry.boats) { boat in
                        if boat.state == .finished {
                            Text("\(boat.id): \(boat.track.count)")
                        }
                    }
                }.background(.gray.opacity(0.5))
            }
        } else {
            Text ("Preview")
        }
    }
    
    func multiComplete (_ response: Result<MultiScanResult, ScanError>) {
        switch response {
        case .success(let result):
            let multiScan = result.results
            snapShot = result.image
            triggerString = "found \(multiScan.count) codes"
            for scan in multiScan {
                print ("found \(scan.qrCode), centre = \(scan.centre)")
                _ = entry.detected(id: scan.qrCode, x: scan.centre.x)
            }
            
        case .failure:
            print("what are you doing here?")
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView(page: .constant(.scan), camera: "previewCamera", isVibrate: false)
    }
}
