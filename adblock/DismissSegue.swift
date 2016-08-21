//
//  DismissSegue.swift
//  adblock
//
//  Created by abuharsky on 18.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {

    override func perform() {
        self.sourceViewController.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
