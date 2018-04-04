//
//  UIViewController+AH.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/3/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import Foundation

import UIKit

extension UIViewController {
    func ahAddChildViewController(_ childVC: UIViewController) {
        childVC.willMove(toParentViewController: self)
        addChildViewController(childVC)
        view.addSubview(childVC.view)
        childVC.view.frame = view.frame
        childVC.didMove(toParentViewController: self)
    }
}
