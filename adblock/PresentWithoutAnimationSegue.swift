//
//  PresentWithoutAnimationSegue.swift
//  adblock
//
//  Created by abuharsky on 18.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

class PresentWithoutAnimationSegue: UIStoryboardSegue {

    override func perform() {
        self.sourceViewController.presentViewController(self.destinationViewController, animated: false, completion: nil)
    }
}
