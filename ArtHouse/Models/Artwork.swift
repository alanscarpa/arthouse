//
//  Artwork.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/2/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

struct ArtworkFromJSON: Codable {
    let name: String
    let image: String
    let size: String
    let price: CGFloat
    let tags: String
    let link: String
    let popularity: CGFloat

    enum CodingKeys: String, CodingKey {
        case name = "NAME"
        case image = "FIREBASE-STORAGE-URL"
        case size = "SIZE"
        case price = "PRICE"
        case tags = "TAGS"
        case link = "LINK"
        case popularity = "POPULARITY"
    }

    // Since this is done manually, we want it to crash instead of
    // potentially populating our production DB with bad values.
    static func artworkFromJSON(filename: String, category: Artwork.Category) -> [Artwork] {
        let url = Bundle.main.url(forResource: filename, withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonData = try! decoder.decode([ArtworkFromJSON].self, from: data)
        return constructedArtworks(from: jsonData, category: category)
    }

    static func constructedArtworks(from artworks: [ArtworkFromJSON], category: Artwork.Category) -> [Artwork] {
        var constructedArtworks = [Artwork]()
        for artwork in artworks {
            let buyURLString = artwork.link + "&curator=thescarpagroup"
            let sizeArray = artwork.size.components(separatedBy: "X")
            let width = CGFloat(exactly: NumberFormatter().number(from: sizeArray[0])!)!
            let height = CGFloat(exactly: NumberFormatter().number(from: sizeArray[1])!)!
            let tagsArray = artwork.tags.components(separatedBy: ",")
            
            let constructedArtwork = Artwork(id: "0", title: artwork.name, height: height, width: width, depth: 1, price: artwork.price, buyURLString: buyURLString, imageURLString: artwork.image, category: category, popularity: artwork.popularity, tags: tagsArray)
            constructedArtworks.append(constructedArtwork)
        }
        return constructedArtworks
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
    let tags: [String]
    
    enum Category: String {
        case posters
        case prints
        case framedPrints = "framed-prints"
        case wallTapestry = "wall-tapestry"
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
        case tags
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
            Keys.popularity.rawValue: popularity,
            Keys.tags.rawValue: tags
        ]
    }

    init(id: String, title: String, height: CGFloat, width: CGFloat, depth: CGFloat, price: CGFloat, buyURLString: String, imageURLString: String, category: Category, popularity: CGFloat, tags: [String]) {
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
        self.tags = tags
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
        tags = dictionary[Keys.tags.rawValue] as? [String] ?? [String]()
    }
}

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
            return "Tapestries"
        case .woodWallArt:
            return "Wood Wall Art"
        }
    }

    var path: String {
        switch self {
        case .framedPrints:
            return "framed-prints"
        case .posters:
            return "posters"
        case .prints:
            return "prints"
        case .wallHanging:
            return "wall-hangings"
        case .wallTapestry:
            return "tapestries"
        case .woodWallArt:
            return "wood-wall-art"
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
