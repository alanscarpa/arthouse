//
//  Artwork.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/2/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

struct Artwork {
    let title: String
    let height: CGFloat
    let width: CGFloat
    let depth: CGFloat
    let price: CGFloat
    let imageURLString: String
    var image: UIImage?
    
    private enum Keys: String {
        case title
        case height
        case width
        case depth
        case price
        case imageURLString = "image-URL-string"
    }
    
    var dictionary: [String: Any] {
        return [
            Keys.title.rawValue: title,
            Keys.height.rawValue: height,
            Keys.width.rawValue: width,
            Keys.depth.rawValue: depth,
            Keys.price.rawValue: price,
            Keys.imageURLString.rawValue: imageURLString
        ]
    }

    init(title: String, height: CGFloat, width: CGFloat, depth: CGFloat, price: CGFloat, imageURLString: String ) {
        self.title = title
        self.height = height
        self.width = width
        self.depth = depth
        self.price = price
        self.imageURLString = imageURLString
    }
    
    init(with dictionary: Dictionary<String, Any>) {
        title = dictionary[Keys.title.rawValue] as? String ?? ""
        height = dictionary[Keys.height.rawValue] as? CGFloat ?? 0
        width = dictionary[Keys.width.rawValue] as? CGFloat ?? 0
        depth = dictionary[Keys.depth.rawValue] as? CGFloat ?? 0
        price = dictionary[Keys.price.rawValue] as? CGFloat ?? 0
        imageURLString = dictionary[Keys.imageURLString.rawValue] as? String ?? ""
    }
}
