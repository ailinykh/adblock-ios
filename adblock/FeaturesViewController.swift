//
//  FeaturesViewController.swift
//  adblock
//
//  Created by abuharsky on 16.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import Foundation
import UIKit

class FeaturesViewController: UIViewController, UITableViewDataSource{
    
    @IBOutlet var getStartedButton: UIButton?
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStartedButton?.setTitle("Get Started".localized, forState: UIControlState.Normal)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! FeatureCell
        
        cell.backgroundColor = self.view.backgroundColor
        
        switch indexPath.row
        {
        case 0:
            cell.imageView?.image       = UIImage(named: "block_ads")
            
            cell.textLabel?.text        = "Block Ads".localized
            cell.detailTextLabel?.text  = "Block all annoying web ads, including video ads on YouTube site, Facebook ads, flashy banners, pop-ups, pop-unders and much more".localized
            break;
            
        case 1:
            cell.imageView?.image       = UIImage(named: "speed_up_loading")
            
            cell.textLabel?.text        = "Speed Up Your Browsing".localized
            cell.detailTextLabel?.text  = "Without annoying ads pages load up to 3x faster".localized
            break;
            
        case 2:
            cell.imageView?.image       = UIImage(named: "privacy")
            
            cell.textLabel?.text        = "Disable Tracking".localized
            cell.detailTextLabel?.text  = "Now you can block hundreds of ad agencies that are tracking your every move".localized
            break;
            
        case 3:
            cell.imageView?.image       = UIImage(named: "block_domains")
            
            cell.textLabel?.text        = "Block Malware Domains".localized
            cell.detailTextLabel?.text  = "Blocks domains that can steal your personal information, credit card numbers, etc.".localized
            break;
            
        default:
            break;
        }
        
        return cell
    }

}