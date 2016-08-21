//
//  FilterList.swift
//  adblock
//
//  Created by Anthony Ilinykh on 02.10.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit
import zipzap

class FilterListType {
    static let Main = "main"
    static let Regional = "regional"
    static let Common = "common"
}

class FilterList: NSObject {

    let name:String
    let desc:String
    let type:String
    let fileName:String
    let localeIdentifier:String
    var isActive:Bool
    
    init(dict: NSDictionary) {
        name = dict["name"] as! String
        desc = dict["description"] as! String
        type = dict["type"] as! String
        fileName = dict["fileName"] as! String
        localeIdentifier = dict["locale"] as! String
        isActive = dict["isActive"] as! Bool
        super.init()
    }
    
    var zipURL: NSURL {
        get {
            return NSBundle.mainBundle().URLForResource(fileName, withExtension: "zip")!
        }
    }
    
    var url: NSURL {
        get {
            let url = FilterListManager.listsDirectoryURL.URLByAppendingPathComponent("\(fileName).json")
            if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
                do {
                    let date = NSDate()
                    let archive = try ZZArchive(URL: zipURL)
                    let firstArchiveEntry = archive.entries[0]
                    let data = try firstArchiveEntry.newData()
                    data.writeToFile(url.path!, atomically: true)
                    print(String(format: "File %@(%@) extracted for %.2f sec", url.lastPathComponent!, url.relativeFileSize, -1*date.timeIntervalSinceNow))
                } catch {
                    print("Archive extracting error! File:\(fileName)")
                }
            }
            return url
        }
    }
    
    var dictionaryRepresentation:NSDictionary {
        get {
            let dict:[String:AnyObject] = ["name":name, "description":desc, "type":type, "fileName":fileName, "locale":localeIdentifier, "isActive":isActive]
            return NSDictionary(dictionary: dict)
        }
    }
}

class EmptyList: FilterList {
    
    override var url:NSURL {
        return FilterListManager.sharedDirectoryURL.URLByAppendingPathComponent("emptylist.json")
    }
    
    init() {
        let dict:[String:AnyObject] = ["name":"Emptylist", "description":"Rules that do nothing", "type":"common", "fileName":"emptylist.plist", "locale":"", "isActive":true]
        super.init(dict: dict)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            do {
                try "[{\"action\":{\"type\":\"block\"},\"trigger\":{\"url-filter\":\"NONE\"}}]".writeToFile(url.path!, atomically: true, encoding: NSUTF8StringEncoding)
            } catch {
                SFLog.log("Can't write to emptylist.json file!")
            }
        }
    }
}

class WhiteList: FilterList {
    
    static let DidChangeNotification = "WhiteListDidChangeNotification"
    
    var rulesArray : NSArray {
        get {
            return NSArray(array: _rulesArray)
        }
    }
    
    private var _rulesArray = NSMutableArray()
    
    override var url:NSURL {
        get {
            return FilterListManager.sharedDirectoryURL.URLByAppendingPathComponent("whitelist.json")
        }
    }
    
    lazy var plistFileURL: NSURL =  {
        return FilterListManager.sharedDirectoryURL.URLByAppendingPathComponent("whitelist.plist")
    }()
    
    init() {
        let dict:[String:AnyObject] = ["name":"Whitelist", "description":"Rules for disable adblock", "locale":"", "type":"common", "fileName":"whitelist.plist", "isActive":true]
        super.init(dict: dict)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(plistFileURL.path!) {
            _saveToFile()
//            SFLog.log("File not exist! \(plistFileURL)")
        } else {
            _rulesArray = NSMutableArray(contentsOfFile: plistFileURL.path!)!
//            SFLog.log("File successfully loaded! \(plistFileURL)")
        }
    }
    
    func addRule(rule: String) {
        _rulesArray.addObject(rule.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        _saveToFile()
    }
    
    func removeRule(rule: String) {
        _rulesArray.removeObject(rule)
        _saveToFile()
    }
    
    func replaceRuleAtIndexWithRule(index: NSInteger, rule: String) {
        _rulesArray.replaceObjectAtIndex(index, withObject: rule.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()))
        _saveToFile()
    }
    
    //MARK: private
    private func _saveToFile() {
        _rulesArray.writeToFile(plistFileURL.path!, atomically: true)
        _generateJSONFile()
        NSNotificationCenter.defaultCenter().postNotificationName(WhiteList.DidChangeNotification, object: self)
    }
    
    private func _generateJSONFile() {
        let pattern = "[{\"trigger\": {\"url-filter\": \".*\",\"if-domain\": [\"%@\"]},\"action\": {\"type\": \"ignore-previous-rules\"}}]"
        let rules = String(format: pattern, _rulesArray.componentsJoinedByString("\", \""))
        do {
            try rules.writeToFile(url.path!, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            SFLog.log("Can't write to whitelist.json file!")
        }
    }
}
