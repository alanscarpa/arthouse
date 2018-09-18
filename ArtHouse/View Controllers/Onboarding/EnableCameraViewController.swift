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
    
    @IBAction func nextButtonTapped() {
        // TODO: PRESENT CAMERA PERMISSION,
            // IF ACCEPTED, TRIGGER DELEGATE
            // IF DENIED, CHANGE TEXT, AND PREVENT MOVING FORWARD, THEN CHECK FOR CAMERA PERMISSIONS ON VIEWWILLAPPEAR
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) else {
            let alertVC = UIAlertController.simpleAlert(withTitle: "No Camera", message: "You are unable to use ArtHouse becuase your phone does not have a camera.")
            present(alertVC, animated: true, completion: nil)
            return
        }
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
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
