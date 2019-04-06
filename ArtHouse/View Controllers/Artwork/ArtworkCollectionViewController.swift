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

class ArtworkCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ArtworkCollectionViewCellDelegate {
    
    var category: Artwork.Category?
    private var artworks = [Artwork]()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        downloadArtwork()
        title = category?.title.capitalized
        navigationItem.setHidesBackButton(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.shared.showNavigationBar = true
    }
    
    private func setUpCollectionView() {
        collectionView.registerCell(ArtworkCollectionViewCell.self)
        collectionView.backgroundColor = .white
    }
    
    private func downloadArtwork() {
        guard let category = category?.rawValue else { return }
        Firestore.firestore().collection(category).getDocuments() { [weak self] querySnapshot, error in
            guard error == nil, let self = self, let snapshot = querySnapshot else { print(error?.localizedDescription ?? "Something went wrong. :("); return }
            for document in snapshot.documents {
                self.artworks.append(Artwork(with: document.data(), id: document.documentID))
            }
            self.artworks.sort(by: { $0.popularity < $1.popularity })
            self.collectionView.reloadData()
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return artworks.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: ArtworkCollectionViewCell.self, for: indexPath)
        cell.setUpWithArtwork(artworks[indexPath.row], delegate: self)
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard artworks[indexPath.row].image != nil else { return }
        RootViewController.shared.presentARVCWithArtwork(artworks[indexPath.row])
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
    
    // MARK: - HomeCollectionViewCellDelegate
    
    func imageDidLoad(image: UIImage, for artworkId: String) {
        artworks.first(where: { $0.id == artworkId })?.image = image
    }
    
}
