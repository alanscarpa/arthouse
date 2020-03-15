//
//  PositionYourselfViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/7/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

class PositionYourselfViewController: OnboardingChildViewController {

    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.round()
    }

    @IBAction func nextButtonTapped() {
        delegate?.nextButtonTapped()
    }

}
