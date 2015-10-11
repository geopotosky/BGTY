//
//  BeGoodShowViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//


import UIKit
import CoreData
import EventKit


class BeGoodShowViewController : UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var textFieldEvent: UILabel!
    @IBOutlet weak var deleteEventButton: UIBarButtonItem!
    @IBOutlet weak var editEventButton: UIBarButtonItem!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var untilEventText: UILabel!
    @IBOutlet weak var untilEventSelector: UISegmentedControl!
    @IBOutlet weak var mgFactorButon: UIButton!
    @IBOutlet weak var mgFactorLabel: UILabel!
    @IBOutlet weak var shareEventButton: UIToolbar!
    @IBOutlet weak var eventCalendarButton: UIButton!
    @IBOutlet weak var toolbarObject: UIToolbar!
    
    @IBOutlet weak var secondsTickerLabel: UILabel!
    @IBOutlet weak var secondsWordLabel: UILabel!
    @IBOutlet weak var minutesTickerLabel: UILabel!
    @IBOutlet weak var minutesWordLabel: UILabel!
    @IBOutlet weak var hoursTickerLabel: UILabel!
    @IBOutlet weak var hoursWordLabel: UILabel!
    @IBOutlet weak var daysTickerLabel: UILabel!
    @IBOutlet weak var daysWordLabel: UILabel!
    
    var events: [Events]!
    //var events: Events!
    
    //    var events: Events!
    var eventIndex:Int!
    var eventIndexPath: NSIndexPath!
    var editEventFlag: Bool!
    var mgFactorValue: Int! = 0
    
    var timeAtPress = NSDate()
    var currentDateWithOffset = NSDate()
    var count: Int!
    //var count = 180
    //var eventText: String!
    var pickEventDate: NSDate!
    var tempEventDate: NSDate!
    
    var durationSeconds: Int!
    var durationMinutes: Int!
    var durationHours: Int!
    var durationDays: Int!
    var durationWeeks: Int!
    var durationMonths: Int!
    
    var shareEventImage: UIImage!
    
    //* - Alert variable
    var alertMessage: String!
    var alertTitle: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addTodoList")
        
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image:UIImage(named:"list-33x33.png"), style:.Plain, target: self, action: "addTodoList")

        //self.toolbarObject?.backgroundColor = UIColor(red:0.69,green:0.85,blue:0.95,alpha:1.0)
        self.toolbarObject?.backgroundColor = UIColor.greenColor()
        
        //-Hide the Tab Bar
        self.tabBarController?.tabBar.hidden = true
        //-Hide the "Event Ended" message
        countDownLabel.hidden = true
        
        let b1 = UIBarButtonItem(barButtonSystemItem: .Stop, target: self,  action: "addBudgetList")
        let b2 = UIBarButtonItem(image:UIImage(named:"list-33x33.png"), style:.Plain, target: self, action: "addTodoList")
        let buttons = [b2, b1] as NSArray
        self.navigationItem.rightBarButtonItems = [b2, b1]
        
        
        fetchedResultsController.performFetch(nil)
        
        // Set the view controller as the delegate
        fetchedResultsController.delegate = self
        
        
        //-Countdown Timer routine
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        
        //-Call the "Until Date" selector method
        segmentPicked(untilEventSelector)
        
    }
    
    //Perform when view appears
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //-UnHider the main ticker
        secondsTickerLabel.hidden = false
        secondsWordLabel.hidden = false
        minutesTickerLabel.hidden = false
        minutesWordLabel.hidden = false
        hoursTickerLabel.hidden = false
        hoursWordLabel.hidden = false
        daysTickerLabel.hidden = false
        daysWordLabel.hidden = false
        countDownLabel.hidden = true
        
        
        println("BeGoodShowVC viewWillAppear")
        
        //println("memes.count: \(memes.count)")
        println("eventIndex: \(eventIndex)")
        println("eventIndexPath: \(eventIndexPath)")
        println("editEventFlag: \(editEventFlag)")
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        var dateFormatter = NSDateFormatter()
        
        let currentDate = NSDate()
        let date = event.eventDate
        let timeZone = NSTimeZone(name: "Local")
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateNew = dateFormatter.stringFromDate(date!)
        
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle //Set date style
        dateFormatter.timeZone = NSTimeZone()
        println(dateFormatter.timeZone)
        
        self.currentDateLabel.text = dateFormatter.stringFromDate(currentDate)
        let localDate = dateFormatter.stringFromDate(date!)
        self.eventDate.text = "Event Date: " + localDate
    
        let finalImage = UIImage(data: event.eventImage!)
        self.imageView!.image = finalImage
        self.textFieldEvent.text = "until " + event.textEvent!

        //-Call the main "until" setup routine
        untilCounterStart()

    }
    
    
    //-Add the "sharedContext" convenience property
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
        }()
    
    
    //-Fetched Results Controller
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Events")
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "textEvent", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
        }()
    
    
    @IBAction func segmentPicked(sender: UISegmentedControl) {
        
        var numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        switch untilEventSelector.selectedSegmentIndex {

        case 0:
            let tempText1 = numberFormatter.stringFromNumber(self.durationWeeks)!
            //let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
            untilEventText.text = ("Only \(tempText1) Weeks")
        case 1:
            //let tempText1 = numberFormatter.stringFromNumber(self.durationDays)!
            let tempText1 = String(stringInterpolationSegment: self.durationDays)
            untilEventText.text = ("Only \(tempText1) Days")
        case 2:
            let tempText1 = numberFormatter.stringFromNumber(self.durationHours)!
            //let tempText1 = String(stringInterpolationSegment: self.durationHours)
            untilEventText.text = ("Only \(tempText1) Hours")
        case 3:
            let tempText1 = numberFormatter.stringFromNumber(self.durationMinutes)!
            //let tempText1 = String(stringInterpolationSegment: self.durationMinutes)
            untilEventText.text = ("Only \(tempText1) Minutes")
        case 4:
            let tempText1 = numberFormatter.stringFromNumber(self.durationSeconds)!
            //let tempText1 = String(stringInterpolationSegment: self.durationSeconds)
            untilEventText.text = ("Only \(tempText1) Seconds")
        default:
            println("Less than 1 day left")
            
        }

    }
    
    
    //-Edit the selected event
    @IBAction func editEvent(sender: AnyObject) {
        println("Getting ready to edit the Event")
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BeGoodAddEventViewController") as! BeGoodAddEventViewController

        controller.eventIndexPath2 = eventIndexPath
        controller.eventIndex2 = eventIndex
        controller.editEventFlag = true
        

        self.navigationController!.pushViewController(controller, animated: true)
//
    }
    
    
    //-Delete the selected event
    @IBAction func deleteEvent(sender: UIBarButtonItem) {
        
        println("delete button pushed.")
        
        //-Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Warning!", message: "Do you really want to Delete the Event and it's ToDo List?", preferredStyle: .Alert)
        
        //-Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        actionSheetController.addAction(cancelAction)
        
        //-Create and add the Delete Event action
        let deleteAction: UIAlertAction = UIAlertAction(title: "Delete Meme", style: .Default) { action -> Void in
            let object = UIApplication.sharedApplication().delegate
            let appDelegate = object as! AppDelegate
            println(self.eventIndex)
            
            let event = self.fetchedResultsController.objectAtIndexPath(self.eventIndexPath) as! Events
            self.sharedContext.deleteObject(event)
            
            CoreDataStackManager.sharedInstance().saveContext()

            self.navigationController!.popViewControllerAnimated(true)
        }
        actionSheetController.addAction(deleteAction)
        
        //-Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    
    //-Countdown Time Viewer
    func update() {
        
        if(count > 0)
        {
            untilCounterUpdate()
            count = count - 1
            
            let minutes:Int = (count / 60)
            let hours:Int = ((count / 60) / 60) % 24
            let days:Int = ((count / 60) / 60) / 24
            let seconds:Int = count - (minutes * 60)
            let minutes2:Int = (count / 60) % 60
            
            let timerOutput = String(format: "%5d Days %2d:%2d:%02d", days, hours, minutes2, seconds) as String
            countDownLabel.text = timerOutput as String
            //CountDownDescription.text = eventText
            
            secondsTickerLabel.text = String(format: "%02d", seconds)
            minutesTickerLabel.text = String(format: "%02d", minutes2)
            hoursTickerLabel.text = String(format: "%02d", hours)
            daysTickerLabel.text = String(days)
            
        }
        else{
            //-Hide the main ticker and show the "Event Ended" message
            secondsTickerLabel.hidden = true
            secondsWordLabel.hidden = true
            minutesTickerLabel.hidden = true
            minutesWordLabel.hidden = true
            hoursTickerLabel.hidden = true
            hoursWordLabel.hidden = true
            daysTickerLabel.hidden = true
            daysWordLabel.hidden = true
            countDownLabel.hidden = false
            
            countDownLabel.text = "Event Has Past"
        }
        
        //------------------- UNTIL TICKER -----------------------------
        var numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
        
        switch untilEventSelector.selectedSegmentIndex {
            
        case 0:
            let tempText1 = numberFormatter.stringFromNumber(self.durationWeeks)!
            //let tempText1 = String(stringInterpolationSegment: self.durationWeeks)
            if self.durationWeeks < 2 {
                untilEventText.text = ("Only \(tempText1) Week")
            } else {
                untilEventText.text = ("Only \(tempText1) Weeks")
            }
        case 1:
            //let tempText1 = numberFormatter.stringFromNumber(self.durationDays)!
            let tempText1 = String(stringInterpolationSegment: self.durationDays)
            if self.durationDays < 2 {
                untilEventText.text = ("Only \(tempText1) Day")
            } else {
                untilEventText.text = ("Only \(tempText1) Days")
            }
        case 2:
            let tempText1 = numberFormatter.stringFromNumber(self.durationHours)!
            //let tempText1 = String(stringInterpolationSegment: self.durationHours)
            if self.durationHours < 2 {
                untilEventText.text = ("Only \(tempText1) Hour")
            } else {
                untilEventText.text = ("Only \(tempText1) Hours")
            }
        case 3:
            let tempText1 = numberFormatter.stringFromNumber(self.durationMinutes)!
            //let tempText1 = String(stringInterpolationSegment: self.durationMinutes)
            if self.durationMinutes < 2 {
                untilEventText.text = ("Only \(tempText1) Minute")
            } else {
                untilEventText.text = ("Only \(tempText1) Minutes")
            }
        case 4:
            let tempText1 = numberFormatter.stringFromNumber(self.durationSeconds)!
            //let tempText1 = String(stringInterpolationSegment: self.durationSeconds)
            if self.durationSeconds < 2 {
                untilEventText.text = ("Only \(tempText1) Second")
            } else {
                untilEventText.text = ("Only \(tempText1) Seconds")
            }
        default:
            println("Less than 1 day left")
            
        }
        
        
    }
    
    //-Update the "untils" as the countdown advances
    func untilCounterUpdate(){
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationSeconds = count
        durationMinutes = count / 60
        durationHours = (count / 60) / 60
        durationDays = ((count / 60) / 60) / 24
        durationWeeks = (((count / 60) / 60) / 24) / 7
        
    }
    
    //-Setup the "untils" based on the current date and event date for the first time
    func untilCounterStart(){

        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime)
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7
        
        //-Disable MG button is days < 2
        if durationDays < 2 {
            mgFactorLabel.enabled = false
            mgFactorButon.enabled = false
        } else {
            mgFactorLabel.enabled = true
            mgFactorButon.enabled = true
        }
        
        //-Disable Segment button if value = 0
        if durationWeeks == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 0)
        }
        if durationDays == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 1)
        }
        if durationHours == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 2)
        }
        if durationMinutes == 0 {
            untilEventSelector.setEnabled(false, forSegmentAtIndex: 3)
        }
        
        //-Set the default segment value (days)
        let tempText1 = String(stringInterpolationSegment: self.durationDays)
        
        //-Check for end of event
        if tempText1 == "-1" {
            untilEventText.text = "ZERO Days"
        } else {
            
            untilEventText.text = ("Only \(tempText1) Days")
        }
        
        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds
        
        
    }
    
    
    //-MG Factor is a special function which removes 1 days from the front of the vacation
    //-and 1 day from the back. After all, does anybody really count those days when your planning? :-)
    @IBAction func mgFactor(sender: UIButton) {
        
        //-Set the MG Factor (172800 = 2 days in seconds) and update the button label
        if mgFactorValue == 0 {
            mgFactorValue = 172800
            mgFactorLabel.text = "MG ON"
        }
        else {
            mgFactorValue = 0
            mgFactorLabel.text = "MG OFF"
        }
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        let pickerDate = event.eventDate
        let elapsedTime = pickerDate!.timeIntervalSinceDate(timeAtPress)  //* Event Date in seconds raw
        durationSeconds = Int(elapsedTime) - mgFactorValue
        durationMinutes = durationSeconds / 60
        durationHours = (durationSeconds / 60) / 60
        durationDays = ((durationSeconds / 60) / 60) / 24
        durationWeeks = (((durationSeconds / 60) / 60) / 24) / 7

        //-Set the duration count in seconds which will be used in the countdown calculation
        count = durationSeconds

    }
    
    
    //-Function to call the To Do List routine for each event
    func addTodoList(){
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TodoTableViewController") as! TodoTableViewController
        
        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
        
        controller.eventIndexPath2 = eventIndexPath
        controller.events = event

        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    //-Function to call the Budget List routine for each event
    func addBudgetList(){
        
        let storyboard = self.storyboard
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("BudgetTableViewController") as! BudgetTableViewController
        
//        let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
//        
//        controller.eventIndexPath2 = eventIndexPath
//        controller.events = event
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    //-Generate the Event Image to share
    func generateEventImage() -> UIImage {
        
        //Hide toolbar and navbar
        //navbarObject.hidden = true
        toolbarObject.hidden = true
        
        //Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let shareEventImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Hide toolbar and navbar
        //navbarObject.hidden = false
        toolbarObject.hidden = false
        
        return shareEventImage
    }
    
    
    //-Share the generated event image with other apps
    @IBAction func shareEvent(sender: UIBarButtonItem) {
        
        //-Create a event image, pass it to the activity view controller.
        self.shareEventImage = generateEventImage()
        
        let activityVC = UIActivityViewController(activityItems: [self.shareEventImage!], applicationActivities: nil)
        
        activityVC.excludedActivityTypes =  [
            UIActivityTypeSaveToCameraRoll
//            UIActivityTypePostToTwitter,
//            UIActivityTypePostToFacebook,
//            UIActivityTypePostToWeibo,
//            UIActivityTypeMessage,
//            UIActivityTypeMail,
//            UIActivityTypePrint,
//            UIActivityTypeCopyToPasteboard,
//            UIActivityTypeAssignToContact,
//            UIActivityTypeSaveToCameraRoll,
//            UIActivityTypeAddToReadingList,
//            UIActivityTypePostToFlickr,
//            UIActivityTypePostToVimeo,
//            UIActivityTypePostToTencentWeibo
        ]
        
        activityVC.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    //-
    @IBAction func addCalendarEvent(sender: UIButton) {
        println("Add Calendar Button touched")
        
        // 1
        let eventStore = EKEventStore()
        
        // 2
        switch EKEventStore.authorizationStatusForEntityType(EKEntityTypeEvent) {
        case .Authorized:
            println("authorized")
            extractEventEntityCalendarsOutOfStore(eventStore)
            insertEvent(eventStore)
        case .Denied:
            println("Access denied")
        case .NotDetermined:
            // 3
            eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion:
                {[weak self] (granted: Bool, error: NSError!) -> Void in
                    if granted {
                        self!.extractEventEntityCalendarsOutOfStore(eventStore)
                        self!.insertEvent(eventStore)
                    } else {
                        println("Access denied")
                    }
                })
        default:
            println("Case Default")
        }
        
    }
    
    func extractEventEntityCalendarsOutOfStore(eventStore: EKEventStore){
        let calendarTypes = [
        
            "Local",
            "CalDAV",
            "Exchange",
            "Subscription",
            "Birthday",
        ]
        
        let calendars = eventStore.calendarsForEntityType(EKEntityTypeEvent) as! [EKCalendar]
        for calendar in calendars{
            println("Calendar title = \(calendar.title)")
            println("Calendar typle = \(calendarTypes[Int(calendar.type.value)])")
            
            let color = UIColor(CGColor: calendar.CGColor)
            println("Calendar color = \(color)")
            
            if calendar.allowsContentModifications{
                println("This Calendar allows modifications")
            } else{
                println("This calendar does not allow modifications")
            }
            println("------------------------------")
            }
        
    }
    
//    //-Find an event source with a given type and value
//    func sourceInEventStore(
//        eventStore: EKEventStore,
//        type: EKSourceType,
//        title: String) -> EKSource?{
//            for source in eventStore.sources() as! [EKSource]{
//                if source.sourceType.value == type.value &&
//                    source.title.caseInsensitiveCompare(title) == NSComparisonResult.OrderedSame{
//                        return source
//                }
//            }
//    }
    
    
//    func calendarWithTitle(
//        title: String,
//        type: EKCalendarType,
//        source: EKSource,
//        eventType: EKEntityType) -> EKCalendar?{
//            for calendar in source.calendarsForEntityType(eventType) as [EKCalendar]{
//            //for calendar in source.calendarsForEntityType(eventType).allObjects as [EKCalendar]{
//                if calendar.title.caseInsentiveCompare(title) == NSComparisonResult.OrderedSame &&
//                    calendar.type.value == type.value{
//                        return calendar
//                }
//            }
//            return nil
//    }

    
    func insertEvent(store: EKEventStore) {
        
        let calendars = store.calendarsForEntityType(EKEntityTypeEvent)
            as! [EKCalendar]
        
        println(calendars)
        
        for calendar in calendars {
            if calendar.title == "Calendar" {

                let event = fetchedResultsController.objectAtIndexPath(eventIndexPath) as! Events
                
                //-Set the selected event start date & time
                let startDate = event.eventDate
                println("calendar start: \(startDate)")
                //-2 hours ahead for endtime
                let endDate = startDate!.dateByAddingTimeInterval(2 * 60 * 60)
                
                //-Create Calendar Event
                var calendarEvent = EKEvent(eventStore: store)
                calendarEvent.calendar = calendar
                
                calendarEvent.title = event.textEvent
                calendarEvent.startDate = startDate
                calendarEvent.endDate = endDate

                //-Save Event in Calendar
                var error: NSError?
                let result = store.saveEvent(calendarEvent, span: EKSpanThisEvent, error: &error)
                
                if result == true {
                    //* - Call Alert message
                    self.alertTitle = "SUCCESS!"
                    self.alertMessage = "Event added to your Calendar"
                    self.calendarAlertMessage()
                }
                else {
                    if let theError = error {
                        //* - Call Alert message
                        self.alertTitle = "ALERT"
                        self.alertMessage = "One of your Calendars may be restricted. Please check to see if your Calendar is updated or allow access to add events."
                        self.calendarAlertMessage()
                        println("An error occured \(theError)")
                    }
                }
            }
        }
    }
 
    
    //-Alert Message function
    func calendarAlertMessage(){
        dispatch_async(dispatch_get_main_queue()) {
            let actionSheetController = UIAlertController(title: "\(self.alertTitle)", message: "\(self.alertMessage)", preferredStyle: .Alert)
            
            //-Update alert colors and attributes
            actionSheetController.view.tintColor = UIColor.blueColor()
            let subview = actionSheetController.view.subviews.first! as! UIView
            let alertContentView = subview.subviews.first! as! UIView
            alertContentView.backgroundColor = UIColor.greenColor()
            alertContentView.layer.cornerRadius = 5;
            
            //* - Create and add the OK action
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
                //self.dismissViewControllerAnimated(true, completion: nil)
                
            }
            actionSheetController.addAction(okAction)
            
            //* - Present the AlertController
            self.presentViewController(actionSheetController, animated: true, completion: nil)
        }
    }
    
}

