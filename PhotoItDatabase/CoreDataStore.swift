//
//  CoreDataStore.swift
//  Photoit
//
//  Created by Roman Barzyczak on 13.06.2015.
//  Copyright (c) 2015 Photoit. All rights reserved.
//

import Foundation
import Foundation
import CoreData

@objc public class CoreDataStore: NSObject {
    // MARK: - Core Data stack
    public class var sharedInstance : CoreDataStore {
        struct Static {
            static let instance : CoreDataStore = CoreDataStore()
        }
        return Static.instance
    }
    
    public class func mainQueueContext() -> NSManagedObjectContext {
        return self.sharedInstance.mainQueueCtxt!
    }
    
    public class func privateQueueContext() -> NSManagedObjectContext {
        return self.sharedInstance.privateQueueCtxt!
    }
    
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSavePrivateQueueContext:", name: NSManagedObjectContextDidSaveNotification, object: self.privateQueueCtxt)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contextDidSaveMainQueueContext:", name: NSManagedObjectContextDidSaveNotification, object: self.mainQueueCtxt)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - NSManagedObject Contexts
    
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mymobi.Remember_Remember" in the application's documents Application Support directory.
        
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        
        
        
        
        }()
    
    
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional...
        let modelURL = NSBundle.mainBundle().URLForResource("Photoit", withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        // Check if we are running as test or not
        let environment = NSProcessInfo.processInfo().environment as! [String : AnyObject]
        let isTest = (environment["XCInjectBundle"] as? String)?.pathExtension == "xctest"
        
        // Create the module name
        let moduleName = (isTest) ? "PhotoitTests" : "Photoit"
        
        // Create a new managed object model with updated entity class names
        var newEntities = [] as [NSEntityDescription]
        for (_, entity) in enumerate(managedObjectModel.entities) {
            let newEntity = entity.copy() as! NSEntityDescription
            newEntity.managedObjectClassName = entity.name// "\(moduleName).\(entity.name)"
            newEntities.append(newEntity)
        }
        let newManagedObjectModel = NSManagedObjectModel()
        newManagedObjectModel.entities = newEntities
        
        return newManagedObjectModel
        
        //        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        //        let modelURL = NSBundle.mainBundle().URLForResource("Remember_Remember", withExtension: "momd")!
        //        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let directory = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("group.photoit.widget");
        
        let url = directory?.URLByAppendingPathComponent("Photoit.sqlite")
        
        
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let myOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSPersistentStoreUbiquitousContentNameKey : "Photoit",
            NSInferMappingModelAutomaticallyOption: true]
        
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: myOptions, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "com.mymobi.photoit", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        println("\(coordinator?.persistentStores)")
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    lazy var mainQueueCtxt: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
    
    lazy var privateQueueCtxt: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        var managedObjectContext = NSManagedObjectContext(concurrencyType:.PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
        }()
}
