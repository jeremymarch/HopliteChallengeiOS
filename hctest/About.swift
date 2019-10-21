//
//  About.swift
//  HopliteChallenge
//
//  Created by Jeremy on 7/20/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

class AboutPageViewController: UIPageViewController {
    let pageNames = ["tutorialTitlePage", "tutorialAcknowledgements", "tutorialGamePlay", "tutorialPractice", "TutorialKeyboard", "tutorialPinch" /*, "tutorialchild", "tutorialchild2",*/]
    var index = 0
    
    //https://stackoverflow.com/questions/28014852/transition-pagecurl-to-scroll-with-uipageviewcontroller
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                animated: true,
                completion: nil)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(color: pageNames[0]),
                self.newColoredViewController(color: pageNames[1]),
                self.newColoredViewController(color: pageNames[2]),
                self.newColoredViewController(color: pageNames[3]),
                self.newColoredViewController(color: pageNames[4]),
                self.newColoredViewController(color: pageNames[5])]
    }()

    private func newColoredViewController(color: String) -> UIViewController {
        let a = AboutChildViewController()
        a.htmlFileName = color
        return a
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let att = [ NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20)! ]
        self.navigationController?.navigationBar.titleTextAttributes = att
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {

                return 0
        
        
        //return firstViewControllerIndex
    }
}

// MARK: UIPageViewControllerDataSource

extension AboutPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
}
