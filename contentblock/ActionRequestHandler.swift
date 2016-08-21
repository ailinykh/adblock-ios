//
//  ActionRequestHandler.swift
//  contentblock
//
//  Created by abuharsky on 11.09.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit
import Foundation
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        
        let item = NSExtensionItem()
        var url: NSURL
        
        if FilterListManager.sharedInstance.isAdBlockEnabled
        {
            url = FilterListManager.sharedInstance.jsonFileURL
        }
        else {
            url = FilterListManager.sharedInstance.emptyList.url
        }
        
        let attachment = NSItemProvider(contentsOfURL:url)!
        item.attachments = [attachment]
        context.completeRequestReturningItems([item], completionHandler: nil);
        
        // MARK: TESTING
//        let str1 = "/Users/tony/Desktop/block-test.json"
//        let str2 = "/Users/tony/Desktop/whitelist-test.json"
//        let ip1 = NSItemProvider(contentsOfURL: NSURL(fileURLWithPath: str1))!
//        let ip2 = NSItemProvider(contentsOfURL: NSURL(fileURLWithPath: str2))!
//        let item = NSExtensionItem()
//        item.attachments = [ip1]
//        
//        let item2 = NSExtensionItem()
//        item2.attachments = [ip2]
//        
//        context.completeRequestReturningItems([item, item2], completionHandler: nil);
    }
}