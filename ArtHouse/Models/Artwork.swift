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
    let height: Int
    let width: Int
    let depth: Int
    let imageURLString: String
    
    private enum Keys: String {
        case title
        case height
        case width
        case depth
        case imageURLString = "image-URL-string"
    }
    
    var dictionary: [String: Any] {
        return [
            Keys.title.rawValue: title,
            Keys.height.rawValue: height,
            Keys.width.rawValue: width,
            Keys.depth.rawValue: depth,
            Keys.imageURLString.rawValue: imageURLString
        ]
    }

    init(title: String, height: Int, width: Int, depth: Int, imageURLString: String ) {
        self.title = title
        self.height = height
        self.width = width
        self.depth = depth
        self.imageURLString = imageURLString
    }
    
    init(with dictionary: Dictionary<String, Any>) {
        title = dictionary[Keys.title.rawValue] as? String ?? ""
        height = dictionary[Keys.height.rawValue] as? Int ?? 0
        width = dictionary[Keys.width.rawValue] as? Int ?? 0
        depth = dictionary[Keys.depth.rawValue] as? Int ?? 0
        imageURLString = dictionary[Keys.imageURLString.rawValue] as? String ?? ""
    }
}
