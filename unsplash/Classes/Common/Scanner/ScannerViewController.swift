//
//  ScannerViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import UIKit
import Vision
import Combine
import AVFoundation

class ScannerViewController: UIViewController {
    // MARK: - Properties
    private let viewModel = ScannerViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    // MARK: - Outlets
    @IBOutlet weak var scannerView: UIView!
    @IBOutlet weak var focusView: UIView!
    @IBOutlet weak var blurView: UIView!
    
    // MARK: - View lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// binds
        viewModel
            .$scanControl
            .sink { [weak self] control in
                guard let self = self, let control = control as? UIControl else { return }
                control.translatesAutoresizingMaskIntoConstraints = false
                self.scannerView.addSubview(control)
                NSLayoutConstraint.activate([
                    control.widthAnchor.constraint(equalTo: self.scannerView.widthAnchor),
                    control.heightAnchor.constraint(equalTo: self.scannerView.heightAnchor)
                ])
            }
            .store(in: &cancellable)
        viewModel
            .$result
            .sink { result in
                switch result {
                case .success(let scanResult):
                    self.processSuccess(scanResult)
                case .failure(let error):
                    self.processFailure(error)
                }
            }
            .store(in: &cancellable)
        
        /// setup - 스캐너를 초기화 하면, $scanControl 이 published 되므로 binds 전에 아래 명령이 수행되서는 안됨
        viewModel.command = .setup
    }
    
    // MARK: - Public methods
    public var shouldScan: Bool {
        get { viewModel.shouldScan }
        set { viewModel.shouldScan = newValue }
    }
    public func start() {
        viewModel.command = .start
    }
    public func stop() {
        viewModel.command = .stop
    }
    public func scaleFocusView(isScaleUp: Bool) {
        self.blurView.alpha = isScaleUp ? 1.0 : 0.0
        self.focusView.transform = isScaleUp ? CGAffineTransform(scaleX: 1.5, y: 1.5) : .identity
    }
}

// MARK: - Process viewModel success results
extension ScannerViewController {
    private func processSuccess(_ scanResult: ScannerViewModel.ScanResult) {
        if case .initial = scanResult { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(1102))
        
        switch scanResult {
        case .domain(let url, let inWebView, let type):
            self.presentDomain(url, inWebView, type)
        case .none:
            self.presentNone()
        default:
            break
        }
    }
    private func presentDomain(_ url: URL, _ inWebView: Bool, _ type: String) {
        // 도메인 링크의 경우 바텀시트 형태로 노출.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { // 스캐너 노출시 animation 타이밍을 보장하기 위하여
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    private func presentNone() {
//        let error = CustomError(code: "Invalid_Code", message: "잘못된 코드입니다. 정상적인 코드인지 확인 후 다시 시도해주세요.")
//        self.presentAlert(error: error)
    }
}

// MARK: - Process viewModel failure results
extension ScannerViewController {
    private func processFailure(_ error: Error) {
        guard let error = error as? ScanError else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        #if targetEnvironment(simulator)
        print("[Scanner] failure by simulator")
        #else
        // self.presentAlert(error: error)
        #endif
    }
}
