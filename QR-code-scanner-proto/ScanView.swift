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
    @State var isScanning = true
    @State var isShowingImage = false
    @State var scannedString:String?
    @State var triggerString:String = ""
    @State var rawImage:UIImage?
    @State var detectedCount = 0
    @EnvironmentObject var entry:Boats

    var body: some View {
        if isScanning {
            ZStack {
                CodeScannerView(codeTypes: [.qr], scanMode: .continuous, scanInterval: 0.5, simulatedData: "bla bla", videoCaptureDevice: AVCaptureDevice(uniqueID: camera)) { response in
                    switch response {
                    case .success(let result):
                        //rawImage = result.image
                        let (x0, y0, x1, y1, x2, y2, x3, y3) = (result.corners[0].x, result.corners[0].y, result.corners[1].x, result.corners[1].y, result.corners[2].x, result.corners[2].y, result.corners[3].x, result.corners[3].y)
                        let centre_x = (x0 + x1 + x2 + x3) / 4.0
                        let centre_y = (y0 + y1 + y2 + y3) / 4.0
                        let width = (x0 + x3 - x1 - x2) / 2.0
                        let height = (y2 + y3 - y1 - y0) / 2.0
                        //scannedString = result.string + String(format: "bottom left: %.1f, %.1f\nbottom right: %.1f, %.1f\ntop left: %.1f, %.1f\ntop right: %.1f, %.1f", x0, y0, x1, y1, x3, y3, x2, y2)
                        scannedString = result.string + String(format: "centre: %.2f, %.2f\nheight: %.2f\nwidth: %.2f", centre_x, centre_y, height, width)
                        //isShowingImage = true
                        
                        let hasTraversedHalfway = entry.detected(id:result.string, x: centre_x)
                        
                        if hasTraversedHalfway {
                            
                            triggerString = result.string + "\nTraversed"
                        } else {
                            triggerString = result.string + "\nDetected"
                        }
                        
                    case .failure(let error):
                        scannedString = error.localizedDescription
                    }
                    
                }
                VStack (alignment: .leading){
                    Text(triggerString)
                    Button("Reset") { entry.reset() }
                    Button("Stop") { exit(0) }
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
        ScanView(page: .constant(.scan), camera: "previewCamera")
    }
}
