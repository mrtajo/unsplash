//
//  LensViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/09/04.
//

import Foundation
import UIKit

class LensViewController: UIViewController {
    // MARK: - Properties
    private weak var scannerViewController: ScannerViewController?
    private var becomeActiveToken: NSObjectProtocol?
    private var resignActiveToken: NSObjectProtocol?
    
    // MARK: - Outlets
    @IBOutlet weak var qrcodeImageView: UIImageView!
    
    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        scannerViewController?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scannerViewController?.stop()
    }
    
    // MARK: - Setups
    private func setup() {
        becomeActiveToken = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil) { [weak self] _ in
            guard self?.tabBarController?.selectedIndex == 1 else { return }
            self?.scannerViewController?.start()
        }
        resignActiveToken = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil) { [weak self] _ in
            guard self?.tabBarController?.selectedIndex == 1 else { return }
            self?.scannerViewController?.stop()
        }
        
        guard let image = Barcode.QR("2938461929391342").generate() else { return }
        qrcodeImageView.image = image
    }
    
    // MARK: - Inits & deinit
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? ScannerViewController {
            scannerViewController = viewController
        }
    }
    
    deinit {
        if let token = becomeActiveToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = resignActiveToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}
