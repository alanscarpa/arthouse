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
        let arts: [Artwork] = [
            Artwork(title: "butts", height: 8, width: 8, depth: 2, price: 30.99, buyURLString: "https://society6.com/product/butts-e5e_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F3.png?alt=media&token=a2957999-a957-4642-a505-a700c1cbcc69", category: .print),
            Artwork(title: "lola", height: 7, width: 10, depth: 2, price: 27.99, buyURLString: "https://society6.com/product/lola126331_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F4.png?alt=media&token=c8c30b7d-8a4e-4db5-bd44-86d4dceb9a38", category: .print),
            Artwork(title: "Shape study #16", height: 10, width: 8, depth: 2, price: 20.99, buyURLString: "https://society6.com/product/shape-study-16-inside-out-collection_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F5.png?alt=media&token=c810c557-1253-45b5-8650-cb0c4a9cd122", category: .print),
            Artwork(title: "Advice", height: 8, width: 8, depth: 2, price: 26.99, buyURLString: "https://society6.com/product/advice1066368_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F6.png?alt=media&token=374807f1-f227-4418-afd7-4a2e1c198a15", category: .print),
            Artwork(title: "Orange", height: 19, width: 8, depth: 2, price: 22.19, buyURLString: "https://society6.com/product/orange1301496_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F7.png?alt=media&token=586fadbf-e4f5-4012-958a-94d859ccce8c", category: .print),
            Artwork(title: "Jungle Panther", height: 8, width: 8, depth: 2, price: 18.99, buyURLString: "https://society6.com/product/jungle-panther920027_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F8.png?alt=media&token=48da0957-0b9c-400d-badc-556f6b9ab765", category: .print),
            Artwork(title: "Rise", height: 10, width: 8, depth: 2, price: 46.99, buyURLString: "https://society6.com/product/rise1404038_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F9.png?alt=media&token=d38172bc-115e-477f-a80d-de3bb2e46104", category: .print),
            Artwork(title: "LILY POND LANE", height: 8, width: 8, depth: 2, price: 27.99, buyURLString: "https://society6.com/product/lily-pond-lane_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F10.png?alt=media&token=82fe4e3c-6e68-4ab3-980f-c4be305aaa31", category: .print),
            Artwork(title: "Indigo Mountains", height: 8, width: 8, depth: 2, price: 22.99, buyURLString: "https://society6.com/product/indigo-mountains894310_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F11.png?alt=media&token=834c0a9c-c957-4699-a10e-31d596262f10", category: .print),
            Artwork(title: "Let The Sunshine In", height: 8, width: 9, depth: 2, price: 23.99, buyURLString: "https://society6.com/product/let-the-sunshine-in1513559_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F12.png?alt=media&token=778c0e4e-9ee8-498b-95d0-a6c0cb772b35", category: .print),
            Artwork(title: "Close on white", height: 10, width: 8, depth: 2, price: 33.99, buyURLString: "https://society6.com/product/clos-on-white_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F13.png?alt=media&token=7241bc1f-4bce-49ff-a08d-59f8233b2f76", category: .print),
            Artwork(title: "Life quote F. Scott Fitzgerald", height: 8, width: 8, depth: 2, price: 27.99, buyURLString: "https://society6.com/product/life-quote-f-scott-fitzgerald_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F14.png?alt=media&token=b1db242e-d654-4c65-814a-8197ac640366", category: .print),
            Artwork(title: "Yellow Cosmos Flower", height: 10, width: 8, depth: 2, price: 21.99, buyURLString: "https://society6.com/product/yellow-cosmos-flowers_print?curator=thescarpagroup", imageURLString: "https://firebasestorage.googleapis.com/v0/b/arthouse-571c6.appspot.com/o/art-images%2F15.png?alt=media&token=73c64807-788b-438e-a81d-6f9e5b579ebf", category: .print)]
        
        for art in arts {
            let collection = Firestore.firestore().collection("prints")
            collection.addDocument(data: art.dictionary)
        }
    }
}
