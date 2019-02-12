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
//
//    Pinky Swear
//    https://society6.com/product/pinky-swear800336_print?curator=thescarpagroup
//    10 x 7
//    29.99
//
//    Clearly Sea
//    https://society6.com/product/clearly-sea_print?curator=thescarpagroup
//    8 x 10
//    27.99
//
//    butts
//    https://society6.com/product/butts-e5e_print?curator=thescarpagroup
//    8 X 8
//    30.99
//
//    lola
//    https://society6.com/product/lola126331_print?curator=thescarpagroup
//    10x7
//    27.99
//
//    Shape study #16 - Inside Out Collection
//    https://society6.com/product/shape-study-16-inside-out-collection_print?curator=thescarpagroup
//    8x10
//    20.99
//
//    Advice
//    https://society6.com/product/advice1066368_print?curator=thescarpagroup
//    8x8
//    26.99
//
//    Orange
//    https://society6.com/product/orange1301496_print?curator=thescarpagroup
//    8x19
//    22.19
//
//    Jungle Panther
//    https://society6.com/product/jungle-panther920027_print?curator=thescarpagroup
//    8x8
//    18.99
//
//    Rise
//    https://society6.com/product/rise1404038_print?curator=thescarpagroup
//    8x10
//    46.99
//
//    LILY POND LANE
//    https://society6.com/product/lily-pond-lane_print?curator=thescarpagroup
//    8x8
//    27.99
//
//    Indigo Mountains
//    https://society6.com/product/indigo-mountains894310_print?curator=thescarpagroup
//    8x8
//    22.99
//
//    Let The Sunshine In
//    https://society6.com/product/let-the-sunshine-in1513559_print?curator=thescarpagroup
//    9x8
//    23.99
//
//    Close on white
//    https://society6.com/product/clos-on-white_print?curator=thescarpagroup
//    8x10
//    33.99
//
//    Life quote F. Scott Fitzgerald
//    https://society6.com/product/life-quote-f-scott-fitzgerald_print?curator=thescarpagroup
//    8x8
//    23.99
//
//    Yellow Cosmos Flower
//    https://society6.com/product/yellow-cosmos-flowers_print?curator=thescarpagroup
//    8x10
//    21.99
    
    static func uploadArtwork() {
        
        /// Most popular = 0
        let arts: [Artwork] = [
            Artwork(title: "butts", height: 8, width: 8, depth: 2, price: 30.99, buyURLString: "https://society6.com/product/butts-e5e_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F3.png?alt=media&token=a2957999-a957-4642-a505-a700c1cbcc69", category: .print, popularity: 1)]
        
        for art in arts {
            let collection = Firestore.firestore().collection("prints")
            collection.addDocument(data: art.dictionary)
        }
    }
}
