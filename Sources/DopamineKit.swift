//
//  DopamineKit.swift
//  Dopamine functionality for swift
//
//  Created by Vince Enachescu on 4/7/16.
//  Copyright © 2016 Dopamine Labs. All rights reserved.
//

import Foundation
import UIKit
    
let deviceUUID = UIDevice.currentDevice().identifierForVendor!.UUIDString
let clientOSVersion = UIDevice.currentDevice().systemVersion
let clientSDKVersion = "4.0.0.beta"
let clientOS = "iOS"

// constants
let DopamineDefaultsKey = "DopaminePrimaryIdentity"
let DopamineAPIURL = "https://api.usedopamine.com/v3/app/"

@objc
public class DopamineKit : NSObject{
    
    // Singleton configuration
    public static let instance: DopamineKit = DopamineKit()
    private let baseURL = NSURL(string: DopamineAPIURL)!
    private let session = NSURLSession.sharedSession()
    
    private static var requestContainedMetadata = false
    private static var requestContainedSecondaryID = false
    
    
    /// This function sends an asynchronous tracking call for the specified actionID
    ///
    /// - parameters:
    ///     - actionID: Descriptive name of the action.
    ///     - metaData?: Event info as a set of key-value pairs that can be sent with a tracking call. The value should JSON formattable like an NSNumber or NSString. Defaults to `nil`.
    ///     - secondaryIdentity?: An additional idetification string. Defaults to `nil`.
    ///     - completion?: Mostly used for debugging, it is a closure with the track HTTP response code passed in as a `String`. Defaults to an empty closure.
    ///
    public static func track(actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, completion: (String) -> () = {_ in} ){
        self.instance.sendRequest("track", actionID: actionID, metaData: metaData, secondaryIdentity: secondaryIdentity, timeout: 2.5, completion: completion)
    }
    
