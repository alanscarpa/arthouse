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
    let sizes: String
    let price: String
    let tags: String
    let link: String
    let popularity: CGFloat

    enum CodingKeys: String, CodingKey {
        case name = "NAME"
        case image = "FIREBASE-STORAGE-URL"
        case sizes = "SIZES"
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
            let sizeArray = artwork.sizes.components(separatedBy: ",")
            let tagsArray = artwork.tags.lowercased().replacingOccurrences(of: " ", with: "").components(separatedBy: ",")

            // For now, we will just take the first price because
            // we aren't displaying price. Maybe in the future we will
            // do something with the whole array.
            let pricesArray = artwork.price.components(separatedBy: ",")
            let price = CGFloat(exactly: NumberFormatter().number(from: pricesArray[0]) ?? 0) ?? 0

            let constructedArtwork = Artwork(id: "0", title: artwork.name, depth: 1, price: price, buyURLString: buyURLString, imageURLString: artwork.image, category: category, popularity: artwork.popularity, tags: tagsArray, sizes: sizeArray)
            constructedArtworks.append(constructedArtwork)
        }
        return constructedArtworks
    }
}

class Artwork {
    let id: String
    let title: String
    let depth: CGFloat
    let price: CGFloat
    var imageURLString: String
    let buyURLString: String
    var image: UIImage?
    var category: Category
    let popularity: CGFloat
    let tags: [String]
    let sizes: [String]

    var sizeIsInFeet: Bool {
        switch category {
        case .framedPrints, .posters, .prints, .wallHanging, .wallTapestry:
            return false
        case .woodWallArt:
            return true
        }
    }

    enum Category: String {
        case framedPrints = "framed-prints"
        case posters
        case prints
        case woodWallArt = "wood-wall-art"
        case wallTapestry = "wall-tapestry"
        case wallHanging = "wall-hangings"
    }
    
    private enum Keys: String {
        case title
        case depth
        case price
        case buyURLString = "buy-URL-string"
        case imageURLString = "image-URL-string"
        case category
        case popularity
        case tags
        case sizes
    }
    
    var dictionary: [String: Any] {
        return [
            Keys.title.rawValue: title,
            Keys.depth.rawValue: depth,
            Keys.price.rawValue: price,
            Keys.buyURLString.rawValue: buyURLString,
            Keys.imageURLString.rawValue: imageURLString,
            Keys.category.rawValue: category.rawValue,
            Keys.popularity.rawValue: popularity,
            Keys.tags.rawValue: tags,
            Keys.sizes.rawValue: sizes
        ]
    }

    init(id: String, title: String, depth: CGFloat, price: CGFloat, buyURLString: String, imageURLString: String, category: Category, popularity: CGFloat, tags: [String], sizes: [String]) {
        self.id = id
        self.title = title
        self.depth = depth
        self.price = price
        self.buyURLString = buyURLString
        self.imageURLString = imageURLString
        self.category = category
        self.popularity = popularity
        self.tags = tags
        self.sizes = sizes
    }
    
    init(with dictionary: Dictionary<String, Any>, id: String) {
        self.id = id
        title = dictionary[Keys.title.rawValue] as? String ?? ""
        depth = dictionary[Keys.depth.rawValue] as? CGFloat ?? 0
        price = dictionary[Keys.price.rawValue] as? CGFloat ?? 0
        buyURLString = dictionary[Keys.buyURLString.rawValue] as? String ?? ""
        imageURLString = dictionary[Keys.imageURLString.rawValue] as? String ?? ""
        category = Category(rawValue: dictionary[Keys.category.rawValue] as? String ?? "") ?? .prints
        popularity = dictionary[Keys.popularity.rawValue] as? CGFloat ?? 0
        tags = dictionary[Keys.tags.rawValue] as? [String] ?? [String]()
        sizes = dictionary[Keys.sizes.rawValue] as? [String] ?? [String]()
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

    var subtitle: String {
        switch self {
        case .framedPrints:
            return "Eco-friendly and minimalistic frames provide a natural warmth to complement your favorite piece of art."
        case .posters:
            return "Banish those blank walls. Posters are the most convenient way to bring rad art to your space."
        case .prints:
            return "Mix and match your favorite art prints on a gallery wall showcasing everything that makes your style unique."
        case .wallHanging:
            return "Crafted from yarns in varying textures and patterns, these are a unique and easy-to-hang alternative to the standard tapestry."
        case .wallTapestry:
            return "Wall tapestries truly can do it all. Lightweight to hang on the wall, durable to use as a tablecloth and vivid colors make it an eye-catching picnic blanket."
        case .woodWallArt:
            return "With this stylish, multi-square design, you have the power to adjust the spacing between each section to form exactly the right look."
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
