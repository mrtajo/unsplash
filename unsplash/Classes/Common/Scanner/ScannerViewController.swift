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
        binds()
        setup() /// setup - 스캐너를 초기화 하면, $scanControl 이 published 되므로 binds 전에 setup 이 수행되면 안됨
    }
    
    // MARK: - Public methods
    public var shouldScan: Bool {
        get { viewModel.shouldScan }
        set { viewModel.shouldScan = newValue }
    }
    public func start() {
        viewModel.command = .start
        viewModel.shouldScan = true
        UIView.animate(withDuration: 0.2) {
            self.blurView.alpha = 0
        }
    }
    public func stop() {
        viewModel.command = .stop
        UIView.animate(withDuration: 0.2) {
            self.blurView.alpha = 1
        }
    }
    
    // MARK: - Setup methods
    private func binds() {
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
    }
    private func setup() {
        viewModel.command = .setup
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
        DispatchQueue.main.async {
            self.alert(message: "\(url.host ?? "알 수 없는 호스트") 를 여시겠습니까?", buttonTitles: ["취소", "열기"]) { [weak self] action in
                guard case action.style = UIAlertAction.Style.default else {
                    self?.shouldScan = true
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    private func presentNone() {
        DispatchQueue.main.async {
            self.alert(message: "잘못된 코드입니다.\n정상적인 코드인지 확인 후 다시 시도해주세요.") { [weak self] _ in
                self?.shouldScan = true
            }
        }
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
        self.alert(message: error.message()) { [weak self] _ in
            self?.shouldScan = true
        }
        #endif
    }
}
