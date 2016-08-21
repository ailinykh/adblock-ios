//
//  WhitelistRuleViewController.swift
//  adblock
//
//  Created by tony on 08.10.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    @IBOutlet var textField: UITextField?
    
}

class WhitelistRuleViewController: UITableViewController, UITextFieldDelegate {

    let textFieldCellReuseIdentifier = "TextFieldCellReuseIdentifier"
    let buttonCellReuseIdentifier = "ButtonCellReuseIdentifier"
    
    var rule: String?
    private var _ruleCandidate = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = rule == nil ? "New rule".localized : "Edit rule".localized
    }
    
    func verifyRule (str: String) -> Bool {
        do {
            try NSRegularExpression(pattern: str, options: NSRegularExpressionOptions.IgnoreMetacharacters)
        }
        catch {
            return false
        }
        return true
    }
    
    // MARK: - Text field delegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let ruleString: NSString = NSString(string: textField.text!)
        _ruleCandidate = ruleString.stringByReplacingCharactersInRange(range, withString: string)
        
        if verifyRule(_ruleCandidate) {
            textField.textColor = UIColor.blackColor()
        }
        else {
            textField.textColor = UIColor.redColor()
        }
        
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(textFieldCellReuseIdentifier, forIndexPath: indexPath)
            (cell as! TextFieldCell).textField?.delegate = self
            (cell as! TextFieldCell).textField?.becomeFirstResponder()
            if (rule != nil) {
                (cell as! TextFieldCell).textField?.text = rule
            }
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier(buttonCellReuseIdentifier, forIndexPath: indexPath)
            
            cell.textLabel!.text = "Save".localized
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 1
        {
            if verifyRule(_ruleCandidate)
            {
                if rule != nil {
                    let idx = FilterListManager.sharedInstance.whitelist.rulesArray.indexOfObject(rule!)
                    FilterListManager.sharedInstance.whitelist.replaceRuleAtIndexWithRule(idx, rule: _ruleCandidate)
                } else {
                    FilterListManager.sharedInstance.whitelist.addRule(_ruleCandidate)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                let alertController = UIAlertController(title: "Error".localized, message: "Please enter site name e.g. apple.com".localized, preferredStyle: UIAlertControllerStyle.Alert)
                let actionOK = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                alertController.addAction(actionOK)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}
