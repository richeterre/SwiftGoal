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
    let tabBarController = UITabBarController()

    private let baseURLSettingKey = "base_url_setting"
    private let baseURLSettingDefault = "http://localhost:3000/api/v1/"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)

        // Customize appearance
        application.statusBarStyle = .LightContent
        let tintColor = Color.primaryColor
        window?.tintColor = tintColor
        UINavigationBar.appearance().barTintColor = tintColor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(name: "OpenSans-Semibold", size: 20)!,
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        UINavigationBar.appearance().translucent = false
        UIBarButtonItem.appearance().setTitleTextAttributes(
            [NSFontAttributeName: UIFont(name: "OpenSans", size: 17)!],
            forState: .Normal
        )

        // Register initial settings
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.stringForKey(baseURLSettingKey) == nil {
            userDefaults.setObject(baseURLSettingDefault, forKey: baseURLSettingKey)
        }

        // Get base URL from settings
        let baseURLString = userDefaults.stringForKey(baseURLSettingKey) ?? baseURLSettingDefault
        let baseURL = baseURLFromString(baseURLString)

        // Set tab-level view controllers based on URL
        tabBarController.viewControllers = tabViewControllersForBaseURL(baseURL)

        // Register for settings changes to reload view hierarchy
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: Selector("userDefaultsDidChange:"),
            name: NSUserDefaultsDidChangeNotification,
            object: nil)

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: Notifications

    func userDefaultsDidChange(notification: NSNotification) {
        if let userDefaults = notification.object as? NSUserDefaults {
            let baseURLString = userDefaults.stringForKey(baseURLSettingKey) ?? baseURLSettingDefault
            let baseURL = baseURLFromString(baseURLString)
            tabBarController.viewControllers = tabViewControllersForBaseURL(baseURL)
        }
    }

    // MARK: Private Helpers

    private func baseURLFromString(var baseURLString: String) -> NSURL {
        // Append forward slash if needed to ensure proper relative URL behavior
        let forwardSlash: Character = "/"
        if !baseURLString.hasSuffix(String(forwardSlash)) {
            baseURLString.append(forwardSlash)
        }

        return NSURL(string: baseURLString) ?? NSURL(string: baseURLSettingDefault)!
    }

    private func tabViewControllersForBaseURL(baseURL: NSURL) -> [UIViewController] {
        let store = RemoteStore(baseURL: baseURL)

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

        return [matchesNavigationController, rankingsNavigationController]
    }
}

