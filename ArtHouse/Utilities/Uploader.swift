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
        
        let artPieceTitle = "Art2"
        
        let storage = Storage.storage()
        let fileName = artPieceTitle
        let storageRef = storage.reference(forURL: "gs://arthouse-571c6.appspot.com")
        let fileRef = storageRef.child("art-images/\(fileName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let photoData = UIImage(named: "lawn")!.jpegData(compressionQuality: 0.9)
        
        fileRef.putData(photoData!, metadata: metadata) { metadata, error in
            guard error == nil else { print (error?.localizedDescription ?? ""); return }
            fileRef.downloadURL { url, error in
                guard error == nil else { print (error?.localizedDescription ?? ""); return }
                let collection = Firestore.firestore().collection("artwork")
                let artPiece = Artwork(title: artPieceTitle,
                                       height: 20,
                                       width: 10,
                                       depth: 2,
                                       price: 99.95,
                                       imageURLString: url?.absoluteString ?? "")
                collection.addDocument(data: artPiece.dictionary)
            }
        }
    }
}
