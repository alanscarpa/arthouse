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

//Indigo Mountains
//https://society6.com/product/indigo-mountains894310_framed-print?curator=thescarpagroup
//10x12
//44.99


class Uploader {
    static func uploadArtwork() {

        /// STEP 0 - Get .csv sheet for category and remove all duplicates!
        
        /// STEP 1 - CHANGE THIS
        let category = Artwork.Category.posters
        
        /// STEP 2 - ADD ALL ARTWORK HERE
        /// Most popular = 0
        
        /// STEP 3 - CAN ENTER THE SAME ID, IT IS NOT UPLOAD, ONLY CREATED WHEN DOWNLOADED

        /// STEP 4 - CHANGE FILE NAME
        let arts: [Artwork] = ArtworkFromJSON.artworkFromJSON(filename: "posters", category: .posters)

        let db = Firestore.firestore()
        let collection = db.collection(category.rawValue)

        for art in arts {
            print(art.imageURLString)
            Storage.storage().reference(forURL: art.imageURLString).downloadURL { (url, error) in
                art.imageURLString = url?.absoluteString ?? ""
                collection.addDocument(data: art.dictionary)
            }
        }
    }
}
