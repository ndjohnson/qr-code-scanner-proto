//
//  SelectCameraView.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 19/07/2023.
//

import SwiftUI
import AVKit

struct SelectCameraView: View {
    @Binding var page:ActivePage
    @Binding<String> var activeCamera:String
    @State var cameraList:[String] = []
    
    var body: some View {
        let session = AVCaptureDevice.DiscoverySession (deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        
        VStack {
            Picker("Select Camera", selection: $activeCamera) {
                ForEach (session.devices, id: \.uniqueID) {device in Text(device.localizedName)}
            }
                
                Button ("Done") { page = .home}
        }
    }
}

struct SelectCameraView_Previews: PreviewProvider {
    static var previews: some View {
        SelectCameraView(page: .constant(.selectCamera), activeCamera: .constant(""))
    }
}
