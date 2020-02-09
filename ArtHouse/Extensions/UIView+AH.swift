//
//  UIView+AH.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/8/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import UIKit

extension UIView {
    func roundCorners(_ cornerRadius: CGFloat = 10) {
        layer.cornerRadius = cornerRadius
    }

    func roundCornersToCircle() {
        layer.cornerRadius = frame.size.width / 2
    }
}
