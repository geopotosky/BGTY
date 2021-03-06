//
//  FlickrTextDelegate.swift
//  BeGoodToYourself
//
//  Created by George Potosky October 2016.
//  Copyright (c) 2016 GeoWorld. All rights reserved.
//

import Foundation
import UIKit

class FlickrTextDelegate: NSObject, UITextFieldDelegate {
    
    //-Ask the delegate if the textfield should change
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        var newText: NSString = textField.text!
        newText = newText.stringByReplacingCharactersInRange(range, withString: string)
        return true;
    }
    
    //-Let the delegate know that editing has begun
    func textFieldDidBeginEditing(textField: UITextField) {
        
        //-Check to see if the initial value of the textfield is TOP. If it is, clear it.
        if textField.text == "Enter Text/Phrase" {
            textField.text = ""
        }
        
    }
    
    //-Ask the delegate if the RETURN key should be processed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
}
