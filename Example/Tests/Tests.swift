import UIKit
import XCTest
import DopamineKit
import Pods_DopamineKit_Tests

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Set the plist so DopamineKit can read the appID, versionID, production and development secrets, and the inProduction flag
        let path = NSBundle(forClass: self.dynamicType).pathForResource("DopamineDemoProperties", ofType: "plist")
        DopamineKit.instance.propertyListPath = path as String!
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    /// Test DopamineKit.reinforce() with just actionID and completion handler
    ///
    func testReinforceRequestSimple() {
        let asyncExpectation = expectationWithDescription("Reinforcement decision")
        DopamineKit.reinforce("action1", completion: {response in
            NSLog("DopamineKitTest reinforce resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: reinforce request timed out")
        })
    }
    
    /// Test DopamineKit.reinforce() with actionID, metaData, secondaryIdentity, timeout, and completion handler
    ///
    func testReinforceRequestFull() {
        let asyncExpectation = expectationWithDescription("Reinforcement decision")
        DopamineKit.reinforce("action1", metaData: ["key":"value", "number":-1.4], secondaryIdentity: "user@example.com", timeout: 2.0, completion: {response in
            NSLog("DopamineKitTest reinforce resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: reinforce request timed out")
        })
    }
    
    /// Test DopamineKit.track() with just actionID and completion handler
    ///
    func testTrackingRequestSimple() {
        let asyncExpectation = expectationWithDescription("Tracking request")
        DopamineKit.track("tracktest1", completion: {response in
            NSLog("DopamineKitTest tracking resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: track request timed out")
        })
    }
    
    /// Test DopamineKit.track() with actionID, metaData, secondaryIdentity, and completion handler
    ///
    func testTrackingRequestFull() {
        let asyncExpectation = expectationWithDescription("Tracking request")
        DopamineKit.track("tracktest2", metaData: ["key":"value", "number":2.2], secondaryIdentity: "user@example.com", completion: {response in
            NSLog("DopamineKitTest tracking resulted in:\(response)")
            asyncExpectation.fulfill()
        })
        
        waitForExpectationsWithTimeout(10, handler: {error in
            XCTAssertNil(error, "DopamineKitTest error: track request timed out")
        })
    }
    
    /// Test 10 calls in a row
    /// uses testTrackingRequestSimple()
    ///
    func testPerformanceExample() {
        self.measureBlock {
            
            let numRequests = 10
            for _ in 1...numRequests{
                self.testTrackingRequestSimple()
            }
            
        }
    }
    
    
    /// Test CandyBar init() and show(duration)
    ///
    func testCandyBar(){
        let color = CandyBar.hexStringToUIColor("#F0F0F0")
        let candybar = CandyBar(title: "Title", subtitle: "subtitle", icon: Candy.Certificate, backgroundColor: color)
        candybar.didDismissBlock = {
            NSLog("hello")
        }
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        candybar.show(view, duration: 1.0)
        //        NSThread.sleepForTimeInterval(5.2)
        //        XCTAssert(candybar.didShow())
        
    }
}
