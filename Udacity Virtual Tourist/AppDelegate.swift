//
//  AppDelegate.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 05/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: User Defaults
    
    func checkIfFirstLaunch() {
        if(UserDefaults.standard.bool(forKey: "firstTimeLaunching")) {
        } else {
            UserDefaults.standard.set(true, forKey: "firstTimeLaunching")
            UserDefaults.standard.set(38.36688, forKey: "defaultLatitude")
            UserDefaults.standard.set(-97.492188, forKey: "defaultLongitude")
            UserDefaults.standard.set(72.242558, forKey: "defLatiDelta")
            UserDefaults.standard.set(44.850853, forKey: "defLongiDelta")
            UserDefaults.standard.synchronize()
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        checkIfFirstLaunch()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TouristPoint")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }


}






    



