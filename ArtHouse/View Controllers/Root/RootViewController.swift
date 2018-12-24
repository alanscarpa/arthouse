//
//  RootViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/3/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

class RootViewController: UIViewController, UINavigationControllerDelegate {
    
    static let shared = RootViewController()
    private let rootNavigationController = UINavigationController()
    var showNavigationBar = true {
        didSet {
            rootNavigationController.setNavigationBarHidden(!showNavigationBar, animated: true)
        }
    }
    
    var showToolBar = true {
        didSet {
            rootNavigationController.setToolbarHidden(!showToolBar, animated: true)
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpRootNavigationController()
        setUpAppearances()
    }
    
    // MARK: - Setup
    
    private func setUpRootNavigationController() {
        rootNavigationController.setNavigationBarHidden(true, animated: false)
        rootNavigationController.delegate = self
        ahAddChildViewController(rootNavigationController)
    }
    
    private func setUpAppearances() {
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .ahPrimaryBlue
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = .white
    }
    
    // MARK: - Navigation
    
    func popViewController() {
        rootNavigationController.popViewController(animated: true)
    }
    
    func goToOnboardingVC() {
        rootNavigationController.setViewControllers([OnboardingViewController()], animated: true)
    }
    
    func goToHomeVC() {
        rootNavigationController.setViewControllers([HomeCollectionViewController()], animated: true)
    }
    
}
