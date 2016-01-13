//
//  Events.swift
//  BeGoodToYourself
//
//  Created by George Potosky on 9/19/15.
//  Copyright (c) 2015 GeoWorld. All rights reserved.
//

import UIKit
import CoreData

@objc(Events)


class Events : NSManagedObject {
    
    @NSManaged var eventDate: NSDate?
    @NSManaged var textEvent: String?
    @NSManaged var eventImage: NSData?
    @NSManaged var textCalendarID: String?
    @NSManaged var todoList: [TodoList]
    @NSManaged var budget: [Budget]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(eventDate: NSDate?, textEvent: String?, eventImage: NSData?, textCalendarID: String?, context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Events", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        self.eventDate = eventDate
        self.textEvent = textEvent
        self.eventImage = eventImage
        self.textCalendarID = textCalendarID
        
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.eventDate!) == NSComparisonResult.OrderedDescending) // deadline is earlier than current date
    }
}
