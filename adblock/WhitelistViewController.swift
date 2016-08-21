//
//  WhitelistViewController.swift
//  adblock
//
//  Created by tony on 06.10.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

class WhitelistViewController: UITableViewController {
    
    let ruleCellReuseIdentifier = "RuleCellReuseIdentifier"
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)

        self.tableView.editing = true;
        
        self.tableView.reloadData()
        
        self.navigationItem.title = "Whitelist".localized
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if FilterListManager.sharedInstance.whitelist.rulesArray.count > 0 {
            return 2
        }
        return 1
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return FilterListManager.sharedInstance.whitelist.rulesArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Rules".localized
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1 {
            return "For these sites the app will not activate ad blocking, tracking blocking, etc.".localized
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ruleCellReuseIdentifier, forIndexPath: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "Add new rule".localized
        }
        else {
            cell.textLabel?.text = FilterListManager.sharedInstance.whitelist.rulesArray[indexPath.row] as? String
        }
        // Configure the cell...
        return cell
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        if indexPath.section == 0 {
            return UITableViewCellEditingStyle.Insert
        }
        
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0
        {
//            let alertController = UIAlertController(title: "New Rule", message: "Paste url that wont to be ignored", preferredStyle: UIAlertControllerStyle.Alert)
//            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
//                textField.placeholder = "http://example.com"
//            }
//            let actionCancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
//            let actionSave = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                if let arr:Array = alertController.textFields {
//                    if let textField:UITextField = arr[0] {
//                        if let rule:String = textField.text {
//                            if self.verifyRule(rule) {
//                                FilterListManager.sharedInstance.whitelist.addRule(rule)
//                                self.tableView.reloadData()
//                            }
//                            else {
//                                let errorAlertController = UIAlertController(title: "Error", message: "Rule must be valid URL address", preferredStyle: UIAlertControllerStyle.Alert)
//                                let actionOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
//                                errorAlertController.addAction(actionOk)
//                                self.presentViewController(errorAlertController, animated: true, completion: nil)
//                            }
//                        }
//                    }
//                }
//            })
//            alertController.addAction(actionCancel)
//            alertController.addAction(actionSave)
//            self.presentViewController(alertController, animated: true, completion: nil)
            
            self.performSegueWithIdentifier("WhitelistRuleViewControllerSegueIdentifier", sender: nil)
        }
        else {
            let rule = FilterListManager.sharedInstance.whitelist.rulesArray[indexPath.row]
            self.performSegueWithIdentifier("WhitelistRuleViewControllerSegueIdentifier", sender: rule)
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let rule: String = FilterListManager.sharedInstance.whitelist.rulesArray[indexPath.row] as! String
            FilterListManager.sharedInstance.whitelist.removeRule(rule)
            
            if FilterListManager.sharedInstance.whitelist.rulesArray.count > 0 {
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            } else {
                tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
            }
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender is String {
            let navController = segue.destinationViewController as! UINavigationController
            let ruleController = navController.viewControllers[0] as! WhitelistRuleViewController
            ruleController.rule = sender as? String
        }
    }

}
