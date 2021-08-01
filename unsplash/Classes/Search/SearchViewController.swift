//
//  SearchViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import UIKit

class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search User"
        navigationItem.titleView = searchBar
    }

}
