//
//  FilterListManager.swift
//  adblock
//
//  Created by tony on 02.10.15.
//  Copyright © 2015 bukharskiy. All rights reserved.
//

import UIKit


extension NSURL {
    var relativeFileSize: String {
        get {
            do {
                let fileAttributes: NSDictionary = try NSFileManager.defaultManager().attributesOfItemAtPath(self.path!)
                let fileSizeNumber = fileAttributes.objectForKey(NSFileSize)
                let fileSize = fileSizeNumber?.longLongValue
                var relativeFileSize = String()
                if fileSize > 1000000 {
                    relativeFileSize = String(format: "%.2f Mb", Double(fileSize!)/1000000.0)
                } else if fileSize > 1000 {
                    relativeFileSize = String(format: "%.2f Kb", Double(fileSize!)/1000.0)
                } else {
                    relativeFileSize = "\(fileSize!) bytes"
                }
                return relativeFileSize
            } catch {
                print("error reading \(self.path) attributes")
            }
            
            return "unknown file size"
        }
    }
}

class FilterListManager: NSObject {
    
    static let sharedInstance = FilterListManager()
    static let DidChangeRegionNotification = "FilterListManagerDidChangeRegionNotification"
    
    static let DidGenerateJSONFileNotification = "FilterListManagerDidGenerateJSONFileNotification"
    static let DidTrimJSONFileNotification = "FilterListManagerDidTrimJSONFileNotification"
    static let DidWriteJSONFileNotification = "FilterListManagerDidWriteJSONFileNotification"
    
    static var sharedDirectoryURL: NSURL {
        get {
            if TARGET_IPHONE_SIMULATOR == 1 {
                return NSURL(fileURLWithPath: SFLog.logDirectory)
            }
            
            return NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(String.init(format: "group.%@", (NSBundle.mainBundle().bundleIdentifier?.stringByReplacingOccurrencesOfString(".contentblock", withString: ""))!))!
        }
    }
    
    static var listsDirectoryURL: NSURL {
        get {
            let url = FilterListManager.sharedDirectoryURL.URLByAppendingPathComponent("lists")
            var isDir : ObjCBool = false
            if !NSFileManager.defaultManager().fileExistsAtPath(url.path!, isDirectory: &isDir) {
                if !isDir {
                    do {
                        try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Can't create 'lists' directory")
                    }
                }
            }
            return url
        }
    }
    
    var filters: NSArray = NSArray()
    let whitelist: WhiteList = WhiteList()
    let emptyList: EmptyList = EmptyList()
    let jsonFileURL: NSURL = FilterListManager.sharedDirectoryURL.URLByAppendingPathComponent("blocker.json")
    var isAdBlockEnabled : Bool {
        set(newValue) {
            if TARGET_IPHONE_SIMULATOR == 1 {
                let dict = NSMutableDictionary(contentsOfFile: _plistFilePath()) as NSDictionary!
                dict.setValue(newValue, forKey: "enabled")
                dict.writeToFile(_plistFilePath(), atomically: true)
            } else {
                _defaults.setBool(newValue, forKey: "ADBLOCK_ENABLED")
                _defaults.synchronize()
            }
        }
        get {
            if TARGET_IPHONE_SIMULATOR == 1 {
                let dict = NSDictionary(contentsOfFile: _plistFilePath()) as NSDictionary!
                return (dict.valueForKey("enabled")?.boolValue)!
            }
            
            return _defaults.boolForKey("ADBLOCK_ENABLED")
        }
    }
    var isNeedToRegenerateJSON: Bool {
        get {
            return _isNeedToReGenerateJSON
        }
    }
    
    private var _isNeedToReGenerateJSON: Bool = false
    private var _localeIdentifier: String?
    var localeIdentifier: String? {
        get {
            return _localeIdentifier
        }
        set(newLocaleIdentifier) {
            if newLocaleIdentifier == localeIdentifier {
                return
            }
            for o : AnyObject in regionalFilters {
                if let f = o as? FilterList {
                    if f.localeIdentifier == newLocaleIdentifier {
                        self.changeFilterEnabledPropertyTo(f, to: true)
                    } else if f.localeIdentifier == localeIdentifier {
                        self.changeFilterEnabledPropertyTo(f, to: false)
                    }
                }
            }
            _localeIdentifier = newLocaleIdentifier
            NSUserDefaults.standardUserDefaults().setObject(_localeIdentifier, forKey: "Adblock.RegionLocaleIdentifier")
            NSNotificationCenter.defaultCenter().postNotificationName(FilterListManager.DidChangeRegionNotification, object: nil)
        }
    }
    
