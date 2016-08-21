//
//  RegionsViewController.swift
//  adblock
//
//  Created by tony on 13.10.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

class RegionsViewController: UITableViewController {

    let kTableViewCellReuseIdentifier = "RegionsCellIdentifier"
    let kTableViewSubtitleCellReuseIdentifier = "RegionsSubtitleCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Region".localized
//        let regions = NSMutableArray()
//        let availableLocaleIdentifiers = NSLocale.availableLocaleIdentifiers()
//        for localeIdentifier: String in availableLocaleIdentifiers {
//            let locale = NSLocale(localeIdentifier: localeIdentifier)
//            if let country = locale.displayNameForKey(NSLocaleCountryCode, value: localeIdentifier) {
//                let lang = locale.displayNameForKey(NSLocaleLanguageCode, value: localeIdentifier)
//                regions.addObject("\(localeIdentifier) \(lang)  \(country)")
//            }
//        }
//        print("\(NSLocale.availableLocaleIdentifiers())")
//        print("Current Locale:\(NSLocale.currentLocale().localeIdentifier)")
//        print("System Locale:\(NSLocale.systemLocale().localeIdentifier)")
//        print(regions)
//        regions.writeToFile("/Users/anton/Desktop/countries.txt", atomically: true)
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return FilterListManager.sharedInstance.regionalFilters.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewCellReuseIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = "Not selected".localized
            if FilterListManager.sharedInstance.localeIdentifier != "Not selected" {
                cell.accessoryType = UITableViewCellAccessoryType.None
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }
            break
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewSubtitleCellReuseIdentifier, forIndexPath: indexPath)
            let list = FilterListManager.sharedInstance.regionalFilters[indexPath.row] as! FilterList
            cell.textLabel?.text = list.name
            cell.detailTextLabel?.text = NSLocale.currentLocale().displayNameForKey(NSLocaleLanguageCode, value: list.localeIdentifier)
            cell.accessoryType = list.localeIdentifier == FilterListManager.sharedInstance.localeIdentifier ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            break
        default:
            break
        }
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            FilterListManager.sharedInstance.localeIdentifier = "Not selected"
            break
        case 1:
            let list = FilterListManager.sharedInstance.regionalFilters[indexPath.row] as! FilterList
            FilterListManager.sharedInstance.localeIdentifier = list.localeIdentifier
            break
        default:
            break
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
