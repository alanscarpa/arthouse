//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import Kingfisher

protocol HomeCollectionViewCellDelegate: class {
    func artworkImageDidLoad(image: UIImage, sender: HomeCollectionViewCell)
}

class HomeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artTitleLabel: UILabel!
    @IBOutlet weak var artPriceLabel: UILabel!
    
    weak var delegate: HomeCollectionViewCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        artTitleLabel.text = nil
        artPriceLabel.text = nil
        artImageView.kf.cancelDownloadTask()
        artImageView.image = nil
    }
    
    func setUpWithArtwork(_ artwork: Artwork) {
        artTitleLabel.text = artwork.title
        artPriceLabel.text = "$\(artwork.price)"
        artImageView.kf.indicatorType = .activity
        artImageView.kf.setImage(with: URL(string: artwork.imageURLString), options: [.transition(.fade(0.5))]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.delegate?.artworkImageDidLoad(image: value.image, sender: self)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    

}
