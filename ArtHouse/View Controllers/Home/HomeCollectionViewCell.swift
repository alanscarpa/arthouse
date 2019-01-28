//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import Kingfisher

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artTitleLabel: UILabel!
    @IBOutlet weak var artPriceLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artTitleLabel.text = nil
        artPriceLabel.text = nil
        artImageView.image = nil
    }
    
    func setUpWithArtwork(_ artwork: Artwork) {
        artTitleLabel.text = artwork.title
        artPriceLabel.text = "$\(artwork.price)"
        artImageView.kf.indicatorType = .activity
        artImageView.kf.setImage(with: URL(string: artwork.imageURLString), options: [.transition(.fade(0.2))])
    }
    

}
