//
//  HomePhotoCell.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import UIKit

class HomePhotoCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var viewModel: HomePhotoCellViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            viewModel.image.bind { [weak self] image in
                self?.photoImageView.image = image
            }
            viewModel.setup()

            backgroundColor = viewModel.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
