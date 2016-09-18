//
//  TodoAddTableViewController.swift
//  BeGoodToYourself
//
//  Created by George Potosky Octobern 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//


import UIKit
import CoreData


class TodoAddTableViewController: UITableViewController {
    
    //-View Outlet
    @IBOutlet weak var editModelTextField: UITextField!
    
    //-Global objects, properties & variables
    var events: Events!
    var editedModel:String?
    
    
    //-Perform when view did load
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    
    //-Table view data source
    
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
            if indexPath.section == 0 && indexPath.row == 0 {
                editModelTextField.becomeFirstResponder()
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //-Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "saveDataAdd" {
            editedModel = editModelTextField.text
        }
        print("Segue Error")

    }
    
    
}


