//
//  WebViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/10.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    // MARK: - Properties
    var urlString: String? = nil {
        didSet { loadRequest() }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var webView: WKWebView!
    
    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        urlString = "https://m.naver.com"
    }
    
    // MARK: - Setups
    private func setup() {
        let searchBar = UISearchBar()
        searchBar.placeholder = "웹 사이트 주소 입력"
        navigationItem.titleView = searchBar
    }
    
    // MARK: - Privates
    private func loadRequest() {
        guard let string = urlString, let url = URL(string: string) else { return }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 30
        
        webView.load(request)
    }
}
