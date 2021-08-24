//
//  HomePhotoCell.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import UIKit

class HomePhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var viewModel: HomeViewModel.Photo? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            viewModel.image.bind { [weak self] image in
                self?.photoImageView.image = image
            }
            backgroundColor = viewModel.color
        }
    }
    
    override func prepareForReuse() {
        viewModel = nil
        photoImageView.image = nil
    }
}
