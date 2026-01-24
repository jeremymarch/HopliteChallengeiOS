//
//  SceneDelegate.swift
//  HopliteChallenge
//
//  Created by jeremy on 1/24/26.
//  Copyright © 2026 Jeremy March. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window.rootViewController = storyboard.instantiateInitialViewController()
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Scene released, clean up resources
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Scene moved to foreground
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Scene moving to background/inactive
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Scene coming from background
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Scene in background
    }
}

