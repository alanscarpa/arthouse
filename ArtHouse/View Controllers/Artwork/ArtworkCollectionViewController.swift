//
//  HomeCollectionViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import Photos
import FirebaseAnalytics

class ArtworkCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, ArtworkCollectionViewCellDelegate, SearchBarDelegate {
    
    var category: Artwork.Category?
    private var artworks = [Artwork]()
    private var lastDocument: DocumentSnapshot?
    private var isDownloadingArtwork = false
    private var fetchLimit = 50
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    private weak var searchBar: UISearchBar?

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        title = category?.title.capitalized
        navigationItem.setHidesBackButton(false, animated: false)

        // Show loading indicator on intiial load as it takes some time to download
        // the initial data for the initial cells.
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()

        trackLoadForAnalytics()

        self.downloadArtwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.shared.showNavigationBar = true
    }

    // MARK: - Setup
    
    private func setUpCollectionView() {
        collectionView.registerCell(ArtworkCollectionViewCell.self)
        collectionView.register(SearchBar.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
    }

    // MARK: - Get Data
    
    private func downloadArtwork(searchString: String? = nil, shouldEmptyCurrentResults: Bool = false) {
        guard isDownloadingArtwork == false else { return }
        guard let category = category?.rawValue else { return }

        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            if shouldEmptyCurrentResults {
                self.artworks = [Artwork]()
                // TODO: Show loading spinner
                self.lastDocument = nil
                self.collectionView.reloadData()
            }

            let db = Firestore.firestore()

            var query = db.collection(category).order(by: "popularity")

            if let lastDocument = self.lastDocument {
                query = query.start(afterDocument: lastDocument)
            }

            query = query.limit(to: self.fetchLimit)

            if let searchString = searchString, !searchString.isEmpty {
                query = query.whereField("tags", arrayContains: searchString.lowercased())
            }

            self.isDownloadingArtwork = true

            query.getDocuments { [weak self] querySnapshot, error in
                guard let self = self else { return }
                defer {
                    self.activityIndicatorView.stopAnimating()
                    self.isDownloadingArtwork = false
                }
                guard error == nil, let snapshot = querySnapshot else {
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
    }
    
    // MARK: UICollectionViewDataSource

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
            downloadArtwork(searchString: searchBar?.text)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let searchBar = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? SearchBar else { return UICollectionReusableView() }
        self.searchBar = searchBar.searchBar
        searchBar.delegate = self
        return searchBar
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

    // MARK: UIScrollViewDelegate

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 2, height: 325)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 65)
    }

    // MARK: - HomeCollectionViewCellDelegate
    
    func imageDidLoad(image: UIImage, for artworkId: String) {
        artworks.first(where: { $0.id == artworkId })?.image = image
    }

    // MARK: - SearchBarDelegate

    func didSearch(for query: String) {
        downloadArtwork(searchString: query, shouldEmptyCurrentResults: true)
    }

    // MARK: - Analytics

    private func trackLoadForAnalytics() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: "id-\(title ?? "")",
            AnalyticsParameterItemName: (title ?? "") + "Collection View"
        ])
    }

}
