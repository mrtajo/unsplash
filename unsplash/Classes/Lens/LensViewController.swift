//
//  LensViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Foundation
import UIKit

class LensViewController: UIViewController {
    
    private weak var scannerViewController: ScannerViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scannerViewController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerViewController?.stop()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ScannerViewController {
            scannerViewController = viewController
        }
    }
}
