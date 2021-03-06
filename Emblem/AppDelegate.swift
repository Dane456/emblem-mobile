//
//  AppDelegate.swift
//  Emblem
//
//  Created by Dane Jordan on 8/3/16.
//  Copyright © 2016 Hadashco. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let googleMapsApiKey = "AIzaSyBi7NLOagsHBOfINbLARaXhHVoOSBw3-_E"
    let deployedServerString:String = "http://www.emblemar.com:3000/"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        IQKeyboardManager.sharedManager().enable = true
        if let devServer = NSProcessInfo.processInfo().environment["DEV_SERVER"] as String? {
            Store.serverLocation = devServer
        } else {
            Store.serverLocation = deployedServerString
        }
        
        // Temp until we can retrieve vals from cache
        NSURLCache.setSharedURLCache(NSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil))

        print("Clearing Temp!")
        ResourceHandler.clearTempFolder()

        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleMapsApiKey)
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        if let font = UIFont(name: "OpenSans", size: 17) {
            UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.blackColor()]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: font], forState: .Normal)
            
            
        }
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

    }


}

