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
        
        /// STEP 1 - CHANGE THIS
        let category = Artwork.Category.posters
        
        /// STEP 2 - ADD ALL ARTWORK HERE
        /// Most popular = 0
        
        /// STEP 3 - CAN ENTER THE SAME ID, IT IS NOT UPLOAD, ONLY CREATED WHEN DOWNLOADED
        let arts: [Artwork] = [Artwork]()

        Artwork(with: Dictionary<String, Any>, id: <#T##String#>)

        for art in arts {
            let db = Firestore.firestore()
            let settings = db.settings
            settings.areTimestampsInSnapshotsEnabled = true
            db.settings = settings
            let collection = db.collection(category.rawValue)
            collection.addDocument(data: art.dictionary)
        }
    }
}
