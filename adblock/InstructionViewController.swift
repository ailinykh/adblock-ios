//
//  InstructionViewController.swift
//  adblock
//
//  Created by abuharsky on 18.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}

class InstructionViewController: UIPageViewController, UIPageViewControllerDataSource {
   
    var pageTitles : Array<NSMutableAttributedString> = [NSMutableAttributedString(),NSMutableAttributedString(),NSMutableAttributedString()]
    var pageImages : Array<String> = ["page1.png", "page2.png", "page3.png"]
    var currentIndex : Int = 0

    var needShowFeatures : Bool = false
    
    var closeButton : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self

        if(NSUserDefaults.standardUserDefaults().boolForKey("FAQ_SHOWN"))
        {
            closeButton = UIButton(type: UIButtonType.System)
            closeButton!.setTitle("Close".localized, forState: UIControlState.Normal)
            closeButton!.sizeToFit()
            closeButton?.addTarget(self, action: "dismissAction", forControlEvents: UIControlEvents.TouchUpInside)
            self.view.addSubview(closeButton!)
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FAQ_SHOWN")
        }
        
        view.backgroundColor = UIColor.whiteColor()
        
        let pageControl = UIPageControl.appearance
        pageControl().pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl().currentPageIndicatorTintColor = UIColor.blackColor()
        pageControl().backgroundColor = UIColor.clearColor()

        // Do any additional setup after loading the view.
        let startingViewController: InstructionView = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [startingViewController]
        self.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: false, completion: nil)
        
        needShowFeatures = !NSUserDefaults.standardUserDefaults().boolForKey("FEATURES_SHOWN")
        
        let str1 = pageTitles[0]
        
        str1.appendAttributedString(NSAttributedString(string: "Open ".localized, attributes: [
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
            ]))
        str1.appendAttributedString(NSAttributedString(string: "\"Settings\"".localized, attributes: [
            NSFontAttributeName:UIFont.boldSystemFontOfSize(16.0)
            ]))
        str1.appendAttributedString(NSAttributedString(string: " app\nand scroll down to ".localized, attributes: [
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
            ]))
        str1.appendAttributedString(NSAttributedString(string: "\"Safari\"".localized, attributes: [
            NSFontAttributeName:UIFont.boldSystemFontOfSize(16.0)
            ]))

        pageTitles[0] = str1
        
        let str2 = pageTitles[1]
        
        str2.appendAttributedString(NSAttributedString(string: "Scroll down to ".localized, attributes: [
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
            ]))
        str2.appendAttributedString(NSAttributedString(string: "\"Content Blockers\"".localized, attributes: [
            NSFontAttributeName:UIFont.boldSystemFontOfSize(16.0)
            ]))
        
        pageTitles[1] = str2
        
        let str3 = pageTitles[2]
        
        str3.appendAttributedString(NSAttributedString(string: "Switch on ".localized, attributes: [
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
            ]))
        str3.appendAttributedString(NSAttributedString(string: "\"Ad Block\"".localized, attributes: [
            NSFontAttributeName:UIFont.boldSystemFontOfSize(16.0)
            ]))
        str3.appendAttributedString(NSAttributedString(string: "\nand enjoy browsing without ads!".localized, attributes: [
            NSFontAttributeName:UIFont.systemFontOfSize(15, weight: UIFontWeightLight)
            ]))
        
        pageTitles[2] = str3
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if(needShowFeatures)
        {
            needShowFeatures = false
            self.performSegueWithIdentifier("ShowFeatures", sender: self)
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FEATURES_SHOWN")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        closeButton?.center = CGPointMake(self.view.bounds.size.width - 40, 30)
    }
    
    func dismissAction()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! InstructionView).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count) {
            return nil
        }
        
        return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> InstructionView?
    {
        if self.pageTitles.count == 0 || index >= self.pageTitles.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InstructionView") as! InstructionView
        
        pageContentViewController.pageImageName = pageImages[index]
        pageContentViewController.pageText      = pageTitles[index]
        
        pageContentViewController.pageIndex = index
        currentIndex = index
        
        return pageContentViewController
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
}
