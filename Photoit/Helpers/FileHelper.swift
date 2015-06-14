//
//  FileHelper.swift
//  Photoit
//
//  Created by Roman Barzyczak on 13.06.2015.
//  Copyright (c) 2015 Photoit. All rights reserved.
//

import Foundation
import UIKit

struct FileHelper {
    
    
    static func removeImage(itemName:String) {
        var image:UIImage!
        let fileManager = NSFileManager.defaultManager()
        
        var filePath = NSString(format:"%@%@.png", sharedDictionary(), itemName) as String
        var error:NSErrorPointer = NSErrorPointer()
        fileManager.removeItemAtPath(filePath, error: error)
        if error != nil {
            println(error.debugDescription)
        }
        
        var filePathSmall = NSString(format:"%@small_%@.png", sharedDictionary(), itemName) as String
        var errorSmall:NSErrorPointer = NSErrorPointer()
        fileManager.removeItemAtPath(filePathSmall, error: errorSmall)
        if errorSmall != nil {
            println(errorSmall.debugDescription)
        }
        
    }
    
    static func sanitizeFileNameString(fileName:String) ->String {
        let illegalFileNameCharacters:NSCharacterSet = NSCharacterSet(charactersInString: "/\\?%*|\"<>")
        let components : [String] = fileName.componentsSeparatedByCharactersInSet(illegalFileNameCharacters)
        let joinedString = join("", components)
        return joinedString
    }
    
    static func sharedDictionary() -> String {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        return appDelegate.applicationDocumentsDirectory.path!
    }
    
    static func saveImage(itemName:String, image:UIImage) -> Bool {
        var fileName = NSString(format:"%@.png", itemName) as String
        let writePath = sharedDictionary().stringByAppendingPathComponent(fileName)
        var success = UIImagePNGRepresentation(image).writeToFile(writePath, atomically: true)
        println("Image saved to " + writePath)
        
        var fileNameSmall = NSString(format:"small_%@.png", itemName) as String
        let smallImage:UIImage = FileHelper.imageWithImage(image, newSize: CGSizeMake(320, 320))
        
        let writePathSmallImage = sharedDictionary().stringByAppendingPathComponent(fileNameSmall)
        var smallSuccess = UIImagePNGRepresentation(smallImage).writeToFile(writePathSmallImage, atomically: true)
        
        return smallSuccess
    }
    
    static func imageWithImage(image:UIImage, newSize:CGSize) ->UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, true, UIScreen.mainScreen().scale);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage
    }
    
    static func readImage(itemName:String)->UIImage {
        var image:UIImage!
        
        var fileName = NSString(format:"%@.png",itemName ) as String
        let readPath = sharedDictionary().stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(readPath))
        {
            image = UIImage(named: readPath)!
        }
        else
        {
            println("FILE NOT AVAILABLE");
            return UIImage()
        }
        
        return image
    }
    
    static func readSmallImage(itemName:String)->UIImage {
        var image:UIImage!
        
        var fileName = NSString(format:"small_%@.png",itemName ) as String
        
        println("Image read to " + fileName)

        let readPath = sharedDictionary().stringByAppendingPathComponent(fileName)
        var checkValidation = NSFileManager.defaultManager()
        
        if (checkValidation.fileExistsAtPath(readPath))
        {
            image = UIImage(named: readPath)!
        }
        else
        {
            println("FILE NOT AVAILABLE");
            return UIImage()
        }
        
        return image
    }
    
    static func smallItemImage(item:Item, newSize:CGSize) -> UIImage? {
        var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
        var itemImage:UIImage? = FileHelper.readImage(itemSanitizeName)
        
        if let itemImage = itemImage  {
            if itemImage.size.height > 0 && itemImage.size.width > 0 {
                let smallImage:UIImage = FileHelper.imageWithImage(itemImage, newSize: newSize)
                return smallImage
            }
            
        }
        
        
        return nil
    }
    
    static func bigItemImage(item:Item) -> UIImage? {
        var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
        var itemImage:UIImage? = FileHelper.readImage(itemSanitizeName)
        
        if let itemImage = itemImage  {
            if itemImage.size.height > 0 && itemImage.size.width > 0 {
                return itemImage
            }
            
        }
        return nil
    }
}


