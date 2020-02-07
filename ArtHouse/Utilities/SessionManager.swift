//
//  SessionManager.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/7/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import Foundation

class SessionManager {
    static let sharedSession = SessionManager()
    private init(){}

    var didCompleteArtworkTutorial = false
}
