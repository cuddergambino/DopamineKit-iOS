//
//  DopamineKit.swift
//  Dopamine functionality for swift
//
//  Created by Vince Enachescu on 4/7/16.
//  Copyright © 2016 Dopamine Labs. All rights reserved.
//

import Foundation

#if os(iOS)
    
    import UIKit
    
let deviceUUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
let clientOSVersion = UIDevice.currentDevice().systemVersion
let clientSDKVersion = "3.1.0"
let clientOS = "iOS-Swift"
    
    
#elseif os(OSX)
    
    import AppKit
    
let deviceUUID = NSProcessInfo().globallyUniqueString
let clientOSVersion = NSProcessInfo().operatingSystemVersionString
let clientSDKVersion = "0.0.1"
let clientOS = "OSX-Swift"
    
#endif

// constants
let DopamineDefaultsKey = "DopaminePrimaryIdentity"
let DopamineAPIURL = "https://api.usedopamine.com/v3/app/"

@objc
public class DopamineKit : NSObject{
    // Singleton configuration
    static public let instance: DopamineKit = DopamineKit()
    private let baseURL = NSURL(string: DopamineAPIURL)!
    private let session = NSURLSession.sharedSession()
    
    private static var requestContainedMetadata = false
    private static var requestContainedSecondaryID = false
    
    
    /// This function sends an asynchronous tracking call for the specified actionID
    /// - parameters:
    ///     - actionID: the name of the action
    ///     - metaData: Default `nil` - metadata as a set of key-value pairs that can be sent with a tracking call. The value should JSON formattable like an NSNumber or NSString.
    ///     - secondaryIdentity: Default `nil` - an additional idetification string
    ///     - callback: A callback function with the track HTTP response code passed in as a String. Defaults to an empty function
    public static func track(actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, callback: (String -> ()) = {_ in} ){
        self.instance.sendRequestFor("track", actionID: actionID, metaData: metaData, secondaryIdentity: secondaryIdentity, callback: callback)
    }
    
    /// This function sends an asynchronous reinforcement call for the specified actionID
    /// - parameters:
    ///     - actionID: the name of the action
    ///     - metaData: Default `nil` - metadata as a set of key-value pairs that can be sent with a tracking call. The value should JSON formattable like an NSNumber or NSString.
    ///     - secondaryIdentity: Default `nil` - an additional idetification string
    ///     - timeoutSeconds: Default 2.0 - the timeout in seconds for the connection
    ///     - callback: A callback function with the reinforcement response passed in as a String
    public static func reinforce(actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, timeoutSeconds: Float = 2.0, callback: String -> ()) {
        self.instance.sendRequestFor("reinforce", actionID: actionID, metaData: metaData, secondaryIdentity: secondaryIdentity, callback: callback)
        
        // Set variables for Tutorial reinforcements
        self.requestContainedMetadata = !(metaData==nil)
        self.requestContainedSecondaryID = !(secondaryIdentity==nil)
        
    }
    
        
    
    /// This function generates tutorial text to help devs using the Demo App become familiar with the `reinforce()` function. There is no effect if using an app registered on UseDopamine.com or if inProduction is set to true for the Demo App
    ///
    /// - parameter primaryText: The title text for a CandyBar if not in tutorial mode
    /// - parameter secondaryText: The subtitle text for a CandyBar if not in tutorial mode
    private static func ifDemoAppGetTutorialText(primaryText:String? = nil, secondaryText:String? = nil)
        -> (String?, String?)
    {
        let isDemoApp = (self.instance.requestData["appID"] as! String) == "570ffc491b4c6e9869482fbf"
        let inProduction = (self.instance.requestData["secret"] as! String) == "20af24a85fa00938a5247709fed395c31c89b142"
        if(isDemoApp && !inProduction  ){   // Is the demo app AND `inProduction` mode is set to false
            if(!self.requestContainedMetadata){
                return ("Add metadata yo", "Analyzing and reinforcing behaviors is so easy with Dopamine!")
            } else if(!self.requestContainedSecondaryID){
                return ("Add custom identification next!", "Dopamine makes it easy to integrate into your current process flow")
            } else{
                return ("Congrats! You're now certified to be Dope", "Turn `inProduction` in DopamineProperties.plist to true to finish the tutorial!")
            }
            
        }
        else{
            // Return text for normal applications and demo app with `inProduction` set to true
            return (primaryText, secondaryText)
        }
    }
    
    private override init() {
        super.init()
    }
    
