//
//  ViewController.swift
//  DopamineTestApp
//
//  Created by Akash Desai on 7/13/16.
//  Copyright © 2016 UseDopamine. All rights reserved.
//

import UIKit
import DopamineKit

class ViewController: UIViewController {
    
    var responseLabel:UILabel = UILabel()
    var action1Button:UIButton = UIButton()
    var trackedActionButton:UIButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBasicUI()
    }
    
    func action1Performed(){
        
        // Reinforce the action to make it sticky!!
        DopamineKit.reinforce("action1", callback: {response in
            // So we don't run on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                
                // Update UI to display reinforcement decision on screen for learning purposes
                self.responseLabel.text = response
                self.flash(self.responseLabel)
                
                
                // Try out CandyBar as a form of reinforcement!
                var reinforcerType:Candy
                var title:String?
                var subtitle:String?
                var backgroundColor:UIColor = UIColor.blueColor()
                var visibilityDuration:NSTimeInterval = 1.75
                
                // Set up a couple of different responses to keep your users surprised
                switch(response){
                case "medalStar":
                    reinforcerType = Candy.MedalStar
                    title = "You should drop an album soon"
                    subtitle = "Cuz you're on 🔥"
                    break
                case "stars":
                    reinforcerType = Candy.Stars
                    title = "Great workout 💯"
                    subtitle = "It's not called sweating, it's called glisenting"
                    backgroundColor = UIColor.orangeColor()
                    break
                case "thumbsUp":
                    reinforcerType = Candy.ThumbsUp
                    title = "Awesome run!"
                    subtitle = "Either you run the day,\nOr the day runs you."
                    backgroundColor = CandyBar.hexStringToUIColor("#ff0000")
                    visibilityDuration = 2.5
                    break
                default:
                    return
                }
                
                // Woo hoo! Treat yoself
                let candyBar = CandyBar.init(title: title, subtitle: subtitle, icon: reinforcerType, backgroundColor: backgroundColor)
                // if `nil` or no duration is provided, the CandyBar will go away when the user clicks on it or `.dismiss()` is used
                candyBar.show(duration: visibilityDuration)
                
            })
        })
    }
    
    
    func action2Performed(){
        // Tracking call is sent asynchronously
        DopamineKit.track("action2")
    }
    
    
    func loadBasicUI(){
        let viewSize = self.view.frame.size
        let viewCenter = self.view.center
        
        // Dopamine icon
        let dopamineIcon = UIImage(named: "BrainLogo")
        let imageView = UIImageView(image: dopamineIcon)
        imageView.center = CGPointMake(viewSize.width/2, 100)
        self.view.addSubview(imageView)
        
        // Response label
        responseLabel = UILabel.init(frame: CGRectMake(0, 150, viewSize.width, 50))
        responseLabel.text = "Click a button below!"
        responseLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(responseLabel)
        
        // Reinforced action button
        action1Button = UIButton.init(frame: CGRectMake(0, 0, viewSize.width/3, viewSize.width/6+10))
        action1Button.center = CGPointMake(viewSize.width/4, viewCenter.y)
        action1Button.layer.cornerRadius = 5
        action1Button.setTitle("Reinforce some triggered action", forState: UIControlState.Normal)
        action1Button.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        action1Button.titleLabel?.textAlignment = NSTextAlignment.Center
        action1Button.backgroundColor = UIColor.init(red: 51/255.0, green: 153/255.0, blue: 51/255.0, alpha: 1.0)
        action1Button.addTarget(self, action: #selector(ViewController.action1Performed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(action1Button)
        
        // Tracked action button
        trackedActionButton = UIButton.init(frame: CGRectMake(0, 0, viewSize.width/3, viewSize.width/6+10))
        trackedActionButton.center = CGPointMake(viewSize.width/4*3, viewCenter.y)
        trackedActionButton.layer.cornerRadius = 5
        trackedActionButton.setTitle("Track some other action", forState: UIControlState.Normal)
        trackedActionButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        trackedActionButton.titleLabel?.textAlignment = NSTextAlignment.Center
        trackedActionButton.backgroundColor = UIColor.init(red: 204/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
        trackedActionButton.addTarget(self, action: #selector(ViewController.action2Performed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(trackedActionButton)
        
        
    }
    
    func flash(elm:UIView){
        elm.alpha = 0.0
        UIView.animateWithDuration(0.75, delay: 0.0, options: [.CurveEaseInOut, .AllowUserInteraction], animations: {() -> Void in
            elm.alpha = 1.0
            }, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
}

