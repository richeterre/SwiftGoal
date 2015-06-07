//
//  AppDelegate.swift
//  SwiftGoal
//
//  Created by Martin Richter on 10/05/15.
//  Copyright (c) 2015 Martin Richter. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        // Customize appearance
        application.statusBarStyle = .LightContent
        let tintColor = UIColor(red:0.99, green:0.54, blue:0.19, alpha:1)
        window?.tintColor = tintColor
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        UINavigationBar.appearance().translucent = false

        // Set up initial hierarchy
        let matchesViewModel = MatchesViewModel(store: Store())
        let matchesViewController = MatchesViewController(viewModel: matchesViewModel)
        window?.rootViewController = UINavigationController(rootViewController: matchesViewController)
        window?.makeKeyAndVisible()

        return true
    }
}

