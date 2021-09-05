//
//  HomeViewController.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import UIKit

class HomeViewController: UIViewController {
    // MARK: - Properties
    var viewModel = HomeViewModel()
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        binds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPhotos()
    }
    
    // MARK: - Setups
    private func setup() {
        title = "Unsplash"
    }
    private func binds() {
        viewModel.photos.bind { [weak self] photos in
            guard photos.count > 0 else { return }
            self?.tableView.reloadData()
            self?.viewModel.shouldFetch = true
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.photos.value.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard viewModel.photos.value.indices ~= indexPath.row else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomePhotoCell", for: indexPath) as! HomePhotoCell
        cell.viewModel = viewModel.photos.value[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard viewModel.photos.value.indices ~= indexPath.row else {
            return 100
        }
        let photo = viewModel.photos.value[indexPath.row]
        let height = self.view.bounds.width * CGFloat(photo.height) / CGFloat(photo.width)
        return height
    }
}

extension HomeViewController: UITableViewDelegate {}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        if offsetY > (contentHeight - height) {
            viewModel.fetchPhotos()
        }
    }
}
