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
        let category = Artwork.Category.woodWallArt
        
        /// STEP 2 - ADD ALL ARTWORK HERE
        /// Most popular = 0
        
        /// STEP 3 - CAN ENTER THE SAME ID, IT IS NOT UPLOAD, ONLY CREATED WHEN DOWNLOADED
        let arts: [Artwork] = [
            Artwork(id: "", title: "Mid Century Modern Geometric 04 Orange", height: 36, width: 36, depth: 1, price: 149.99, buyURLString: "https://society6.com/product/mid-century-modern-geometric-04-orange_wood-wall-art?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2Fwood-wall-art%2F1.png?alt=media&token=c89d01c0-35c4-4bec-b767-6a53792600cc", category: category, popularity: 1)]
        for art in arts {
            let collection = Firestore.firestore().collection(category.rawValue)
            collection.addDocument(data: art.dictionary)
        }
    }
}
