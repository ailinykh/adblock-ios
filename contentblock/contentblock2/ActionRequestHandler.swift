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
        else
        {
            url = FilterListManager.sharedInstance.emptyList.url
        }
        
        let attachment = NSItemProvider(contentsOfURL:url)!
        item.attachments = [attachment]
        context.completeRequestReturningItems([item], completionHandler: nil);
    }
}