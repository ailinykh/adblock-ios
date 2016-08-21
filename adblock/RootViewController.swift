//
//  ViewController.swift
//  adblock
//
//  Created by abuharsky on 11.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit
import SafariServices
import MBProgressHUD

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let kTableViewRightDetailCellReuseIdentifier = "ADBlockRightDetailCellReuseIdentifier"
    let kTableViewSubtitleCellReuseIdentifier = "ADBlockSubtitleCellReuseIdentifier"
    let kTableViewUpdateCellReuseIdentifier = "ADBlockUpdatesCellIdentifier"
    let kTableViewCellReuseIdentifier = "ADBlockCellIdentifier"
    
    @IBOutlet weak var _enableButton: RAMPaperSwitch?
    @IBOutlet weak var _titleLabel: UILabel?
    @IBOutlet weak var tableView: UITableView!
    var _spinnerBarItem: UIBarButtonItem?
    var _spinner: UIActivityIndicatorView?
    var _needShowInstruction: Bool?
    var _statusBarStyle: UIStatusBarStyle = UIStatusBarStyle.Default
    
    var backgroundTask:UIBackgroundTaskIdentifier = 0
    
    var isNeedToReloadFilters: Bool = false
    var HUD: MBProgressHUD = MBProgressHUD()

    override func preferredStatusBarStyle() -> UIStatusBarStyle
    {
        return _statusBarStyle
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation
    {
        return UIStatusBarAnimation.Fade
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        _spinner = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        _spinner?.startAnimating()
        _spinnerBarItem = UIBarButtonItem.init(customView: _spinner!)
        
        _needShowInstruction = !NSUserDefaults.standardUserDefaults().boolForKey("INSTRUCTION_SHOWN")
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { (notification) -> Void in
            self.tableView.reloadData()
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(WhiteList.DidChangeNotification, object: nil, queue: nil) { (notification) -> Void in
            self.isNeedToReloadFilters = true
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(FilterListManager.DidChangeRegionNotification, object: nil, queue: nil) { (notification) -> Void in
            self.isNeedToReloadFilters = true
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(FilterListManager.DidGenerateJSONFileNotification, object: nil, queue: nil) { (notification) -> Void in
            self.HUD.progress = 0.1
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(FilterListManager.DidTrimJSONFileNotification, object: nil, queue: nil) { (notification) -> Void in
            self.HUD.progress = 0.2
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(FilterListManager.DidWriteJSONFileNotification, object: nil, queue: nil) { (notification) -> Void in
            self.HUD.progress = 0.6
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        self._updateFilters()
        self.navigationController?.toolbar.hidden = true // there are no updates yet
        
        if (_needShowInstruction == true)
        {
            _needShowInstruction = false
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "INSTRUCTION_SHOWN")
            self.performSegueWithIdentifier("ShowInstruction", sender: self)
            
            // enable by default
            FilterListManager.sharedInstance.isAdBlockEnabled = true
        }
        
        _enableButton?.on = FilterListManager.sharedInstance.isAdBlockEnabled
        _updateTitleText()
        self.tableView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if isNeedToReloadFilters {
            _reloadFilters()
            isNeedToReloadFilters = false
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.presentedViewController == nil {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    private func _updateTitleText() {
        self.navigationItem.title = nil
        
        let string = NSMutableAttributedString()
        
        if _enableButton!.on
        {
            _statusBarStyle = UIStatusBarStyle.Default
            
            string.appendAttributedString(
                NSAttributedString(string: "Ad Block".localized,
                    attributes: [NSFontAttributeName : UIFont.systemFontOfSize(19.0, weight: UIFontWeightBold), NSForegroundColorAttributeName : UIColor.blackColor() ]))
            
            string.appendAttributedString(NSAttributedString(string: "\n"))
            
            string.appendAttributedString(
                NSAttributedString(string: "enabled".localized,
                    attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight), NSForegroundColorAttributeName : UIColor.darkGrayColor() ]))
        }
        else
        {
            _statusBarStyle = UIStatusBarStyle.LightContent
            
            string.appendAttributedString(
                NSAttributedString(string: "Ad Block".localized,
                    attributes: [NSFontAttributeName : UIFont.systemFontOfSize(19.0, weight: UIFontWeightBold), NSForegroundColorAttributeName : UIColor.whiteColor() ]))
            
            string.appendAttributedString(NSAttributedString(string: "\n"))
            
            string.appendAttributedString(
                NSAttributedString(string: "disabled".localized,
                    attributes: [NSFontAttributeName : UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight), NSForegroundColorAttributeName : UIColor(white: 1.0, alpha: 0.85)]))
        }
        
        setNeedsStatusBarAppearanceUpdate()

        UIView.animateWithDuration(0.35) { () -> Void in
            self._titleLabel?.attributedText = string
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
//        if(!UIApplication.sharedApplication().isRegisteredForRemoteNotifications())
//        {
//            return 5
//        }
        
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return FilterListManager.sharedInstance.availableFilters.count
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 36
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewRightDetailCellReuseIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = "Region".localized
            cell.detailTextLabel?.text = "Not selected".localized

            if FilterListManager.sharedInstance.localeIdentifier != "Not selected" {
                for o : AnyObject in FilterListManager.sharedInstance.regionalFilters {
                    if let f = o as? FilterList {
                        if f.localeIdentifier == FilterListManager.sharedInstance.localeIdentifier {
                            cell.detailTextLabel?.text = f.name
                            break
                        }
                    }
                }
            }
            
            break
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewSubtitleCellReuseIdentifier, forIndexPath: indexPath)
            let list:FilterList = FilterListManager.sharedInstance.availableFilters[indexPath.row] as! FilterList
            
            if indexPath.row == 1 && FilterListManager.sharedInstance.localeIdentifier != "Not selected" && FilterListManager.sharedInstance.localeIdentifier != nil
            {
                cell.textLabel?.text = "Region Filter".localized
                cell.detailTextLabel?.text = list.name.localized
            } else {
                cell.textLabel?.text = list.name.localized
                cell.detailTextLabel?.text = list.desc.localized
            }
            
            
            cell.accessoryType = list.isActive ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            
            if(_enableButton!.on)
            {
                cell.contentView.alpha = 1.0
                cell.selectionStyle = UITableViewCellSelectionStyle.Default
                cell.tintColor = nil
            }
            else
            {
                cell.contentView.alpha = 0.3
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.tintColor = UIColor.lightGrayColor()
            }

            break
        case 2:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewCellReuseIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = "Whitelist".localized
            break
//        case 3:
//            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewCellReuseIdentifier, forIndexPath: indexPath)
//            cell.textLabel?.text = "FAQ".localized
//            break
//        case 4:
//            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewUpdateCellReuseIdentifier, forIndexPath: indexPath)
//            cell.textLabel?.text = "Ad filters update".localized
//            break
        default:
            cell = tableView.dequeueReusableCellWithIdentifier(kTableViewCellReuseIdentifier, forIndexPath: indexPath)
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.section {
        case 0:
            self.performSegueWithIdentifier("RegionsSegueIdentifier", sender: nil)
            break
        case 1:
            if(_enableButton!.on)
            {
                let list = FilterListManager.sharedInstance.availableFilters[indexPath.row] as! FilterList
                FilterListManager.sharedInstance.changeFilterEnabledPropertyTo(list, to: !list.isActive)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                self._reloadFilters()
            }
            break
        case 2:
            self.performSegueWithIdentifier("WhiteListSegueIdentifier", sender: nil)
            break
        case 3:
            self.performSegueWithIdentifier("ShowInstruction", sender: nil)
            break
        case 4:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            if(!UIApplication.sharedApplication().isRegisteredForRemoteNotifications())
            {
                let alertController = UIAlertController(title: "Enable Notifications".localized, message: "App notifications must be enabled in order to receive ad filter updates.\nTo enable notifications go to device settings - App - Notifications".localized, preferredStyle: .Alert)
                
                let cancelAction = UIAlertAction(title: "Dismiss".localized, style: .Cancel) { (action:UIAlertAction!) in
                    print("you have pressed the Cancel button");
                }
                alertController.addAction(cancelAction)
                
                let OKAction = UIAlertAction(title: "Open Settings".localized, style: .Default) { (action:UIAlertAction!) in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion:nil)
            }
            break
        default:
            break
        }
    }

    @IBAction func enableAction(sender: UISwitch) {
        FilterListManager.sharedInstance.isAdBlockEnabled = sender.on
        _updateTitleText()
        self._reloadFilters()
        self.tableView.reloadData()
    }
    
    @IBAction func infoAction()
    {
        self.performSegueWithIdentifier("ShowInstructionAnimated", sender: nil)
    }
    
    func _reloadFilters()
    {
        if _enableButton!.on
        {
            backgroundTask = UIApplication.sharedApplication().beginBackgroundTaskWithName("ReloadFiltersBackgroundTask") { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask)
                self.backgroundTask = UIBackgroundTaskInvalid
            }
            
            HUD = MBProgressHUD.init(view: self.navigationController?.view)
            HUD.mode = MBProgressHUDMode.AnnularDeterminate
            if self.view.window != nil {
                self.navigationController?.view.addSubview(HUD)
            }
            HUD.show(true)
            _increaseHUDProgress()
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if FilterListManager.sharedInstance.isNeedToRegenerateJSON {
                FilterListManager.sharedInstance.generateJSONFile()
            } else {
                print("JSON file is actual")
            }
            
            let date = NSDate()
            
            SFContentBlockerManager
                .reloadContentBlockerWithIdentifier(String.init(format: "%@.contentblock", NSBundle.mainBundle().bundleIdentifier!)) {
                    (error) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        print(String(format: "filters apply time: %.2f sec", -date.timeIntervalSinceNow))
                        
                        if UIApplication.sharedApplication().applicationState == UIApplicationState.Background {
                            let localNotification = UILocalNotification()
                            localNotification.alertBody = "All filters updated".localized
                            localNotification.fireDate = NSDate()
                            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
                        }
                        
                        UIApplication.sharedApplication().endBackgroundTask(self.backgroundTask)
                        self.backgroundTask = UIBackgroundTaskInvalid
                        
                        if ((error) != nil) {
                            self.HUD.hide(true)
                        } else {
                            self.HUD.customView = UIImageView(image:UIImage(named: "37x-Checkmark.png"))
                            self.HUD.mode = MBProgressHUDMode.CustomView
                            self.HUD.labelText = "Completed".localized
                            self.HUD.hide(true, afterDelay: 0.5)
                        }

                    })
                    
                    if ((error) != nil)
                    {
                        NSLog("%@", error!);
                    }
            }
        }
    }
    
    func _increaseHUDProgress() {
        NSObject.cancelPreviousPerformRequestsWithTarget(self)
        HUD.progress += 0.01
        if self.backgroundTask != UIBackgroundTaskInvalid {
            self.performSelector("_increaseHUDProgress", withObject: nil, afterDelay: 0.2)
        }
    }
}

