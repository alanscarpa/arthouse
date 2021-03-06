//
//  HomeCollectionViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseAnalytics

class HomeCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        Auth.auth().signInAnonymously() { user, error in
            guard user != nil else { print(error?.localizedDescription ?? ""); return }
            // RUN AN UPLOAD FOR ARTWORK THEN COMMENT OUT
            // Uploader.uploadArtwork()
        }
        setTitleImage()
        trackLoadForAnalytics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RootViewController.shared.showNavigationBar = true
    }
    
    // MARK: - Setup
    
    private func setTitleImage() {
        let imageView = UIImageView(image: UIImage(named: "title-image-4"))
        imageView.contentMode = .scaleAspectFit
        navigationItem.titleView = imageView
    }
    
    private func setUpCollectionView() {
        collectionView.registerCell(HomeCollectionViewCell.self)
        let backgroundView = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.ahLightBlue.cgColor]
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        collectionView.backgroundView = backgroundView
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Artwork.Category.allCases.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(with: HomeCollectionViewCell.self, for: indexPath)
        cell.setUpForCategory(Artwork.Category.allCases[indexPath.row])
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        RootViewController.shared.presentArtworkVCWithCategory(Artwork.Category.allCases[indexPath.row])
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 500)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    // MARK: - Analytics

    private func trackLoadForAnalytics() {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: "id-\(HomeCollectionViewController.className)",
            AnalyticsParameterItemName: HomeCollectionViewController.className
        ])
    }

}
