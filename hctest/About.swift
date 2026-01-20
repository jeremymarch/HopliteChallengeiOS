//
//  About.swift
//  HopliteChallenge
//
//  Created by Jeremy on 7/20/19.
//  Copyright © 2019 Jeremy March. All rights reserved.
//

import UIKit

class AboutPageViewController: UIPageViewController {
    
    let pageNames = [ "tutorialTitlePage", "tutorialAcknowledgements", "tutorialGamePlay", "tutorialPractice", "tutorialKeyboard", "tutorialPinch", "tutorialThirdPartySoftware" ]
    var index = 0
    //var orderedViewControllers2: [UIViewController] = []
    //https://stackoverflow.com/questions/28014852/transition-pagecurl-to-scroll-with-uipageviewcontroller
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = GlobalTheme.primaryBG

            // To make it transparent (no gradient, no color):
            // appearance.configureWithTransparentBackground()

            // Apply the appearance to the standard, compact, and scroll edge states
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        //this fixes ugly transition when this view is clear until it is fully loaded
        view.backgroundColor = GlobalTheme.primaryBG
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                animated: true,
                completion: nil)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newColoredViewController(html: pageNames[0]),
                self.newColoredViewController(html: pageNames[1]),
                self.newColoredViewController(html: pageNames[2]),
                self.newColoredViewController(html: pageNames[3]),
                self.newColoredViewController(html: pageNames[4]),
                self.newColoredViewController(html: pageNames[5]),
                self.newColoredViewController(html: pageNames[6])]
    }()

    func newColoredViewController(html: String) -> UIViewController {
        let a = AboutChildViewController()
        a.htmlFileName = html
        return a
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let att = [ NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20)! ]
        self.navigationController?.navigationBar.titleTextAttributes = att
        self.navigationController?.isNavigationBarHidden = false
    }
}

// MARK: UIPageViewControllerDataSource

extension AboutPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
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
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
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
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return orderedViewControllers.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
                guard let firstViewController = viewControllers?.first,
                    let firstViewControllerIndex = orderedViewControllers.firstIndex(of:firstViewController) else {
                        return 0
                }
                
                return firstViewControllerIndex
    }
}
