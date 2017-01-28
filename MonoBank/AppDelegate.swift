//
//  AppDelegate.swift
//  MonoBank
//
//  Created by Richard Neitzke on 31/12/2016.
//  Copyright © 2016 Richard Neitzke. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		return true
	}

	func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .pad {
			return .all
		} else {
			return .portrait
		}
	}
	
}

