//
//  UIAlertController+AH.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/9/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func simpleAlert(withTitle title: String, message: String) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(action)
        return alertController
    }
}

