//
//  OnboardingViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/7/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

protocol OnboardingDelegate: class {
    func nextButtonTapped()
}

class OnboardingPageViewController: UIPageViewController, OnboardingDelegate {
    
    lazy var allViewControllers: [UIViewController] = {
        let enableVC = EnableCameraViewController()
        enableVC.delegate = self
        let chooseVC = ChooseArtworkViewController()
        chooseVC.delegate = self
        let positionYourselfVC = PositionYourselfViewController()
        positionYourselfVC.delegate = self
        return [enableVC, chooseVC, positionYourselfVC]
    }()
    var numberOfViewControllers: Int {
        return allViewControllers.count
    }
    private var currentVCIndex = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers([allViewControllers.first!], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: - OnboardingDelegate
    
    func nextButtonTapped() {
        currentVCIndex += 1
        if currentVCIndex == allViewControllers.count {
            finishOnboarding()
        } else {
            setViewControllers([allViewControllers[currentVCIndex]], direction: .forward, animated: true, completion: nil)
        }
    }
     
    // MARK: - Helpers
    
    private func finishOnboarding() {
        UserDefaultsManager.shared.hasCompletedOnboarding = true
        RootViewController.shared.goToHomeVC()
    }
    
}
