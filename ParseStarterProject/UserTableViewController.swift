//
//  UserTableViewController.swift
//  ParseStarterProject
//
//  Created by TangWeichang on 9/22/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var usernames = [String]()
    var recipientUsername = ""
    
    func checkForMessage() {
        //print("checked")
        if PFUser.currentUser()?.username != nil {
            var query = PFQuery(className:"image")
            query.whereKey("recipientUsername", equalTo: (PFUser.currentUser()?.username)!)
            var images = query.findObjects()
            
            if let pfObjects = images as? [PFObject] {
                if pfObjects.count > 0 {
                    
                    var imageView: PFImageView = PFImageView()
                    imageView.file = pfObjects[0]["photo"] as! PFFile
                    imageView.loadInBackground({
                        (photo, error) -> Void in
                        if error == nil {
                            var senderUsername = "Unknown User"
                            if let username = pfObjects[0]["senderUsername"] as? String {
                                senderUsername = username
                                
                            }
                            var alert = UIAlertController(title: "You have a message", message: "Message from " + senderUsername, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                                
                                // fade out the background
                                let backgroundView = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                backgroundView.backgroundColor = UIColor.blackColor()
                                backgroundView.alpha = 0.8
                                backgroundView.tag = 10
                                backgroundView.contentMode = UIViewContentMode.ScaleAspectFit
                                self.view.addSubview(backgroundView)
                                
                                
                                let displayedImage = UIImageView(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
                                displayedImage.image = photo
                                displayedImage.tag = 10
                                displayedImage.contentMode = UIViewContentMode.ScaleAspectFit
                                self.view.addSubview(displayedImage)
                                
                                pfObjects[0].delete()
                                
                                _ = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: Selector("hideMessage"), userInfo: nil, repeats: false)
                                
                            }))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        }
                    )
                }
                
            }

            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("checkForMessage"), userInfo: nil, repeats: true)
        
        // Do not have the fancy ways of error handling
        var query = PFUser.query()!
        query.whereKey("username", notEqualTo: PFUser.currentUser()!.username!)
        var users = query.findObjects()
        for user in users as! [PFUser] {
            usernames.append(user.username!)
        }
        
        tableView.reloadData()

    }
    
    func hideMessage() {
        //remove images by using tag number 10
        for subview in self.view.subviews {
            if subview.tag == 10 {
                subview.removeFromSuperview()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        cell.textLabel?.text = usernames[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        recipientUsername = usernames[indexPath.row]
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        var imageToSend = PFObject(className: "image")
        imageToSend["photo"] = PFFile(name: "photo.jpg", data: UIImageJPEGRepresentation(image, 0.5)!)
        imageToSend["senderUsername"] = PFUser.currentUser()?.username
        imageToSend["recipientUsername"] = recipientUsername
        let acl = PFACL()
        acl.setPublicReadAccess(true)
        acl.setPublicWriteAccess(true)
        imageToSend.ACL = acl
        imageToSend.save()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "logOut" {
            PFUser.logOut()
        }
    }
    

}
