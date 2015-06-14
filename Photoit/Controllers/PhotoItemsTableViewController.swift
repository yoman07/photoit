//
//  PhotoItemsTableViewController.swift
//  Photoit
//
//  Created by Roman Barzyczak on 13.06.2015.
//  Copyright (c) 2015 Photoit. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

class PhotoItemsTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MWPhotoBrowserDelegate {
    
    var items = [Item]()
    let kCellPhotoIdentifier = "ItemCellPhotoIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 69.0
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onContentSizeChange:",
            name: UIContentSizeCategoryDidChangeNotification,
            object: nil)
        cameraAction()
        self.tableView.registerNib(UINib(nibName: "ItemPhotoViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: kCellPhotoIdentifier)
        configureTableView()
    }
    
    func onContentSizeChange(notification: NSNotification) {
        tableView.reloadData()
    }
    
    @IBAction func addItem(sender: AnyObject) {
        cameraAction()
    }
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        refreshItems()
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.saveContext()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contentSizeCategoryChanged:", name: UIContentSizeCategoryDidChangeNotification, object: nil)
        self.tableView.reloadData()
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections())), withRowAnimation: .None)

    }

    override func viewDidDisappear(animated: Bool)
    {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    // This function will be called when the Dynamic Type user setting changes (from the system Settings app)
    func contentSizeCategoryChanged(notification: NSNotification)
    {
        tableView.reloadData()
    }
    
    
    
    func refreshItems() {
        items =  DatabaseHelper.getItems()
        self.tableView.reloadData()
    }
    
    func cameraAction() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            
            var imag = UIImagePickerController()
            imag.delegate = self
            imag.sourceType = UIImagePickerControllerSourceType.Camera;
            imag.mediaTypes = [kUTTypeImage]
            imag.allowsEditing = true
            
            self.presentViewController(imag, animated: true, completion: nil)
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            var imag = UIImagePickerController()
            imag.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            imag.allowsEditing = false
            imag.delegate = self
            imag.mediaTypes = [kUTTypeImage]
            self.presentViewController(imag, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        println("i've got an image");
        DatabaseHelper.saveItem(image)
        picker.dismissViewControllerAnimated(false, completion: nil)
    }
    
    
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return items.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            
            let item : Item = items[indexPath.row] as Item
            var name = item.name
            
            var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
            
            if let cell: ItemPhotoViewCell = tableView.dequeueReusableCellWithIdentifier(kCellPhotoIdentifier) as? ItemPhotoViewCell {

                cell.itemPhoto.contentMode  = .ScaleAspectFill;
                cell.itemPhoto.clipsToBounds = true;
                cell.itemPhoto.tag = 10
                
                let qualityOfServiceClass = QOS_CLASS_BACKGROUND
                let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
                
                cell.itemPhoto.image = UIImage()
                
                
                dispatch_async(backgroundQueue, {
                    
                    let smallImage:UIImage? = FileHelper.readSmallImage(itemSanitizeName)
                    
                    
                    if let image:UIImage = smallImage {
                        if image.size.width > 0 && image.size.height > 0  {
                            dispatch_async(dispatch_get_main_queue(), {
                                cell.itemPhoto.image = smallImage
                            })
                        }
                    } else {
                        cell.itemPhoto.image = UIImage()
                        
                    }
                    
                })

                return cell
            
            }
            
            assert(false, "The dequeued table view cell was of an unknown type!");
            return UITableViewCell();
    }
    
    var tapCount:Int = 0
    var tapTimer:NSTimer?
    var tappedRow:Int?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //checking for double taps here
        if(tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row){
            //double tap - Put your double tap code here
            let item : Item = items[indexPath.row] as Item
            var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
            FileHelper.removeImage(itemSanitizeName)
            DatabaseHelper.deleteItem(item)
            refreshItems()
            tapTimer?.invalidate()
            tapTimer = nil
        }
        else if(tapCount == 0){
            //This is the first tap. If there is no tap till tapTimer is fired, it is a single tap
            tapCount = tapCount + 1;
            tappedRow = indexPath.row;
            tapTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: "tapTimerFired:", userInfo: nil, repeats: false)
        }
        else {
            //tap on new row
            tapCount = 0;
            if(tapTimer != nil){
                tapTimer?.invalidate()
                tapTimer = nil
            }
        }
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(items.count)
    }
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let item : Item = items[Int(index)] as Item

        var itemSanitizeName = FileHelper.sanitizeFileNameString(item.objectID.URIRepresentation().absoluteString!)
        
        
        return MWPhoto(image: FileHelper.readImage(itemSanitizeName))
    }
    
    func tapTimerFired(aTimer:NSTimer){
    //timer fired, there was a single tap on indexPath.row = tappedRow
        let item : Item = items[tappedRow!] as Item
        
        
        var browser:MWPhotoBrowser = MWPhotoBrowser(delegate: self)
        browser.setCurrentPhotoIndex(UInt(tappedRow!))
        self.showViewController(browser, sender: nil)
        
        if(tapTimer != nil){
            tapCount = 0;
            tappedRow = -1;
        }
        
        
    }


}