//
//  AppDelegate.swift
//  iOSSBackAPI
//
//  Created by Matheus Ribeiro on 06/07/2017.
//  Copyright (c) 2017 Matheus Ribeiro. All rights reserved.
//  FIVE'S DEVELOPMENT LTDA

import UIKit
import MapKit
import iOSSBackAPI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, iOSSBackAPIDelegate{

    var window: UIWindow?
    
    var sback:iOSSBackAPI!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sback = iOSSBackAPI(key: "0a0ec49bff3978d7ce232aecf34f19a9", email: "as@shopback.com.br", cellphone: nil, uid: nil, del:self, rangeInKm: 1)
        sback.pinCheck = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    //MARK: iOSSBackAPIDelegate
    /*
    func notificateWhenAPPIsActive(store_id: String, title: String, message: String) {
        //Called when the application is active and the notification needs send
    }
     
    func userClickedInNotificationSBack() {
        //Called when the user click in the notification SBack
    }
    */
    
    func pointsLoaded(points:[CLCircularRegion]) {
        //Called when the points of region was load
        (window?.rootViewController as! ViewController).points = points
        (window?.rootViewController as! ViewController).addPoint()
    }
}

