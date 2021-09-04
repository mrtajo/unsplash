//
//  ScanModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Foundation
import ZXingObjC
import Vision

struct ScanModel {
    struct QRCodeResult {
        let payload: String?
        let eucKr: String?
        let utf8: String?
        
        var text: String? {
            let string: String? = (payload != nil) ? payload! : ((eucKr != nil) ? eucKr! : utf8)
            return string?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        var hasZxingResult: Bool { return eucKr != nil || utf8 != nil }
        var symbology: VNBarcodeSymbology { return barcodeSymbology ?? .QR }
        private let barcodeSymbology: VNBarcodeSymbology?
        
        func convertEucKr(allowLossyConversion lossy: Bool = false) -> String? {
            guard let string = text,
                  let strData = string.data(using: .isoLatin1, allowLossyConversion: lossy) else { return nil }
            return String.init(data: strData, encoding: String.Encoding(rawValue: QRCodeResult.EUCKREncoding))
        }
        
        init(payloadString: String?, image: UIImage?, symbology: VNBarcodeSymbology) {
            payload = payloadString
            eucKr = QRCodeResult.decodeZXing(from: image, encoding: QRCodeResult.EUCKREncoding)
            utf8 = QRCodeResult.decodeZXing(from: image, encoding: QRCodeResult.UTF8Encoding)
            barcodeSymbology = symbology
        }
        
        static let UTF8Encoding: UInt = String.Encoding.utf8.rawValue
        static let EUCKREncoding: UInt = CFStringConvertEncodingToNSStringEncoding(0x0422)
        
        static func decodeZXing(from image: UIImage?, encoding: UInt) -> String? {
            guard let image = image else { return nil }
            
            let source = ZXCGImageLuminanceSource.init(cgImage: image.cgImage)
            let binarizer = ZXHybridBinarizer.init(source: source)
            let bitmap = ZXBinaryBitmap.init(binarizer: binarizer)
            let hints  = ZXDecodeHints.init()
            hints.encoding = encoding
            
            var resultStr: String? = nil
            
            do {
                let reader = ZXMultiFormatReader.reader() as! ZXMultiFormatReader
                let result = try reader.decode(bitmap, hints: hints)
                if result.text.isEmpty == false {
                    resultStr = result.text
                }
            } catch {
                print("[Scanner] decodeZXing Unexpected error: \(error)")
            }
            return resultStr
        }
    }
    
    
}
