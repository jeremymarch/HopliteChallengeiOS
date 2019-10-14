//
//  About.swift
//  HopliteChallenge
//
//  Created by Jeremy on 7/20/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

class AboutPageViewController: UIPageViewController {
    let pageNames = ["tutorialIntro", "tutorialAcknowledgements", "tutorialGamePlay", "tutorialPractice", "tutorialKeyboard", "tutorialPinch" /*, "tutorialchild", "tutorialchild2",*/]
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
    }
}

// MARK: UIPageViewControllerDataSource

extension AboutPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}
