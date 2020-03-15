//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/12/19.
//  Copyright © 2019 The Scarpa Group. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    override func prepareForReuse() {
        categoryTitleLabel.text = nil
        categoryImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        categoryTitleLabel.backgroundColor = .ahPrimaryBlue
        categoryTitleLabel.roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        categoryImageView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner])
        
    }
    
    func setUpForCategory(_ category: Artwork.Category) {
        categoryTitleLabel.text = category.title
        categoryImageView.image = category.image
    }

}
