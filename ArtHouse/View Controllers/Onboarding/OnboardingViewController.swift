//
//  OnboardingViewController.swift
//  ArtHouse
//
//  Created by Alan Scarpa on 4/7/18.
//  Copyright © 2018 The Scarpa Group. All rights reserved.
//

import UIKit

protocol OnboardingDelegate: class {
    func nextButtonTapped()
}

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, OnboardingDelegate {
    
    lazy var allViewControllers: [UIViewController] = {
        let enableVC = EnableCameraViewController()
        enableVC.delegate = self
        let chooseVC = ChooseArtworkViewController()
        chooseVC.delegate = self
        let positionYourselfVC = PositionYourselfViewController()
        positionYourselfVC.delegate = self
        return [enableVC, chooseVC, positionYourselfVC]
    }()
    var numberOfViewControllers: Int {
        return allViewControllers.count
    }
    private var currentVCIndex = 0
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers([allViewControllers.first!], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: - OnboardingDelegate
    
    func nextButtonTapped() {
        if currentVCIndex == allViewControllers.count - 1 {
            finishOnboarding()
        } else {
            guard let nextVC = dataSource?.pageViewController(self, viewControllerAfter: allViewControllers[currentVCIndex]) else { return }
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
        }
    }

    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = indexOfViewController(viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 && numberOfViewControllers > previousIndex else { return nil }
        currentVCIndex = previousIndex
        return allViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = indexOfViewController(viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        if nextIndex == allViewControllers.count {
            finishOnboarding()
            return nil
        } else {
            guard numberOfViewControllers != nextIndex && numberOfViewControllers > nextIndex else { return nil }
            currentVCIndex = nextIndex
            return allViewControllers[nextIndex]
        }
    }
     
    // MARK: - Helpers
    
    private func indexOfViewController(_ viewController: UIViewController) -> Int? {
        guard let viewControllerIndex = allViewControllers.firstIndex(of: viewController) else { return nil }
        return viewControllerIndex
    }
    
    private func finishOnboarding() {
        UserDefaultsManager.shared.hasCompletedOnboarding = true
        RootViewController.shared.goToHomeVC()
    }
    
}
