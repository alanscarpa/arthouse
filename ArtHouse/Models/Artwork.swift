//
//  Artwork.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/2/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

extension Artwork.Category: CaseIterable {
    
    var title: String {
        switch self {
        case .framedPrints:
            return "Framed Prints"
        case .posters:
            return "Posters"
        case .prints:
            return "Prints"
        case .wallHanging:
            return "Wall Hangings"
        case .wallTapestry:
            return "Tapestry"
        case .woodWallArt:
            return "Wood Wall Art"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .framedPrints:
            return UIImage(named: "framed")
        case .posters:
            return UIImage(named: "poster")
        case .prints:
            return UIImage(named: "prints")
        case .wallHanging:
            return UIImage(named: "wall-hanging")
        case .wallTapestry:
            return UIImage(named: "wall-tapestry")
        case .woodWallArt:
            return UIImage(named: "wood")
        }
    }
}

class Artwork {
    let id: String
    let title: String
    let height: CGFloat
    let width: CGFloat
    let depth: CGFloat
    let price: CGFloat
    var imageURLString: String
    let buyURLString: String
    var image: UIImage?
    var category: Category
    let popularity: CGFloat
    
    enum Category: String {
        case prints
        case framedPrints = "framed-prints"
        case wallTapestry = "wall-tapestry"
        case posters
        case woodWallArt = "wood-wall-art"
        case wallHanging = "wall-hangings"
    }
    
    private enum Keys: String {
        case title
        case height
        case width
        case depth
        case price
        case buyURLString = "buy-URL-string"
        case imageURLString = "image-URL-string"
        case category
        case popularity
    }
    
    var dictionary: [String: Any] {
        return [
            Keys.title.rawValue: title,
            Keys.height.rawValue: height,
            Keys.width.rawValue: width,
            Keys.depth.rawValue: depth,
            Keys.price.rawValue: price,
            Keys.buyURLString.rawValue: buyURLString,
            Keys.imageURLString.rawValue: imageURLString,
            Keys.category.rawValue: category.rawValue,
            Keys.popularity.rawValue: popularity
        ]
    }

    init(id: String, title: String, height: CGFloat, width: CGFloat, depth: CGFloat, price: CGFloat, buyURLString: String, imageURLString: String, category: Category, popularity: CGFloat) {
        self.id = id
        self.title = title
        self.height = height
        self.width = width
        self.depth = depth
        self.price = price
        self.buyURLString = buyURLString
        self.imageURLString = imageURLString
        self.category = category
        self.popularity = popularity
    }
    
    init(with dictionary: Dictionary<String, Any>, id: String) {
        self.id = id
        title = dictionary[Keys.title.rawValue] as? String ?? ""
        height = dictionary[Keys.height.rawValue] as? CGFloat ?? 0
        width = dictionary[Keys.width.rawValue] as? CGFloat ?? 0
        depth = dictionary[Keys.depth.rawValue] as? CGFloat ?? 0
        price = dictionary[Keys.price.rawValue] as? CGFloat ?? 0
        buyURLString = dictionary[Keys.buyURLString.rawValue] as? String ?? ""
        imageURLString = dictionary[Keys.imageURLString.rawValue] as? String ?? ""
        category = Category(rawValue: dictionary[Keys.category.rawValue] as? String ?? "") ?? .prints
        popularity = dictionary[Keys.popularity.rawValue] as? CGFloat ?? 0
    }
}
