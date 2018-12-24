//
//  NSObject+AH.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 12/23/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import Foundation

extension NSObject {
    static var className: String {
        return String(describing: self)
    }
}
