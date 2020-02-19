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
import Photos

class ArtworkCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ArtworkCollectionViewCellDelegate {
    
    var category: Artwork.Category?
    private var artworks = [Artwork]()
    private var lastDocument: DocumentSnapshot?
    private var isDownloadingArtwork = false
    private var fetchLimit = 20

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
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func downloadArtwork() {
        guard isDownloadingArtwork == false else { return }
        guard let category = category?.rawValue else { return }

        let db = Firestore.firestore()
        var query = db.collection(category).limit(to: fetchLimit).order(by: "popularity")
        if let lastDocument = lastDocument {
            query = query.start(afterDocument: lastDocument)
        }

        isDownloadingArtwork = true
        query.getDocuments { [weak self] querySnapshot, error in
            defer { self?.isDownloadingArtwork = false }
            guard error == nil, let self = self, let snapshot = querySnapshot else {
                print(error?.localizedDescription ?? "Something went wrong. :(");
                return
            }
            guard !snapshot.documents.isEmpty else {
                print("No more additional documents!")
                return
            }
            for document in snapshot.documents {
                let artwork = Artwork(with: document.data(), id: document.documentID)
                if !artwork.imageURLString.isEmpty {
                    self.artworks.append(artwork)
                }
            }
            self.artworks.sort(by: { $0.popularity < $1.popularity })
            self.lastDocument = snapshot.documents.last
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

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == Int(Double(artworks.count) * 0.8) {
            downloadArtwork()
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard artworks[indexPath.row].image != nil else { return }
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized || AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            RootViewController.shared.presentARVCWithArtwork(artworks[indexPath.row])
        } else {
            let alertVC = UIAlertController.simpleAlert(withTitle: "Please enable camera access", message: "Go to settings and allow camera access in order to use ArtHouse.")
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 2, height: 250)
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
