//
//  HomeViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    let viewModel = HomeViewModel()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        binds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPhotos()
    }
    
    // MARK: - Setups
    private func binds() {
        viewModel.photos.bind { photos in
            guard photos.count > 0 else { return }
            print(photos)
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
