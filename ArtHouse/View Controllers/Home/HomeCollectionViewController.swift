//
//  HomeCollectionViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuthUI
import FirebaseStorage

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private var artworks = [Artwork]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        Auth.auth().signInAnonymously() { [weak self] user, error in
            guard user != nil, let self = self else { print(error?.localizedDescription ?? ""); return }
            // TODO: RUN AN UPLOAD FOR ARTWORK THEN COMMENT OUT
            //self.uploadArtwork()
            self.downloadArtwork()
        }
    }
    
    private func setUpCollectionView() {
        collectionView.registerCell(HomeCollectionViewCell.self)
    }
    
    private func downloadArtwork() {
        Firestore.firestore().collection("artwork").getDocuments() { [weak self] querySnapshot, error in
            guard error == nil, let self = self, let snapshot = querySnapshot else { print(error?.localizedDescription ?? "Something went wrong. :("); return }
            for document in snapshot.documents {
                self.artworks.append(Artwork(with: document.data()))
            }
            self.collectionView.reloadData()
        }
    }
    
    private func uploadArtwork() {
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworks.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: HomeCollectionViewCell.self, for: indexPath)
        cell.setUpWithArtwork(artworks[indexPath.row])
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        RootViewController.shared.presentARVC()
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 3, height: 250)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
