//
//  EnableCameraViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/7/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit
import Photos

class EnableCameraViewController: OnboardingChildViewController {
    
    @IBOutlet weak var enableCameraButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        enableCameraButton.round()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            self.delegate?.nextButtonTapped()
        }
    }
    
    @IBAction func nextButtonTapped() {
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            let alertVC = UIAlertController.simpleAlert(withTitle: "No Camera", message: "You are unable to use ArtHouse because your phone does not have a camera.")
            present(alertVC, animated: true, completion: nil)
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.delegate?.nextButtonTapped()
                }
            } else {
                let alertVC = UIAlertController.simpleAlert(withTitle: "Camera Access Denied", message: "Go to settings and allow camera access in order to use ArtHouse.")
                DispatchQueue.main.async {
                    self?.present(alertVC, animated: true, completion: nil)
                }
            }
        }
    }
    
}
