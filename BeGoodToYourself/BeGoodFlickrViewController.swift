//
//  BeGoodFlickrViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/26/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodFlickrViewController: UIViewController {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var phraseTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var flickrActivityIndicator: UIActivityIndicatorView!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //-Get the app delegate
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var events: [Events]!
    
    //-Alert variable
    var alertMessage: String!
    
    var editEventFlag2: Bool!
    var searchFlag: Bool!
    var flickrImageURL: String!
    var eventIndexPath2: NSIndexPath!
    var eventImage2: NSData!
    var currentImage: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired = 1
        
        searchFlag = false
        //searchButtonLabel.text = "Search"
        pickImageButton.hidden = true
        flickrActivityIndicator.hidden = true
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Subscribe to keyboard events so we can adjust the view to show hidden controls
        self.subscribeToKeyboardNotifications()
        
        if editEventFlag2 == false {
            self.photoImageView.image = UIImage(named: "BG_Placeholder_Image.png")
        } else {
            self.photoImageView.image = currentImage
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()
        
        //-Unsubscribe to all keyboard events
        self.unsubscribeToKeyboardNotifications()
    }

    
    
    @IBAction func searchFlicker(sender: UIButton) {
        
        println("search button pushed")
        searchFlag = true
        pickImageButton.hidden = true
        
        self.flickrActivityIndicator.hidden = false
        self.flickrActivityIndicator.startAnimating()
        
        appDelegate.phraseText = self.phraseTextField.text
        println(appDelegate.phraseText)
        
        //-Added from student request -- hides keyboard after searching
        self.dismissAnyVisibleKeyboards()
        
        //-Verify Phrase Textfield in NOT Empty
        if !self.phraseTextField.text.isEmpty {
            
            //-Update Search button text
            //self.updateSearchButton()
            
            //-Call the Get Flickr Images function
            BGClient.sharedInstance().getFlickrData(self) { (success, pictureURL, errorString) in
                
                if success {
                    
                    self.flickrImageURL = pictureURL
                    
                    println("Success! Found Image")
                    let imageURL = NSURL(string: pictureURL!)
                    
                    /* If an image exists at the url, set the image and title */
                    if let imageData = NSData(contentsOfURL: imageURL!) {
                        //let finalImage = UIImage(data: imageData)
                        self.eventImage2 = imageData
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.defaultLabel.alpha = 0.0
                            self.photoImageView.image = UIImage(data: imageData)
                            self.pickImageButton.hidden = false
                            self.flickrActivityIndicator.hidden = true
                            self.flickrActivityIndicator.stopAnimating()
                            
                        })
                        //* - Save to local file
                        //self.storeImage(finalImage, withIdentifier: pictureURL!)
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            //self.photoTitleLabel.text = "No Photos Found. Search Again."
                            //self.defaultLabel.alpha = 1.0
                            self.photoImageView.image = UIImage(named: "BG_Placeholder_Image.png")
                        })
                    }
                    
                } else {
                    //* - Call Alert message
                    self.alertMessage = "Flickr Error Message! \(errorString)"
                    self.errorAlertMessage()
                } // End success
            
            } // End VTClient method
        
        } else {
            /* If Phrase is empty, display Empty message */
            //self.photoTitleLabel.text = "Phrase Empty."
            self.alertMessage = "Search Phrase is Missing"
            self.errorAlertMessage()
        }

    }

    
    @IBAction func pickFlickrImage(sender: UIButton) {
        
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //* - Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            println(self.flickrImageURL)
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
            
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //* - Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            println(self.flickrImageURL)
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }

    
    //-Dismissing the keyboard
    func addKeyboardDismissRecognizer() {
        //-Add the recognizer to dismiss the keyboard
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        //-Remove the recognizer to dismiss the keyboard
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        //-End editing here
        self.view.endEditing(true)
    }
    
    /* Shifting the keyboard so it does not hide controls */
    func subscribeToKeyboardNotifications() {
        /* Subscribe to the KeyboardWillShow and KeyboardWillHide notifications */
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        /* Unsubscribe to the KeyboardWillShow and KeyboardWillHide notifications */
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        /* Shift the view's frame up so that controls are shown */
        if self.photoImageView.image != nil {
            //self.defaultLabel.alpha = 0.0
            println("No Photo found")
        }
//        self.view.frame.origin.y -= self.getKeyboardHeight(notification) / 2
    }
    
    func keyboardWillHide(notification: NSNotification) {
        /* Shift the view's frame down so that the view is back to its original placement */
        if self.photoImageView.image == nil {
            //self.defaultLabel.alpha = 1.0
            println("No Photo Found")
        }
//        self.view.frame.origin.y += self.getKeyboardHeight(notification) / 2
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        /* Get and return the keyboard's height from the notification */
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    //-Alert Message function
    func errorAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController: UIAlertController = UIAlertController(title: "Alert!", message: "\(self.alertMessage)", preferredStyle: .Alert)
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
    
//    //-Update the button label based on selection criteria
//    func updateSearchButton() {
//        if searchFlag == true {
//            searchButtonLabel.text = "Search Again"
//        } else {
//            searchButtonLabel.text = "Search"
//        }
//    }
    
}

//-This extension was added as a fix based on student comments */
extension BeGoodFlickrViewController {
    func dismissAnyVisibleKeyboards() {
        if phraseTextField.isFirstResponder() {
            self.view.endEditing(true)
        }
    }
}

