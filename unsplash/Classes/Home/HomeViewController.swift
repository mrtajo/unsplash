//
//  HomeViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    private let networkClient = NetworkClient()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    
    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Setups
    private func setup() {
        networkClient.request(urlString: "https://api.unsplash.com/photos") { (result: Result<[Photo], NetworkError>) in
            print(result)
        }
    }

}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    
}
