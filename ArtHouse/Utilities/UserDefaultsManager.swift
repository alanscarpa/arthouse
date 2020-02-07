//
//  UserDefaults.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 9/18/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private init(){}
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboardingKey"

    var hasCompletedOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        } set {
            return UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
}