    private let _defaults = NSUserDefaults.init(suiteName: String.init(format: "group.%@", (NSBundle.mainBundle().bundleIdentifier?.stringByReplacingOccurrencesOfString(".contentblock", withString: ""))!))!
    
    var enabledFilters: NSArray {
        get {
            let a = NSMutableArray()
            for f : AnyObject in filters {
                if let l = f as? FilterList {
                        if l.isActive {
                        a.addObject(l)
                    }
                }
                
            }
            
            if whitelist.rulesArray.count > 0 {
                a.addObject(whitelist)
            }
            
            return NSArray(array: a)
        }
    }
    
    var availableFilters: NSArray {
        get {
            let a = NSMutableArray()
            for f : AnyObject in filters {
                if let l = f as? FilterList {
                    if l.type != FilterListType.Regional {
                        a.addObject(l)
                    }
                    else if l.localeIdentifier == localeIdentifier {
                        a.addObject(l)
                    }
                }
                
            }
            return NSArray(array: a)
        }
    }
    
    var regionalFilters: NSArray {
        get {
            let a = NSMutableArray()
            for f : AnyObject in filters {
                if let l = f as? FilterList {
                    if l.type == FilterListType.Regional {
                        a.addObject(l)
                    }
                }
                
            }
            return NSArray(array: a)
        }
    }
    
