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
    
    var dictionary: [String: Any] {
        return [
            "title": title,
            "height": height,
            "width": width,
            "depth": depth,
            "image-URL-string": imageURLString
        ]
    }
}
