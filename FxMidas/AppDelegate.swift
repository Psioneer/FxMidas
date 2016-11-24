//
//  AppDelegate.swift
//  FxMidas
//
//  Created by KOBOKKYUNG on 2016. 11. 14..
//  Copyright © 2016년 Studio Psion. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import UserNotifications
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .alert, .sound], completionHandler: { (granted, error) in
            
        })
        application.registerForRemoteNotifications()
        
        let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
        if let authenticationToken = keychainItemWrapper["authenticationToken"] as? String {
        
            let path = "/debug_token?input_token=" + authenticationToken
            let request = GraphRequest.init(graphPath: path)
        
            request.start({ (httpResponse, result) in
                switch result {
                case .failed(let error):
                    print("Graph Request Failed: \(error)")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                    self.window?.rootViewController = controller
                    self.window?.makeKeyAndVisible()
                case .success(let response):
                    print("Graph Request Succeeded: \(response)")
                
                    if let responseDictionanry = response.dictionaryValue {
                        if let data = responseDictionanry["data"] as? [String: Any] {
                            if (data["is_valid"] as! Bool == true) {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "TabBar")
                                self.window?.rootViewController = controller
                                self.window?.makeKeyAndVisible()
                            } else {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
                                self.window?.rootViewController = controller
                                self.window?.makeKeyAndVisible()
                            }
                        }
                    }
                }
            })
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "LoginNavi")
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()            
        }
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        return SDKApplicationDelegate.shared.application(application, open: url, options: options)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEventsLogger.activate(application)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FxMidas")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("Device Token: \(deviceTokenString)")
        
        let uuidString = UIDevice.current.identifierForVendor!.uuidString
        print("UUID String: \(uuidString)")
        
        let systemName = UIDevice.current.systemName
        print(systemName)
        let systemVersion = UIDevice.current.systemVersion
        print(systemVersion)
        //let keychainItemWrapper = KeychainItemWrapper(identifier: "access info", accessGroup: nil)
        //keychainItemWrapper["deviceToken"] = deviceTokenString as AnyObject?
        
        // 서버로 os버전, 디바이스토큰, UUID 전송
        
        let parameters = [
            "systemName": systemName,
            "systemVersion": systemVersion,
            "uuid": uuidString,
            "deviceToken": deviceTokenString
        ]
        
        Alamofire.request("http://fmapi.japaneast.cloudapp.azure.com/api/device", method: .post, parameters: parameters).validate().responseJSON { response in
            switch response.result {
            case .success:
                print(response.result.value! as Any)
            case .failure(let error):
                print(error)
            }
            
        }
        
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("i am not available in simulator \(error)")
        
    }
    
    
}

