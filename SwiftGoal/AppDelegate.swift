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

    private let useRemoteStoreSettingKey = "use_remote_store_setting"
    private let useRemoteStoreSettingDefault = false
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

        let userDefaults = NSUserDefaults.standardUserDefaults()

        registerInitialSettings(userDefaults)

        // Set tab-level view controllers with appropriate store
        let store = storeForUserDefaults(userDefaults)
        tabBarController.viewControllers = tabViewControllersForStore(store)

        // Register for settings changes as store might have changed
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
            let store = storeForUserDefaults(userDefaults)
            tabBarController.viewControllers = tabViewControllersForStore(store)
        }
    }

    // MARK: Private Helpers

    private func registerInitialSettings(userDefaults: NSUserDefaults) {
        if userDefaults.objectForKey(useRemoteStoreSettingKey) == nil {
            userDefaults.setBool(useRemoteStoreSettingDefault, forKey: useRemoteStoreSettingKey)
        }
        if userDefaults.stringForKey(baseURLSettingKey) == nil {
            userDefaults.setObject(baseURLSettingDefault, forKey: baseURLSettingKey)
        }
    }

    private func storeForUserDefaults(userDefaults: NSUserDefaults) -> StoreType {
        if userDefaults.boolForKey(useRemoteStoreSettingKey) == true {
            // Create remote store
            let baseURLString = userDefaults.stringForKey(baseURLSettingKey) ?? baseURLSettingDefault
            let baseURL = baseURLFromString(baseURLString)
            return RemoteStore(baseURL: baseURL)
        } else {
            // Create local store
            return LocalStore()
        }
    }

    private func baseURLFromString(var baseURLString: String) -> NSURL {
        // Append forward slash if needed to ensure proper relative URL behavior
        let forwardSlash: Character = "/"
        if !baseURLString.hasSuffix(String(forwardSlash)) {
            baseURLString.append(forwardSlash)
        }

        return NSURL(string: baseURLString) ?? NSURL(string: baseURLSettingDefault)!
    }

    private func tabViewControllersForStore(store: StoreType) -> [UIViewController] {
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

