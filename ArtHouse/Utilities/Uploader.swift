//
//  Uploader.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 1/27/19.
//  Copyright © 2019 The Scarpa Group. All rights reserved.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit

class Uploader {
    static func uploadArtwork() {

        /// STEP 0 - Get .csv sheet for category and remove all duplicates!
        
        /// STEP 1 - CHANGE THIS
        let category = Artwork.Category.framedPrints
        
        /// STEP 2 - ADD ALL ARTWORK HERE
        /// Most popular = 0
        
        /// STEP 3 - CAN ENTER THE SAME ID, IT IS NOT UPLOAD, ONLY CREATED WHEN DOWNLOADED

        /// STEP 4 - CHANGE FILE NAME
        let artworks: [Artwork] = ArtworkFromJSON.artworkFromJSON(filename: "framed-prints", category: category)

        let db = Firestore.firestore()
        let collection = db.collection(category.rawValue)

        for artwork in artworks {
            print(artwork.imageURLString)
            Storage.storage().reference(forURL: artwork.imageURLString).downloadURL { (url, error) in
                artwork.imageURLString = url?.absoluteString ?? ""
                collection.addDocument(data: artwork.dictionary)
            }
        }
    }
}
