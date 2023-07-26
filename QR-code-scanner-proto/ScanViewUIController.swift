//
//  ScanViewUIController.swift
//  QR-code-scanner-proto
//
//  Created by Nick Johnson on 25/07/2023.
//


import AVFoundation
import UIKit

@available(macCatalyst 14.0, *)
extension CodeScanView {
    
    public class ScanViewUIController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCaptureMetadataOutputObjectsDelegate, UIAdaptivePresentationControllerDelegate {
        private let photoOutput = AVCapturePhotoOutput()
        private var handler2: ((UIImage) -> Void)?
        var parentView: CodeScanView!
        var codesFound = Set<String>()
        var lastTime = Date(timeIntervalSince1970: 0)
        
        let fallbackVideoCaptureDevice = AVCaptureDevice.default(for: .video)
        
        public init(parentView: CodeScanView) {
            self.parentView = parentView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer!

        private lazy var manualCaptureButton: UIButton = {
            let button = UIButton(type: .system)
            let image = UIImage(named: "capture", in: nil, with: nil)
            button.setBackgroundImage(image, for: .normal)
            button.addTarget(self, action: #selector(manualCapturePressed), for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            return button
        }()

        override public func viewDidLoad() {
            super.viewDidLoad()
            self.addOrientationDidChangeObserver()
            self.setBackgroundColor()
            self.handleCameraPermission()
        }

        override public func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }

        @objc func updateOrientation() {
            guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession?.connections.last, connection.isVideoOrientationSupported else { return }
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
            }
        }

        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateOrientation()
        }

        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            setupSession()
        }
      
        private func setupSession() {
            guard let captureSession = captureSession else {
                return
            }
            
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }

            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)

            reset()

            if (captureSession.isRunning == false) {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.startRunning()
                }
            }
        }

        private func handleCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
                case .restricted:
                    break
                case .denied:
                    self.didFail(reason: .permissionDenied)
                case .notDetermined:
                    self.requestCameraAccess {
                        self.setupCaptureDevice()
                        DispatchQueue.main.async {
                            self.setupSession()
                        }
                    }
                case .authorized:
                    self.setupCaptureDevice()
                    self.setupSession()
                    
                default:
                    break
            }
        }

        private func requestCameraAccess(completion: (() -> Void)?) {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                guard status else {
                    self?.didFail(reason: .permissionDenied)
                    return
                }
                completion?()
            }
        }
      
        private func addOrientationDidChangeObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateOrientation),
                name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                object: nil
            )
        }
      
        private func setBackgroundColor(_ color: UIColor = .black) {
            view.backgroundColor = color
        }
      
        private func setupCaptureDevice() {
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice else {
                return
            }

            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                didFail(reason: .initError(error))
                return
            }

            if (captureSession!.canAddInput(videoInput)) {
                captureSession!.addInput(videoInput)
            } else {
                didFail(reason: .badInput)
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession!.canAddOutput(metadataOutput)) {
                captureSession!.addOutput(metadataOutput)
                captureSession?.addOutput(photoOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = parentView.codeTypes
            } else {
                didFail(reason: .badOutput)
                return
            }
        }

        override public func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)

            if (captureSession?.isRunning == true) {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.stopRunning()
                }
            }

            NotificationCenter.default.removeObserver(self)
        }

        override public var prefersStatusBarHidden: Bool {
            true
        }

        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            .all
        }

        /** Touch the screen for autofocus */
        public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard touches.first?.view == view,
                  let touchPoint = touches.first,
                  let device = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice,
                  device.isFocusPointOfInterestSupported
            else { return }

            let videoView = view
            let screenSize = videoView!.bounds.size
            let xPoint = touchPoint.location(in: videoView).y / screenSize.height
            let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
            let focusPoint = CGPoint(x: xPoint, y: yPoint)

            do {
                try device.lockForConfiguration()
            } catch {
                return
            }

            // Focus to the correct point, make continiuous focus and exposure so the point stays sharp when moving the device closer
            device.focusPointOfInterest = focusPoint
            device.focusMode = .continuousAutoFocus
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.unlockForConfiguration()
        }
        
        @objc func manualCapturePressed(_ sender: Any?) {
            self.readyManualCapture()
        }
        
        func showManualCaptureButton(_ isManualCapture: Bool) {
            if manualCaptureButton.superview == nil {
                view.addSubview(manualCaptureButton)
                NSLayoutConstraint.activate([
                    manualCaptureButton.heightAnchor.constraint(equalToConstant: 60),
                    manualCaptureButton.widthAnchor.constraint(equalTo: manualCaptureButton.heightAnchor),
                    view.centerXAnchor.constraint(equalTo: manualCaptureButton.centerXAnchor),
                    view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: manualCaptureButton.bottomAnchor, constant: 32)
                ])
            }
            
            view.bringSubviewToFront(manualCaptureButton)
            manualCaptureButton.isHidden = !isManualCapture
        }
        
        func updateViewController(isTorchOn: Bool, isGalleryPresented: Bool, isManualCapture: Bool, isManualSelect: Bool) {
            guard let videoCaptureDevice = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice else {
                return
            }
            
            if videoCaptureDevice.hasTorch {
                try? videoCaptureDevice.lockForConfiguration()
                videoCaptureDevice.torchMode = isTorchOn ? .on : .off
                videoCaptureDevice.unlockForConfiguration()
            }
        }
        
        public func reset() {
            codesFound.removeAll()
            lastTime = Date(timeIntervalSince1970: 0)
        }
        
        public func readyManualCapture() {
            guard parentView.scanMode == .manual else { return }
            self.reset()
            lastTime = Date()
        }

        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            var foundCodes:[FoundCode] = []
            
            for metadataObject in metadataObjects {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                
                if isPastScanInterval() {
                    let cc = readableObject.corners
                    let cx = (cc[0].x + cc[1].x + cc[2].x + cc[3].x)/4.0
                    let cy = (cc[0].y + cc[1].y + cc[2].y + cc[3].y)/4.0
                    let codeCentre = CGPoint(x:cx, y:cy)
                    
                    foundCodes.append(FoundCode(code: stringValue, type: readableObject.type, centre: codeCentre))
                    if metadataObject == metadataObjects.last {
                        let photoSettings = AVCapturePhotoSettings()
                        handler2 = { [self] image in
                            let result = MultiScanResult(results: foundCodes, image: image)
                            foundMulti(result)
                        }
                        photoOutput.capturePhoto(with: photoSettings, delegate: self)
                    }
                }
            }
        }

        func isPastScanInterval() -> Bool {
            Date().timeIntervalSince(lastTime) >= parentView.scanInterval
        }
        
        func isWithinManualCaptureInterval() -> Bool {
            Date().timeIntervalSince(lastTime) <= 0.5
        }

        func found(_ result: ScanResult) {
            lastTime = Date()

            if parentView.shouldVibrateOnSuccess {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }

            parentView.completion(.success(result))
        }
        
        func foundMulti(_ result: MultiScanResult) {
            lastTime = Date()
            
            parentView.multiCompletion(.success(result))
        }

        func didFail(reason: ScanError) {
            parentView.completion(.failure(reason))
        }
        
    }
}

@available(macCatalyst 14.0, *)
extension CodeScanView.ScanViewUIController: AVCapturePhotoCaptureDelegate {
    
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation() else {
            print("Error while generating image from photo capture data.");
            return
        }
        guard let qrImage = UIImage(data: imageData) else {
            print("Unable to generate UIImage from image data.");
            return
        }
        handler2?(qrImage)
    }
    
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
    public func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) {
        AudioServicesDisposeSystemSoundID(1108)
    }
    
}

@available(macCatalyst 14.0, *)
public extension AVCaptureDevice {
    
    /// This returns the Ultra Wide Camera on capable devices and the default Camera for Video otherwise.
    static var bestForVideo: AVCaptureDevice? {
        let deviceHasUltraWideCamera = !AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.isEmpty
        return deviceHasUltraWideCamera ? AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) : AVCaptureDevice.default(for: .video)
    }
    
}

