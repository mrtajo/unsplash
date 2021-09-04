//
//  ScannerViewModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Foundation
import Combine

class ScannerViewModel {
    
    // MARK: - command (Published)
    /// ScannerViewModel 의 command interface
    /// 스캐너(카메라)를 초기화 하고, 스캐너(카메라)를 시작하고, 스캐너(카메라)를 중지합니다.
    @Published var command: ScanCommand = .none
    enum ScanCommand {
        case none
        case setup
        case start
        case stop
    }
    
    // MARK: - result (Published)
    /// 코드 스캔 결과를 Result 로 반환합니다
    @Published var result: Result<ScanResult, Error> = .success(.initial)
    enum ScanResult {
        case initial
        case domain(url: URL, inWebView: Bool, type: String)
        case none
    }
    
    // MARK: - scanControl (Published)
    /// scanControl 은 카메라 화면을 제공하기 위해 UIControl 로 구현되었지만
    /// 캡쳐링 된 이미지를 읽어 문자열을 추출하고, 어떤 문자열인지 분류하는 로직을 수행하는 컨트롤 입니다.
    /// UI 가 있지만 로직 모듈로서 viewModel 에 속하도록 구현했습니다.
    /// scanControl 을 publish 하는 이유는, 뷰컨에서 이를 받아 스캐너 영역에 붙여야 하기 때문입니다.
    @Published private(set) var scanControl: ScanControlable? = nil
    
    // MARK: - shouldScan
    /// 카메라 구동 상태에서 스캐닝 가능 여부를 확인하고 설정합니다
    var shouldScan: Bool {
        get { scanControl?.shouldScan == true }
        set {
            print("[Scanner] scanControl shouldScan \(newValue)")
            scanControl?.shouldScan = newValue
        }
    }
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        $command
            .sink { [weak self] command in
                switch command {
                case .setup:
                    self?.setupScanControl()
                case .start:
                    self?.scanControl?.start()
                case .stop:
                    self?.scanControl?.stop()
                default:
                    break
                }
            }
            .store(in: &cancellable)
    }
    
    private func setupScanControl() {
        // 스캔 컨트롤을 생성하고, scanControl 로 publish 합니다
        scanControl = ScanControl.instantiate()
        
        // 스캔 컨트롤이 탐지한 문자열, 캡처링한 이미지, code 종류를 반환하여 분류할 수 있도록 제공합니다
        scanControl?.didDetect = { [weak self] (string, image, symbology) in
            let qrcodeResult = ScanModel.QRCodeResult(payloadString: string, image: image, symbology: symbology)
            guard let _ = qrcodeResult.text else {
                self?.scanControl?.shouldScan = true
                return
            }
            print("[Scanner] didDetect")
            self?.readQRCodeResult(qrcodeResult)
        }
        // 스캔 컨트롤이 오류를 반환하는 경우는 주로 카메라 초기화에 실패하는 경우입니다
        scanControl?.didFail = { [weak self] (error) in
            self?.callbackError(error)
        }
        // 스캔 컨트롤을 초기화 합니다. 위의 callback closure 연결 후 수행되어야 합니다.
        scanControl?.setup()
    }
    
    private func readQRCodeResult(_ result: ScanModel.QRCodeResult) {
        guard let string = result.text, isDomainCode(from: string) else {
            callbackNone()
            return
        }
        callbackDomain(string)
    }
    
    private func isDomainCode(from string: String) -> Bool {
        guard let url = URL(string: string),
              let scheme = url.scheme, (scheme == "http" || scheme == "https") else { return false }
        return true
    }
    private func callbackDomain(_ domain: String) {
        guard let url = URL(string: domain) else {
            scanControl?.shouldScan = true
            return
        }
        // Scanner.Action.stopScan(withTransition: false)
        // result = .success(.domain(url: url, inWebView: domain.shouldPresentInWebView, type: domain.scanType))
    }
    private func callbackNone() {
        // Scanner.Action.stopScan()
        result = .success(.none)
    }
    private func callbackError(_ error: ScanError?) {
        guard let error = error else { return }
        print("[Scanner] didFail")
        // Scanner.Action.stopScan()
        result = .failure(error)
    }
}
