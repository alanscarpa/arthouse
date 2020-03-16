//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/12/19.
//  Copyright © 2019 The Scarpa Group. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var chinView: UIView!
    
    override func prepareForReuse() {
        categoryTitleLabel.text = nil
        categoryImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        chinView.roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        categoryImageView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner])

        chinView.layer.masksToBounds = false
        chinView.layer.shadowColor = UIColor.black.cgColor
        chinView.layer.shadowOpacity = 0.3
        chinView.layer.shadowOffset = CGSize(width: 0, height: 3)
        chinView.layer.shadowRadius = 2
        
    }
    
    func setUpForCategory(_ category: Artwork.Category) {
        categoryTitleLabel.text = category.title
        categoryImageView.image = category.image
    }

}
