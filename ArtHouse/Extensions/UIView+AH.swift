//
//  UIView+AH.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 2/8/20.
//  Copyright © 2020 The Scarpa Group. All rights reserved.
//

import UIKit

extension UIView {
    func round(_ cornerRadius: CGFloat = 10) {
        clipsToBounds = true
       //layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    func roundCorners(_ corners: CACornerMask, cornerRadius: CGFloat = 10) {
        clipsToBounds = true
        layer.maskedCorners = corners
        //layer.masksToBounds = true
        layer.cornerRadius = cornerRadius
    }
}
