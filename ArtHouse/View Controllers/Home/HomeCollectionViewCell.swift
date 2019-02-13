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
    
    func setUpForCategory(_ category: Artwork.Category) {
        categoryTitleLabel.text = category.rawValue
    }

}
