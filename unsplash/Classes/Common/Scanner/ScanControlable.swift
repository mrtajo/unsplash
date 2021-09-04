//
//  ScanControlable.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Vision
import UIKit

protocol ScanControlable: AnyObject {
    // Required
    var didDetect: ((String?, UIImage?, VNBarcodeSymbology) -> Void)? { get set }
    var didFail: ((ScanError?) -> Void)? { get set }
    
    // 스캐너 준비
    func setup()
    // 스캐너 활성화 (카메라 시작)
    func start()
    // 스캐너 비활성화 (카메라 정지)
    func stop()
    
    // 스캐너 detect 상태를 설정 (롱플중에만 true)
    var shouldScan: Bool { get set }
}