    private func sendRequestFor(callType: String, actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, callback: String -> ()) {
        // create dictionary container for api call data
        var data = self.requestData
        var jsonData: NSData
        
        data["actionID"] = actionID
        data["UTC"] = NSDate().timeIntervalSince1970 * 1000
        data["localTime"] = Double(NSTimeZone.defaultTimeZone().secondsFromGMT) +
            NSDate().timeIntervalSince1970 * 1000
        
        // optional metadata and secondary indentity
        if metaData != nil {
            data["metaData"] = metaData as [String: AnyObject]!
        }
        
        if secondaryIdentity != nil {
            data["secondaryIdentity"] = secondaryIdentity!
        }
        
        do {
            jsonData = try NSJSONSerialization.dataWithJSONObject(data, options: .PrettyPrinted)
        } catch {
            NSLog("[DopamineKit]: Error composing api request type:(\(callType)) with data:(\(data))")
            return
        }
        
        let url = NSURL(string: callType, relativeToURL: baseURL)!
        let request = NSMutableURLRequest(URL: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPMethod = "POST"
        request.HTTPBody = jsonData
        
        // set up request handler
        let task = session.dataTaskWithRequest(request) { data, response, error in
            // check if request failed locally from device side
            if let httpError = error as NSError! {
                NSLog("[DopamineKit]: Error while sending request - '\(httpError.localizedDescription)'")
                return
            // check for good server (ActionHero) response
            } else if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode != 200 {
                NSLog("[DopamineKit]: Error while receiving response - Status Code:\(httpResponse.statusCode)")
                if(data != nil){
                    do {
                        let dict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! [String: AnyObject]
                        NSLog("[DopamineKit]: Error while receiving response - Response json data: \(dict)")
                    } catch {
                        NSLog("[DopamineKit]: Error while receiving response - Response data: \(data)")
                        return
                    }
                }
                return
            // handle good response
            } else{
                self.handleResponse(callType, data: data, callback: callback)
                return
            }
        }
        
        // send request
        NSLog("[DopamineKit]: sending request \(data.description)")
        task.resume()
        
    }
    
    // Only use callback for good responses
    private func handleResponse(callType: String, data: NSData?, callback: String -> ()) {
        
        // parse the json response
        let jsonOptions = NSJSONReadingOptions()
        var dict: [String: AnyObject] = [:]
        
        do {
            dict = try NSJSONSerialization.JSONObjectWithData(data!, options: jsonOptions) as! [String: AnyObject]
            if(dict.keys.contains("error") || dict.keys.contains("errors")){
                NSLog("[DopamineKit]: Error in response - Response data: \(dict)")
                return
            }
        } catch {
            NSLog("[DopamineKit]: Error reading dopamine response data: \(data)")
            return
        }
        
        // return reinforcementDecision for reinforcement, status as string for track calls
        var reinforcementDecision = ""
        switch (callType){
        case "reinforce":
            NSLog("DopamineKit server response:\(dict)")
            if let reinforcer = dict["reinforcementDecision"] as? String{
                reinforcementDecision = reinforcer
            }
            break
            
        case "track":
            NSLog("DopamineKit server response:\(dict)")
            if let status = dict["status"] as? Int{
                reinforcementDecision = status.description
            }
            break
            
        default:
            NSLog("[DopamineKit]: Error - unhandled response for \(callType): \(dict)")
            return
        }
        
        callback(reinforcementDecision)
        
    }
    
    // compile the static elements of the request call
    public var propertyListPath:String = ""
    lazy var requestData: [String: AnyObject] = {
        let DopaminePlistFile = "DopamineProperties"
        
        var dict: [String: AnyObject] = [
            "clientOS": "iOS-Swift",
            "clientOSVersion": clientOSVersion,
            "clientSDKVersion": clientSDKVersion,
            ]
        
        // load configuration details from bundled plist file
        if (self.propertyListPath == ""){
            // set the plist path to the default (main bundle)
            if let path = NSBundle.mainBundle().pathForResource(DopaminePlistFile, ofType: "plist") {
                self.propertyListPath = path
            } else {
                self.propertyListPath = ""
            }
            
        }
        
        // save values
        if let config = NSDictionary(contentsOfFile: self.propertyListPath) as? [String: AnyObject] {
            for key in ["appID", "versionID"] {
                if let value = config[key] {
                    dict[key] = value
                } else {
                    NSLog("[DopamineKit]: Error - bad appID or versionID in 'DopamineProperties.plist'")
                }
            }
            
            NSLog("DopamineKit credentials:\(dict)")
            
            // set the development/production secret key
            if config["inProduction"] as! Bool {
                dict["secret"] = config["productionSecret"] as! String
            } else {
                dict["secret"] = config["developmentSecret"] as! String
            }
            
            dict["primaryIdentity"] = self.getPrimaryIdentity()
            
        } else {
            NSLog("[DopamineKit]: Error - bad configuration in 'DopamineProperties.plist'")
        }
        
        return dict
    }()
    
    // get the primary identity as a lazy computed variable
    private func getPrimaryIdentity() -> String! {
        
        // check if a current primary identity is set in user defaults
        let defaults = NSUserDefaults.standardUserDefaults()
        if let identity = defaults.valueForKey(DopamineDefaultsKey) as? String {
            return identity
        } else {
            // if not, generate the unique identifier and save it to defaults
            let defaultIdentity = deviceUUID
            defaults.setValue(defaultIdentity, forKey: DopamineDefaultsKey)
            return defaultIdentity
        }
    }
    
}