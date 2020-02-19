//
//  AppDelegate.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 3/21/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        settings.isPersistenceEnabled = false
        db.settings = settings

        window = UIWindow(frame: UIScreen.main.bounds)
        window!.rootViewController = RootViewController.shared
        window!.makeKeyAndVisible()
        window!.backgroundColor = .white

        UINavigationBar.appearance().tintColor = UIColor.ahPrimaryBlue
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.ahPrimaryBlue]


        if UserDefaultsManager.shared.hasCompletedOnboarding {
            RootViewController.shared.goToHomeVC()
        } else {
            RootViewController.shared.goToOnboardingVC()
        }
        
        return true
    }
}

