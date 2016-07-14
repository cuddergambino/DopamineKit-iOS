//
//  DopamineKitTests.swift
//  DopamineKitTests
//
//  Created by Akash Desai on 6/3/16.
//  Copyright © 2016 DopamineLabs. All rights reserved.
//

import XCTest


@testable import DopamineKit

class DopamineKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Set the plist so DopamineKit can read the AppID, API keys, ...
        let path = NSBundle(forClass: self.dynamicType).pathForResource("DopamineProperties", ofType: "plist")
        DopamineKit.instance.propertyListPath = path as String!
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Test DopamineKit.reinforce()
    func testReinforceRequestSimple() {
        let asyncExpectation = expectationWithDescription("Reinforcement decision")
        DopamineKit.reinforce("action1", callback: {response in
            NSLog("DopamineKitTest reinforce resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: reinforce request timed out")
        })
    }
    func testReinforceRequestFull() {
        let asyncExpectation = expectationWithDescription("Reinforcement decision")
        DopamineKit.reinforce("action1", metaData: ["key":"value", "number":-1.4], secondaryIdentity: "user@example.com", timeoutSeconds: 2.0, callback: {response in
            NSLog("DopamineKitTest reinforce resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: reinforce request timed out")
        })
    }
    
    // Test DopamineKit.track()
    func testTrackingRequestSimple() {
        let asyncExpectation = expectationWithDescription("Tracking request")
        DopamineKit.track("tracktest1", callback: {response in
            NSLog("DopamineKitTest tracking resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: track request timed out")
        })
    }
    func testTrackingRequestFull() {
        let asyncExpectation = expectationWithDescription("Tracking request")
        DopamineKit.track("tracktest2", metaData: ["key":"value", "number":2.2], secondaryIdentity: "user@example.com", callback: {response in
            NSLog("DopamineKitTest tracking resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: track request timed out")
        })
    }
    
    func testPerformanceExample() {
        self.measureBlock {
            
            let numRequests = 10
            for _ in 1...numRequests{
                self.testTrackingRequestSimple()
            }
            
        }
    }
    
    
    
    func testCandyBar(){
        let color = CandyBar.hexStringToUIColor("#F0F0F0")
        let candybar = CandyBar(title: "Title", subtitle: "subtitle", icon: Candy.Certificate, backgroundColor: color)
        candybar.didDismissBlock = {
            NSLog("hello")
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        candybar.show(view, duration: 1.0)
//        NSThread.sleepForTimeInterval(5.2)
//        XCTAssert(candybar.didShow())

    }
}


