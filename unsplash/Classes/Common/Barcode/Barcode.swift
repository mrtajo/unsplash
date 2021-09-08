//
//  Barcode.swift
//  unsplash
//
//  Created by mrtajo on 2021/07/13.
//

import UIKit

enum BarcodeError: Error {
    case filter
    case output
}

enum Barcode {
    typealias Filter = (CIImage) -> CIImage
    
    case QR(String)
    case Code128(String)
    
    func generate() -> UIImage? {  //-> Result<UIImage, BarcodeError> {
        switch self {
        case .QR(let string):
            let image = expand(scale: 10)(generate(string: string)(CIImage()))
            return UIImage(ciImage: image)
        case .Code128(let string):
            let image = expand(scale: 10)(generate(string: string)(CIImage()))
            return UIImage(ciImage: image)
        }
    }
    
    private func generate(string: String) -> Filter {
        return { _ in
            let data = string.data(using: encoding)
            
            guard let filter = CIFilter(name: filterName) else { fatalError() }
            filter.setValue(data, forKey: "inputMessage")
            
            guard let outputImage = filter.outputImage else { fatalError() }
            return outputImage
        }
    }
    
    private func expand(scale: CGFloat) -> Filter {
        return { image in
            return image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        }
    }
    
    private var filterName: String {
        switch self {
        case .QR: return "CIQRCodeGenerator"
        case .Code128: return "CICode128BarcodeGenerator" }
    }
    private var encoding: String.Encoding {
        switch self {
        case .QR: return String.Encoding.utf8
        case .Code128: return String.Encoding.ascii }
    }
}
