//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/17/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedStringKey.font: UIFont(name: "Helvetica Neue", size: 17)!],
                for: .normal)
        return true
    }

}

