//
//  HomeCollectionViewCell.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import Kingfisher

protocol ArtworkCollectionViewCellDelegate: class {
    func imageDidLoad(image: UIImage, for artworkId: String)
}

class ArtworkCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var artImageView: UIImageView!
    @IBOutlet weak var artTitleLabel: UILabel!

    weak var delegate: ArtworkCollectionViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        artImageView.kf.indicatorType = .activity
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        artImageView.kf.cancelDownloadTask()
        artTitleLabel.text = nil
        artImageView.image = nil
    }
    
    func setUpWithArtwork(_ artwork: Artwork, delegate: ArtworkCollectionViewCellDelegate) {
        self.delegate = delegate
        artTitleLabel.text = artwork.title

        self.artImageView.kf.setImage(with: URL(string: artwork.imageURLString), options: [.transition(.fade(0.45))]) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                self.delegate?.imageDidLoad(image: value.image, for: artwork.id)
            case .failure(let error):
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    

}
