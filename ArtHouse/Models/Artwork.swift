//
//  Artwork.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/2/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

extension Artwork.Category: CaseIterable {}

struct Artwork {
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
        case wallHanging = "wall-hangings"
        case wallMurals = "wall-murals"
        case woodWallArt = "wood-wall-art"
        case posters
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

    init(title: String, height: CGFloat, width: CGFloat, depth: CGFloat, price: CGFloat, buyURLString: String, imageURLString: String, category: Category, popularity: CGFloat) {
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
    
    init(with dictionary: Dictionary<String, Any>) {
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