    override init() {
        super.init()
        filters = _loadFilters()
        
        if let l = NSUserDefaults.standardUserDefaults().stringForKey("Adblock.RegionLocaleIdentifier") {
            _localeIdentifier = l
        }
        
        let isFirstLaunch = !NSUserDefaults.standardUserDefaults().boolForKey("Adblock.isNotFirstLaunch")
        if isFirstLaunch {
            _isNeedToReGenerateJSON = true
            for o : AnyObject in filters {
                if let f = o as? FilterList {
                    if f.type == FilterListType.Regional {
                        let flang = f.localeIdentifier.componentsSeparatedByString("_").first
                        let lang = NSLocale.currentLocale().localeIdentifier.componentsSeparatedByString("_").first
                        if flang?.lowercaseString == lang?.lowercaseString {
                            self.localeIdentifier = f.localeIdentifier
                            self.changeFilterEnabledPropertyTo(f, to: true)
                        }
                    } else {
                        self.changeFilterEnabledPropertyTo(f, to: true)
                    }
                }
            }
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "Adblock.isNotFirstLaunch")
        }
    }
    
    func changeFilterEnabledPropertyTo(filter:FilterList, to:Bool) {
        filter.isActive = to
        for o : AnyObject in filters {
            if let f = o as? FilterList {
                if f.name == filter.name {
                    let mutableArray = NSMutableArray(array: filters)
                    mutableArray.replaceObjectAtIndex(filters.indexOfObject(f), withObject: filter)
                    filters = NSArray(array: mutableArray)
                    _isNeedToReGenerateJSON = true
                    _saveFilters()
                    break
                }
            }
        }
    }
    
    func generateJSONFile() {
        _isNeedToReGenerateJSON = false
        var allRules: AnyObject = NSNull()
        var date = NSDate()
        if self.enabledFilters.count > 0 && isAdBlockEnabled {
            for obj : AnyObject in self.enabledFilters {
                if let list = obj as? FilterList {
                    let data = NSData(contentsOfURL: list.url)
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                        if allRules is NSNull {
                            allRules = json
                        } else {
                            (allRules as! NSMutableArray).addObjectsFromArray(json as [AnyObject])
                        }
                    } catch {
                        print("Cant read Rules from list:\(list.name)")
                    }
                }
            }
            NSNotificationCenter.defaultCenter().postNotificationName(FilterListManager.DidGenerateJSONFileNotification, object: nil)
            print(String(format: "JSON generated for %.2f sec", -1*date.timeIntervalSinceNow))
            date = NSDate()
            // Extension compilation failed: Too many rules in JSON array
            if allRules.count > 50000 {
                allRules.removeObjectsInRange(NSMakeRange(10000, allRules.count-50000))
            }
            NSNotificationCenter.defaultCenter().postNotificationName(FilterListManager.DidTrimJSONFileNotification, object: nil)
            print(String(format: "JSON trimmed for %.2f sec", -1*date.timeIntervalSinceNow))
            date = NSDate()
        } else {
            let data = NSData(contentsOfURL: emptyList.url)
            do {
                allRules = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
            } catch {
                print("Cant read Rules from empty list")
            }
        }
        let outputStream = NSOutputStream(toFileAtPath: jsonFileURL.path!, append: false)!
        outputStream.open()
        NSJSONSerialization.writeJSONObject(allRules, toStream: outputStream, options: NSJSONWritingOptions.init(rawValue: 0), error: nil)
        outputStream.close()
        NSNotificationCenter.defaultCenter().postNotificationName(FilterListManager.DidWriteJSONFileNotification, object: nil)
        print(String(format: "JSON writed for %.2f sec", -1*date.timeIntervalSinceNow))
        print("\(allRules.count) rules in blocker.json size of \(jsonFileURL.relativeFileSize)")
    }
    
    //MARK: Private
    
    private func _loadFilters() -> NSArray {
        if TARGET_IPHONE_SIMULATOR == 1 {
            return _loadFiltersFromPlist()
        }
        else {
            if let obj1 = _defaults.objectForKey("Adblock.filters") {
                if let arr = obj1 as? NSArray {
                    let mutableArray = NSMutableArray()
                    for obj2 : AnyObject in arr {
                        if let dictionary = obj2 as? NSDictionary {
                            mutableArray.addObject(FilterList(dict: dictionary))
                        }
                    }
                    return NSArray(array: mutableArray)
                }
            }
            else {
                return _loadFiltersFromPlist()
            }
        }
        
        return NSArray()
    }
    
    private func _saveFilters() {
        if TARGET_IPHONE_SIMULATOR == 1 {
            _saveFiltersToPlist()
        } else {
            _defaults.setObject(_arrayOfDictionaries(), forKey: "Adblock.filters")
        }
    }
    
    private func _loadFiltersFromPlist() -> NSArray {
        print("Loading filters from .plist file")
        let dict = NSDictionary(contentsOfFile: _plistFilePath()) as NSDictionary!
        if let arr:NSArray = dict.objectForKey("filters") as? NSArray {
            let a = NSMutableArray()
            for o : AnyObject in arr {
                if let d = o as? NSDictionary {
                    let list = FilterList(dict: d)
                    a.addObject(list)
                }
            }
            return NSArray(array: a)
        }
        return NSArray()
    }
    
    private func _arrayOfDictionaries() -> NSArray {
        let a = NSMutableArray()
        for o : AnyObject in filters {
            if let f = o as? FilterList {
                a.addObject(f.dictionaryRepresentation)
            }
        }
        return NSArray(array: a)
    }
    
    //MARK: IPHONE SIMULATOR METHODS
    
    private func _saveFiltersToPlist() {
        let dict = NSMutableDictionary(contentsOfFile: _plistFilePath()) as NSMutableDictionary!
        dict["filters"] = _arrayOfDictionaries()
        if dict.writeToFile(_plistFilePath(), atomically: true) {
            print("Plist file saved! Active filters:\(enabledFilters.count)")
        } else {
            print("Plist file saving error occured")
        }
    }
    
    private func _plistFilePath() -> String {
        var plistFilePath = NSBundle.mainBundle().pathForResource("FilterList", ofType: "plist") as String!
        if TARGET_IPHONE_SIMULATOR == 1 {
            let plistFileSimulatorPath = SFLog.logDirectory + "/FilterList.plist"
            if !NSFileManager.defaultManager().fileExistsAtPath(plistFileSimulatorPath) {
                do {
                    try NSFileManager.defaultManager().copyItemAtPath(plistFilePath, toPath: plistFileSimulatorPath)
                } catch {
                    print("Error creating plist file! \(plistFilePath)")
                }
            }
            plistFilePath = plistFileSimulatorPath
        }
        return plistFilePath
    }
}

class SFLog: NSObject {
    
    static var logDirectory: String {
        let home = NSString(string: "~").stringByExpandingTildeInPath
        let components = home.componentsSeparatedByString("/")
        return String(format: "/%@/%@/Desktop", components[1], components[2])
    }
    
    class func log(message: String) {
        let filePath = String(format: "%@/sflog.txt", SFLog.logDirectory)
        do {
            let content = NSMutableString()
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                let log = try NSMutableString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
                content.appendFormat("%@", log)
            }
            content.appendFormat("%@\n", message)
            try content.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        } catch {
            print("Can't read or write log file! \(filePath)")
        }
    }
}
