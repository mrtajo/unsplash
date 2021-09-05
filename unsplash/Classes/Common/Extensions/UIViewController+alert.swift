//
//  UIViewController+alert.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/05.
//

import UIKit

extension UIViewController {
    func alert(title: String? = nil, message: String?, buttonTitles: [String] = ["확인"], completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for (index, title) in buttonTitles.enumerated() {
            let action = UIAlertAction(title: title, style: index == 0 ? .cancel : .default, handler: completion)
            alertController.addAction(action)
        }
        self.present(alertController, animated: true)
    }
}