    /// This function sends an asynchronous reinforcement call for the specified actionID
    ///
    /// - parameters:
    ///     - actionID: Descriptive name of the action.
    ///     - metaData?: Event info as a set of key-value pairs that can be sent with a tracking call. The value should JSON formattable like an NSNumber or NSString. Defaults to `nil`.
    ///     - secondaryIdentity?: An additional idetification string. Defaults to `nil`.
    ///     - timeoutSeconds?: Default 2.0 - the timeout in seconds for the connection
    ///     - completion: A closure with the reinforcement response passed in as a `String`.
    ///
    public static func reinforce(actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, timeout: NSTimeInterval! = 2.5, completion: (String) -> ()) {
        self.instance.sendRequest("reinforce", actionID: actionID, metaData: metaData, secondaryIdentity: secondaryIdentity, timeout: timeout, completion: completion)
        
        // Set variables for Tutorial reinforcements
        self.requestContainedMetadata = !(metaData==nil)
        self.requestContainedSecondaryID = !(secondaryIdentity==nil)
        
    }
    
    
    /// Initializes the DopamineKit singleton. 
    /// Sets the path for the credential file, which can be changed by DopamienKit.instance.propertyListPath = "path/to/dopamine/creds".
    ///
    private override init() {
        super.init()
        // load configuration details from bundled plist file
        // note: in XCTests, point propertyListPath to a file in the test bundle i.e.
        //      DopamineKit.instance.propertyListPath = NSBundle(forClass: self.dynamicType).pathForResource("DopamineProperties", ofType: "plist")!
        if (self.propertyListPath == ""){
            // set the plist path to the default (main bundle)
            if let path = NSBundle.mainBundle().pathForResource("DopamineProperties", ofType: "plist") {
                self.propertyListPath = path
            }
        }
    }
        
    
    /// This function generates tutorial text to help devs using the Demo App become familiar with the `reinforce()` function. 
    ///
    /// There is no effect if using an app registered on UseDopamine.com or if inProduction is set to true for the Demo App credentials
    ///
    /// - parameters:
    ///     - primaryText: The title text for a CandyBar if not in tutorial mode.
    ///     - secondaryText: The subtitle text for a CandyBar if not in tutorial mode.
    ///
    private static func ifDemoAppGetTutorialText(primaryText:String? = nil, secondaryText:String? = nil)
        -> (String?, String?)
    {
        let isDemoApp = (self.instance.configurationData["appID"] as! String) == "570ffc491b4c6e9869482fbf"
        let inProduction = (self.instance.configurationData["secret"] as! String) == "20af24a85fa00938a5247709fed395c31c89b142"
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
    
    
    /// This function sends a request to the DopamineAPI
    ///
    /// - parameters:
    ///     - callType: "track" or "reinforce".
    ///     - actionID: Descriptive name of the action.
    ///     - metaData?: Event info as a set of key-value pairs that can be sent with a tracking call. The value should JSON formattable like an NSNumber or NSString. Defaults to `nil`.
    ///     - secondaryIdentity?: An additional idetification string. Defaults to `nil`.
    ///     - completion: A closure with the reinforcement response passed in as a `String`.
    ///
    private func sendRequest(callType: String, actionID: String, metaData: [String: AnyObject]? = nil, secondaryIdentity: String? = nil, timeout:NSTimeInterval, completion: String -> ()) {
        
        // create dictionary for api call
        var payload = self.configurationData
        payload["actionID"] = actionID
        payload["metaData"] = metaData
        payload["secondaryIdentity"] = secondaryIdentity
        let curTime = NSDate().timeIntervalSince1970
        payload["UTC"] = curTime * 1000
        payload["localTime"] = ( curTime + Double(NSTimeZone.defaultTimeZone().secondsFromGMT) ) * 1000
        
        if let url = NSURL(string: callType, relativeToURL: baseURL){
            do {
                let request = NSMutableURLRequest(URL: url)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPMethod = "POST"
                request.timeoutInterval = timeout
                let jsonPayload = try NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
                request.HTTPBody = jsonPayload
                
                // set up request handler
                let task = session.dataTaskWithRequest(request) { responseData, urlResponse, error in
                    if let httpError = error as NSError! {
                        // handle bad request
                        DopamineKit.DebugLog("Error while sending \(callType) request - '\(httpError.localizedDescription)'")
                        return
                    } else if let httpResponse = urlResponse as? NSHTTPURLResponse where httpResponse.statusCode != 200 {
                        // handle bad response
                        DopamineKit.DebugLog("Error while receiving \(callType) response - Status Code:\(httpResponse.statusCode)")
                        return
                    } else if let data = responseData{
                        // handle good response
                        self.handleResponse(callType, data: data, completion: completion)
                        return
                    } else {
                        // catch all, should never reach here
                        DopamineKit.DebugLog("Error while receiving \(callType) response - no data")
                        return
                    }
                }
                // send request
                DopamineKit.DebugLog("Sending \(callType) request with payload: \(payload.description)")
                task.resume()
                
            } catch {
                DopamineKit.DebugLog("Error composing \(callType) request with payload:(\(payload.description))")
                return
            }
        } else {
            DopamineKit.DebugLog("Error with base url:(\(baseURL))")
        }
        
    }
    
    // Only use completion for good responses
    private func handleResponse(callType: String, data: NSData?, completion: String -> ()) {
        
        // parse the json response into a dictionary
        var response: [String: AnyObject] = [:]
        
        do {
            // turn the dictionary into a json object
            response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! [String: AnyObject]
            DopamineKit.DebugLog("DopamineKit \(callType) response:\(response)")
            if(response.keys.contains("errors")){
                DopamineKit.DebugLog("[DopamineKit]: Error in \(callType) response - Response data: \(response["errors"])")
                return
            }
        } catch {
            DopamineKit.DebugLog("[DopamineKit]: Error reading dopamine \(callType) response data: \(data)")
            return
        }
        
        // return reinforcementDecision for reinforcement, status as string for track calls
        var reinforcementDecision = ""
        switch (callType){
        case "reinforce":
            if let reinforcer = response["reinforcementDecision"] as? String{
                reinforcementDecision = reinforcer
            }
            break
            
        case "track":
            if let status = response["status"] as? Int{
                reinforcementDecision = status.description
            }
            break
            
        default:
            DopamineKit.DebugLog("[DopamineKit]: Error - unhandled response for \(callType): \(response)")
            return
        }
        
        completion(reinforcementDecision)
        
    }
    
    public var propertyListPath:String = ""
    
    // compile the static elements of the request call
    lazy var configurationData: [String: AnyObject] = {
        var dict: [String: AnyObject] = [
            "clientOS": "iOS-Swift",
            "clientOSVersion": clientOSVersion,
            "clientSDKVersion": clientSDKVersion,
            ]
        
        // get values from .plist
        if let dopaminePlist = NSDictionary(contentsOfFile: self.propertyListPath) as? [String: AnyObject] {
            
            if let inProduction = dopaminePlist["inProduction"] as? Bool {
                for key in ["appID", "versionID"] {
                    if let value = dopaminePlist[key] as? String {
                        dict[key] = value
                    } else {
                        DopamineKit.DebugLog("Error - bad \((key)) in \((self.propertyListPath))")
                    }
                }
                if(inProduction){
                    if let secret = dopaminePlist["productionSecret"] as? String {
                        dict["secret"] = secret
                    } else {
                        DopamineKit.DebugLog("Error - bad (productionSecret) in 'DopamineProperties.plist'")
                    }
                } else {
                    if let secret = dopaminePlist["developmentSecret"] as? String {
                        dict["secret"] = secret
                    } else {
                        DopamineKit.DebugLog("Error - bad (developmentSecret) in 'DopamineProperties.plist'")
                    }
                }
            } else {
                DopamineKit.DebugLog("Error - bad (productionSecret) in 'DopamineProperties.plist'")
            }
        } else {
            DopamineKit.DebugLog("[DopamineKit]: Error - cannot find credentials in (\(self.propertyListPath))")
        }
        
        dict["primaryIdentity"] = self.getPrimaryIdentity()
        
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
    
    internal static func DebugLog(message: String,  fileName: String = #file, function: String =  #function, line: Int = #line) {
        //#if DEBUG
            var functionSignature:String = function
            if let parameterNames = functionSignature.rangeOfString("\\((.*?)\\)", options: .RegularExpressionSearch){
                functionSignature.replaceRange(parameterNames, with: "()")
            }
            NSLog("[\((fileName as NSString).lastPathComponent):\(line):\(functionSignature)] - \(message)")
        //#endif
    }

}