//
//  BeGoodFlickrViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import UIKit

class BeGoodFlickrViewController: UIViewController, UISearchBarDelegate {
    
    //-View Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var pickImageButton: UIButton!
    @IBOutlet weak var flickrActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flickrActivityFrame: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tempImage: UIImageView!
    
    //-Global objects, properties & variables
    var events: [Events]!
    var editEventFlag2: Bool!
    var searchFlag: Bool!
    var flickrImageURL: String!
    var eventIndexPath2: NSIndexPath!
    var eventImage2: NSData!
    var currentImage: UIImage!
    var tapRecognizer: UITapGestureRecognizer? = nil

    
    //-Set the textfield delegates
    let flickrTextDelegate = FlickrTextDelegate()
    
    //-Get the app delegate (used for Flickr API)
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //-Alert variable
    var alertMessage: String!
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //-Set Navbar Title
        self.navigationItem.title = "Flicker Picker"
        
        //-Initialize the tapRecognizer in viewDidLoad
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BeGoodFlickrViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired = 1
        
        searchFlag = false
        pickImageButton.hidden = true
        flickrActivityIndicator.hidden = true
        flickrActivityFrame.hidden = true
        
        searchBar.delegate = self
        
    }
    
    
    //-Perform when view will appear
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-Add tap recognizer to dismiss keyboard
        self.addKeyboardDismissRecognizer()
        
        //-Display the current or default event image
        if editEventFlag2 == false {
            self.tempImage.hidden = false
        } else {
            self.tempImage.hidden = true
            self.photoImageView.image = currentImage
        }
    }
    
    
    //-Perform when view will disappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //-Remove tap recognizer
        self.removeKeyboardDismissRecognizer()

    }

    
    
    //-Call the Flicker Search API with Search Bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchFlag = true
        pickImageButton.hidden = true
        self.tempImage.hidden = true
        
        self.flickrActivityFrame.layer.cornerRadius = 47
        self.flickrActivityFrame.backgroundColor = UIColor.whiteColor()
        self.flickrActivityFrame.hidden = false
        self.flickrActivityIndicator.hidden = false
        self.flickrActivityIndicator.startAnimating()
        
        
        //-Set the Flickr Text Phrase for API search
        appDelegate.phraseText = self.searchBar.text
        
        //-Added from student request -- hides keyboard after searching
        self.dismissAnyVisibleKeyboards()
        
        //-Verify Phrase Textfield in NOT Empty
        
        print(self.searchBar.text)
        
        if self.searchBar.text!.isEmpty {
            
            self.flickrActivityIndicator.hidden = true
            self.flickrActivityIndicator.stopAnimating()
            //-If Phrase is empty, display Empty message
            self.alertMessage = "Search Phrase is Missing"
            self.errorAlertMessage()
            
        } else {
            
            //-Call the Get Flickr Images function
            BGClient.sharedInstance().getFlickrData(self) { (success, pictureURL, errorString) in
                
                if success {
                    
                    self.flickrImageURL = pictureURL
                    let imageURL = NSURL(string: pictureURL!)
                    
                    //-If an image exists at the url, set the image and title
                    if let imageData = NSData(contentsOfURL: imageURL!) {
                        self.eventImage2 = imageData
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.photoImageView.image = UIImage(data: imageData)
                            self.tempImage.hidden = true
                            self.pickImageButton.hidden = false
                            self.flickrActivityIndicator.hidden = true
                            self.flickrActivityFrame.hidden = true
                            self.flickrActivityIndicator.stopAnimating()
                        })
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.tempImage.hidden = false
                        })
                    }
                    
                } else {
                    //-Call Alert message
                    self.alertMessage = "\(errorString!)"
                    self.errorAlertMessage()
                } //-End success
                
            } //-End VTClient method
            
        }
        
    }


    //-Pick the selected image button
    @IBAction func pickFlickrImage(sender: UIButton) {
        
        //-If edit event flag is set to true, then prep for return to Add VC for existing event
        if editEventFlag2 == true {
            let controller = self.navigationController!.viewControllers[2] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
            
        //-If edit event flag is set to false, then prep for return to Add VC for new event
        } else {
            let controller = self.navigationController!.viewControllers[1] as! BeGoodAddEventViewController
            //-Forward selected event date to previous view
            controller.flickrImageURL = self.flickrImageURL
            controller.flickrImage = self.photoImageView.image
            controller.imageFlag = 3

            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }

    
    //-Dismissing the keyboard methods
    
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
    
    
    //-Alert Message function
    func errorAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController: UIAlertController = UIAlertController(title: "Alert!", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
            self.flickrActivityIndicator.hidden = true
            self.flickrActivityIndicator.stopAnimating()
            self.flickrActivityFrame.hidden = true
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first! 
            let alertContentView = subview.subviews.first! 
            alertContentView.backgroundColor = UIColor(red:0.6,green:1.0,blue:0.6,alpha:1.0)
            alertContentView.layer.cornerRadius = 5;
            
            //-Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            }
            actionSheetController.addAction(okAction)
            
            //-Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
}

//-This extension was added as a fix based on student comments
extension BeGoodFlickrViewController {
    func dismissAnyVisibleKeyboards() {
        if searchBar.isFirstResponder() {
            self.view.endEditing(true)
        }
    }
}

