//
//  ScanControl.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Foundation
import UIKit
import AVFoundation
import Vision
import VideoToolbox

enum ScanError: Error {
    case unknown
    case camera
}

class ScanControl: UIControl, ScanControlable {
    
    // MARK: - Init
    static func instantiate() -> ScanControl {
        let control = UINib(nibName: "ScanControl", bundle: Bundle(for: self.classForCoder()))
            .instantiate(withOwner: self, options: nil)[0] as! ScanControl
        return control
    }
    
    // MARK: - Properties
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "scanControl session queue", attributes: [], target: nil)
    private let videoDataQueue = DispatchQueue(label: "scanControl videoData queue")
    private let visionQueue = DispatchQueue(label: "scanControl vision queue", qos: .userInitiated,
                                            attributes: [], autoreleaseFrequency: .inherit, target: nil)
    private let metadataOutput = AVCaptureMetadataOutput()
    private let videoOutput = AVCaptureVideoDataOutput()
    
    private var authStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.connection?.videoOrientation = .portrait
        return layer
    }()
    private lazy var barcodeDetectionRequest: VNDetectBarcodesRequest = {
        let request = VNDetectBarcodesRequest { [weak self] (request, error) in
            if let results = request.results as? [VNBarcodeObservation],
                let observation = results.first {
                self?.processBarcode(observation: observation)
            } else {
                self?.currentBuffer = nil
                self?.shouldScan = true
            }
        }
        request.symbologies = [.QR, .DataMatrix] //.Aztec, .UPCE]
        return request
    }()
    private var currentBuffer: CVPixelBuffer?
    private var isFailedCamera = false
    
    // MARK: - Outlets
    @IBOutlet weak var scannerView: UIView!
    
    // MARK: - ScanControlable
    var didDetect: ((String?, UIImage?, VNBarcodeSymbology) -> Void)?
    var didFail: ((ScanError?) -> Void)?
    var shouldScan: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.bounds
    }
    public func setup() {
        if authStatus == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] granted in
                DispatchQueue.main.async {
                    self?.start()
                }
            })
            return
        }
        setupSession()
    }
    public func start() {
        guard authStatus == .authorized else {
            if authStatus == .denied, let settingURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingURL, options: [:], completionHandler: nil)
            }
            return
        }
        setupSession()
        startSession()
    }
    public func stop() {
        stopSession()
    }
}

// MARK: - AVCaptureSession methods
extension ScanControl {
    private func setupSession() {
        guard session.isRunning == false,
              session.inputs.count == 0 else {  // inputs 이 있으면 이미 설정되었기 때문에 configure 를 수행하지 않음
            return
        }
        sessionQueue.async {
            self.configureSession()
        }
    }
    private func configureSession() {
        session.beginConfiguration()
        removeDevices()
        
        guard addVideoDeviceInput() else {
            isFailedCamera = true
            session.commitConfiguration()
            print("[Scanner] Could not add video device input to the session")
            return
        }
        print("[Scanner] addInput success")
        
        guard addVideoDataOutput() else {
            isFailedCamera = true
            session.commitConfiguration()
            print("[Scanner] 🛑 Could not add videodata output to the session")
            return
        }
        print("[Scanner] addOutput success")
        
        session.commitConfiguration()
    }
    private func removeDevices() {
        for input in session.inputs {
            session.removeInput(input)
        }
        for output in session.outputs {
            if let videoOutput = output as? AVCaptureVideoDataOutput {
                videoOutput.setSampleBufferDelegate(nil, queue: nil)
            }
            session.removeOutput(output)
        }
    }
    private func addVideoDeviceInput() -> Bool {
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            return false
        }
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(videoDeviceInput) {
                session.sessionPreset = .hd1280x720
                session.addInput(videoDeviceInput)
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    private func addVideoDataOutput() -> Bool {
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(self, queue: videoDataQueue)
            // videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.connection(with: .video)?.videoOrientation = .portrait
            return true
        }
        return false
    }
    private func startSession() {
        guard session.isRunning == false else { return }
        
        DispatchQueue.main.async {
            if self.previewLayer.superlayer == nil {
                self.scannerView.layer.addSublayer(self.previewLayer)
            }
            self.previewLayer.opacity = 0
        }
        
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.isFailedCamera == true {
//                    self.didFail?(CustomError(code: "SCAN_CAMERA_ERROR", message: "스캐너 초기화에 실패하였습니다. 다시 시도해주세요."))
                    self.didFail?(.camera)
                    
                    print("[Scanner] startRunning failed")
                } else if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                    self.session.startRunning()
                    UIView.animate(withDuration: 0.3) {
                        self.previewLayer.opacity = 1
                    }
                    print("[Scanner] startRunning")
                }
            }
        }
    }
    private func stopSession() {
        guard session.isRunning else { return }
        
        sessionQueue.async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.previewLayer.opacity = 0
            }
            print("[Scanner] stopRunning")
        }
    }
    
//    private func addMetaDataOutput() -> Bool {
//        if session.canAddOutput(metadataOutput) {
//            session.addOutput(metadataOutput)
//            metadataOutput.setMetadataObjectsDelegate(self, queue: videoDataQueue)
//            metadataOutput.metadataObjectTypes = [.qr, .dataMatrix]
//            Log.verbose("[Lens] addOutput success")
//            return true
//        }
//        return false
//    }
}

extension ScanControl: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard shouldScan, let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        shouldScan = false
        currentBuffer = pixelBuffer
        detectBarcode()
    }
    private func detectBarcode() {
        guard let pixelBuffer = currentBuffer else { return }
        
        let requests = [barcodeDetectionRequest]
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up)
        visionQueue.async {
            do {
                // defer { self.currentBuffer = nil }
                try requestHandler.perform(requests)
            } catch {
                print("[Scanner] Vision request failed with error \(error)")
            }
        }
    }
    private func processBarcode(observation: VNBarcodeObservation) {
        DispatchQueue.main.async {
            self.didDetect?(observation.payloadStringValue, self.capturedImage(), observation.symbology)
        }
    }
    private func capturedImage() -> UIImage? {
        guard let pixelBuffer = currentBuffer else { return nil }
        var image: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)
        
        guard let cgImage = image else { return nil }
        return UIImage(cgImage: cgImage)
    }
}
