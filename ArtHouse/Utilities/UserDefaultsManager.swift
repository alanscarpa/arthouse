//
//  UserDefaults.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 9/18/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import Foundation

//Indigo Mountains
//https://society6.com/product/indigo-mountains894310_framed-print?curator=thescarpagroup
//10x12
//44.99
//
//Pinky Swear
//https://society6.com/product/pinky-swear800336_framed-print?curator=thescarpagroup
//10x12
//54.99
//
//Moroccan Pool
//https://society6.com/product/moroccan-pool286802_framed-print?curator=thescarpagroup
//10x12
//50.99
//
//Anish Dress
//https://society6.com/product/nameless-dress_framed-print?curator=thescarpagroup
//10x12
//52.99
//
//Palm Springs Tigers
//https://society6.com/product/palm-springs-tigers_framed-print?curator=thescarpagroup
//10x12
//49.99
//
//Cyra Framed
//https://society6.com/product/cyra901820_framed-print?curator=thescarpagroup
//10x12
//43.99
//
//Comfort Zone
//https://society6.com/product/comfort-zone233861_framed-print?curator=thescarpagroup
//10x12
//47.99
//
//Let The Sunshine In
//https://society6.com/product/let-the-sunshine-in1513559_framed-print?curator=thescarpagroup
//10x12
//44.99
//
//The Swim
//https://society6.com/product/the-swim-9se_framed-print?curator=thescarpagroup
//10x12
//58.99
//
//Life quote F. Scott Fitzgerald
//https://society6.com/product/life-quote-f-scott-fitzgerald_framed-print?curator=thescarpagroup
//10x12
//51.99
//
//How far is a light year?
//https://society6.com/product/how-far-is-a-light-year_framed-print?curator=thescarpagroup
//10x12
//47.99
//
//Joshua Tree
//https://society6.com/product/joshua-tree1360561_framed-print?curator=thescarpagroup
//10x12
//44.99
//
//Jungle Panther
//https://society6.com/product/jungle-panther920027_framed-print?curator=thescarpagroup
//10x12
//42.99
//
//I Saw Her In the Library
//https://society6.com/product/i-saw-her-in-the-library_framed-print?curator=thescarpagroup
//10x12
//69.99

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
