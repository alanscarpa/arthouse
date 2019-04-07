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
        
        /// STEP 1 - CHANGE THIS
        let category = Artwork.Category.wallHanging
        
        /// STEP 2 - ADD ALL ARTWORK HERE
        /// Most popular = 0
        
        /// STEP 3 - CAN ENTER THE SAME ID, IT IS NOT UPLOAD, ONLY CREATED WHEN DOWNLOADED
        let arts: [Artwork] = [
            ]
        for art in arts {
            let collection = Firestore.firestore().collection(category.rawValue)
            collection.addDocument(data: art.dictionary)
        }
    }
}
