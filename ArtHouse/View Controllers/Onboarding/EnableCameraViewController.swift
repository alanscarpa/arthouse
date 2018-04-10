//
//  EnableCameraViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/7/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

class EnableCameraViewController: OnboardingChildViewController {
    
    @IBAction func nextButtonTapped() {
        delegate?.nextButtonTapped()
    }
    
}
