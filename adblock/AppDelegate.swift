//
//  AppDelegate.swift
//  adblock
//
//  Created by abuharsky on 11.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        if TARGET_IPHONE_SIMULATOR == 1 {
            // Simulator
//            self.didRegisterToken("SIMULATOR_TOKEN")
        }
        
        return true
    }
    
    func applicationWillTerminate(application: UIApplication) {
        if let navController = window?.rootViewController as? UINavigationController {
            if let rootController = navController.viewControllers.first as? RootViewController {
                if rootController.backgroundTask != UIBackgroundTaskInvalid {
                    let localNotification = UILocalNotification()
                    localNotification.alertBody = "Filters are not updated".localized
                    localNotification.fireDate = NSDate()
                    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                }
            }
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        var token = String(format: "%@", deviceToken)
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        print("token:\(token)")
        
        self.didRegisterToken(token)
    }
    
    func didRegisterToken(token : String) {
        let request : NSMutableURLRequest?
        request = NSMutableURLRequest.init(URL: NSURL.init(string: "http://adblock-devorel.rhcloud.com/api/subscribe/updates/?bundle-id=asdfasdf&country=ru&apns-token=".stringByAppendingString(token))!)
        
        request?.HTTPMethod = "POST"
        
        
        NSURLSession.sharedSession().dataTaskWithRequest(request!)
            {
                (data, response, error) -> Void in
                
                print("code: \((response as! NSHTTPURLResponse).statusCode)")
                
                if data != nil {
                    print("data: \(NSString.init(data: data!, encoding: NSUTF8StringEncoding))")
                } else {
                    print("failed: \(error!.localizedDescription)")
                }
            }.resume()
    }

}

