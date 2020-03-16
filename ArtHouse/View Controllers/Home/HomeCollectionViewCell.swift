//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/12/19.
//  Copyright © 2019 The Scarpa Group. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    @IBOutlet weak var chinView: UIView!
    
    override func prepareForReuse() {
        categoryTitleLabel.text = nil
        categoryImageView.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.round()
        chinView.roundCorners([.layerMaxXMaxYCorner, .layerMinXMaxYCorner])
        categoryImageView.roundCorners([.layerMaxXMinYCorner, .layerMinXMinYCorner])

        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.shadowOffset = .zero
        containerView.layer.shadowRadius = 8
        
    }
    
    func setUpForCategory(_ category: Artwork.Category) {
        categoryTitleLabel.text = category.title
        categoryImageView.image = category.image
    }

}
