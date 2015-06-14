//
//  DatabaseHelper.swift
//  Photoit
//
//  Created by Roman Barzyczak on 13.06.2015.
//  Copyright (c) 2015 Photoit. All rights reserved.
//

import UIKit
import Foundation
import CoreData

var ENTITY_ITEM_NAME:String = "Item"

struct DatabaseHelper {

    static func deleteItem(item:Item) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        let context = appDelegate.managedObjectContext!
        context.deleteObject(item)
        var error: NSError?
        if context.hasChanges && !context.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    static func saveItem(photo:UIImage) -> Item  {
        //1
        
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
        
        
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName(ENTITY_ITEM_NAME, inManagedObjectContext:managedContext)
        
        let item = Item(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        var itemNameVar = "Image item from " + (DateHelper.niceCurrentDate() as String)
        
        item.name = itemNameVar
        
        
        var error: NSError?
        if managedContext.hasChanges && !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        var itemObjectId:String = item.objectID.URIRepresentation().absoluteString!
        var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
        
        
        FileHelper.saveImage(itemSanitizeName, image: photo)
        
        return item
    }
    
    
    static func getItems() -> [Item] {
        //
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
        
        let moc = appDelegate.managedObjectContext!
        let entityDescription = NSEntityDescription.entityForName(ENTITY_ITEM_NAME, inManagedObjectContext: moc)
        let request = NSFetchRequest()
        request.entity = entityDescription;
        
        
        var error:NSErrorPointer = NSErrorPointer()
        
        let array = moc.executeFetchRequest(request, error: error) as! [Item]
        
        return array
    }
}