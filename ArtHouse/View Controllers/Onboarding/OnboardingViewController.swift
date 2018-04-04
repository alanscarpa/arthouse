//
//  OnboardingViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/3/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import paper_onboarding
import AVFoundation
import AVKit

class OnboardingViewController: UIViewController, PaperOnboardingDelegate, PaperOnboardingDataSource {
    
    private static let titleFont = UIFont(name: "Nunito-Bold", size: 36.0) ?? UIFont.boldSystemFont(ofSize: 20.0)
    private static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 14.0) ?? UIFont.systemFont(ofSize: 14.0)
    var avPlayer: AVPlayer!
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "ed.jpg")!,
                           title: "Enable Your Camera",
                           description: "To see what your new artwork will look like on your walls, we need you to enable your camera permissions.",
                           pageIcon: UIImage(named: "ed.jpg")!,
                           color: UIColor.ahPrimaryBlue,
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(named: "ed.jpg")!,
                           title: "Choose Some Awesome Artwork",
                           description: "We source amazing, affordable art from all over the world.  Browse our collection and pick any pieces that catch your eye!",
                           pageIcon: UIImage(named: "ed.jpg")!,
                           color: UIColor(red: 0.40, green: 0.69, blue: 0.71, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(named: "ed.jpg")!,
                           title: "Stand 3 - 5 Feet From Your Wall",
                           description: "Standing a few feet from your wall will give you an accurate idea of how big the artwork will look on your wall.",
                           pageIcon: UIImage(named: "ed.jpg")!,
                           color: UIColor(red: 0.61, green: 0.56, blue: 0.74, alpha: 1.00),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
        
        ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaperOnboardingView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        // Add constraints
        for attribute: NSLayoutAttribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
    
    // MARK: - PaperOnboardingDelegate
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        //skipButton.isHidden = index == 2 ? false : true
    }
    
    func onboardingDidTransitonToIndex(_: Int) {
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        item.titleLabel?.numberOfLines = 0
        guard index + 1 == items.count else { return }
        let filepath: String? = Bundle.main.path(forResource: "sampleVideo", ofType: "mp4")
        let fileURL = URL.init(fileURLWithPath: filepath!)
        avPlayer = AVPlayer(url: fileURL)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { notification in
            self.avPlayer.seek(to: kCMTimeZero)
            self.avPlayer.play()
        }
        let avPlayerController = AVPlayerViewController()
        avPlayerController.view.clipsToBounds = true
        avPlayerController.player = avPlayer
        avPlayerController.view.frame = item.imageView!.frame
        avPlayerController.view.frame.origin.y = item.imageView!.frame.origin.y - 125
        avPlayerController.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
        avPlayerController.showsPlaybackControls = false
        avPlayerController.player?.play()
        item.addSubview(avPlayerController.view)
        item.imageView!.alpha = 0
    }
    
    // MARK: - PaperonboardingDataSource
    
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        let item = items[index]
        return item
    }
    
    func onboardingItemsCount() -> Int {
        return 3
    }
    
    //    func onboardinPageItemRadius() -> CGFloat {
    //        return 2
    //    }
    //
    //    func onboardingPageItemSelectedRadius() -> CGFloat {
    //        return 10
    //    }
    //    func onboardingPageItemColor(at index: Int) -> UIColor {
    //        return [UIColor.white, UIColor.red, UIColor.green][index]
    //    }
    
}

