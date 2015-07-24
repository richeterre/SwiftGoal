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
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!
        ], forState: .Normal)

        // Set up initial hierarchy

        let store = Store()

        let matchesViewModel = MatchesViewModel(store: store)
        let matchesViewController = MatchesViewController(viewModel: matchesViewModel)
        let matchesNavigationController = UINavigationController(rootViewController: matchesViewController)
        matchesNavigationController.tabBarItem = UITabBarItem(
            title: matchesViewModel.title,
            image: UIImage(named: "FootballFilled"),
            selectedImage: UIImage(named: "FootballFilled")
        )

        let rankingsViewModel = RankingsViewModel(store: store)
        let rankingsViewController = RankingsViewController(viewModel: rankingsViewModel)
        let rankingsNavigationController = UINavigationController(rootViewController: rankingsViewController)
        rankingsNavigationController.tabBarItem = UITabBarItem(
            title: rankingsViewModel.title,
            image: UIImage(named: "Crown"),
            selectedImage: UIImage(named: "CrownFilled")
        )

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [matchesNavigationController, rankingsNavigationController]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }
}

