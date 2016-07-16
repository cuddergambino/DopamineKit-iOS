//
//  Candy.swift
//  A simple way to give users feedback and visual reinforcement.
//
//  Created by Akash Desai on 6/2/16.
//  Copyright © 2016 DopamineLabs. All rights reserved.
//

import Foundation

/// Candy is an icon that can appear on a CandyBar.
/// Look at `DopamineKit/Resources/CandyIcons.xcassets` to see what each icon looks like.
///
@objc public enum Candy : Int{
    case None = 0, Certificate, Crown, Crown2, MedalStar, RibbonStar, Stars, Stopwatch, ThumbsUp, TrophyHand, TrophyStar, WreathStar
    
    private var DopeAssetName:String?{
        switch self{
        case .None: return nil
        case .Certificate: return "certificate"
        case .Crown: return "crown"
        case .Crown2: return "crown2"
        case .MedalStar: return "medalStar"
        case .RibbonStar: return "ribbonStar"
        case .Stars: return "stars"
        case .Stopwatch: return "stopwatchOne"
        case .ThumbsUp: return "thumbsUp"
        case .TrophyHand: return "trophyHand"
        case .TrophyStar: return "trophyStar"
        case .WreathStar: return "wreathStar"
        }
    }
}

@objc public class CandyBar: Banner {
    
    /// A CandyBar with the provided `title`, `subtitle`, and an optional `image`, ready to be presented with `show()`.
    ///
    /// - parameters:
    ///     - title?: The title of the banner. Defaults to `nil`.
    ///     - subtitle?: The subtitle of the banner. Defaults to `nil`.
    ///     - image?: The image on the left of the banner. Defaults to `nil`.
    ///     - backgroundColor?: The color of the banner's background view. Defaults to `UIColor.blackColor()`.
    ///     - didTapBlock?: An action to be called when the user taps on the banner. Defaults to `nil`.
    ///
    public required init(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, backgroundColor: UIColor = UIColor.blackColor(), didTapBlock: (() -> ())? = nil) {
    
        super.init(title: title, subtitle: subtitle, image: image, backgroundColor: backgroundColor, didTapBlock: didTapBlock)
        self.position = .Bottom
    }
    
    /// A CandyBar with the provided `title`, `subtitle`, and an optional icon, ready to be presented with `show()`.
    ///
    /// - parameters:
    ///     - title?: The title of the banner. Defaults to `nil`.
    ///     - subtitle?: The subtitle of the banner. Defaults to `nil`.
    ///     - icon?: An icon, from the `Candy` class, to be displayed on the left of a candybar. Defaults to `.Stars`
    ///     - backgroundColor?: The color of the banner's background view. Defaults to `UIColor.blackColor()`.
    ///     - didTapBlock?: An action to be called when the user taps on the banner. Defaults to `nil`.
    ///
    public required init(title: String? = nil, subtitle: String? = nil, icon: Candy = .Stars, backgroundColor: UIColor = UIColor.blackColor(), didTapBlock: (() -> ())? = nil) {
        
        var retrievedImage:UIImage? = nil
        if let url = NSBundle(forClass: DopamineKit.self).URLForResource("DopamineKit", withExtension: "bundle"){
            let dkitBundle = NSBundle(URL: url)
            retrievedImage = UIImage(named: icon.DopeAssetName!, inBundle:dkitBundle, compatibleWithTraitCollection: nil)
        }
        
        super.init(title: title, subtitle: subtitle, image: retrievedImage, backgroundColor: backgroundColor, didTapBlock: didTapBlock)
        self.position = .Bottom
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Shows the candybar. If a view is specified, the candybar will be displayed at the top of that view, otherwise at top of the top window. If a `duration` is specified, the candybar dismisses itself automatically after that duration elapses.
    ///
    /// - parameter:
    ///     - view?: A view the candybar will be shown in. Defaults to `nil`, which in turn means it will be shown in the top window.
    ///     - duration?: A time interval, after which the banner will dismiss itself. Defaults to `nil`, which in turn means the user will have to tap-to-dismiss or the function `candybar.dismiss()` can be used.
    ///
    public override func show(view: UIView? = Banner.topWindow(), duration: NSTimeInterval? = nil) {
        guard let view = view else {
            print("[CandyBar]: Could not find view. Aborting.")
            return
        }
        super.show(view, duration: duration)
    }
    
    /// Dismisses the candybar.
    ///
    public override func dismiss() {
        super.dismiss()
    }
    
    
    /// This function takes a hex string and returns a UIColor
    ///
    /// - parameters:
    ///     - hex: A hex string with either format `"#ffffff"` or `"ffffff"` or `"#FFFFFF"`.
    ///
    /// - returns: 
    ///     The corresponding UIColor for valid hex strings, `UIColor.grayColor()` otherwise.
    ///
    public static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.grayColor()
        }
        
        var rgbValue:UInt32 = 0
        NSScanner(string: cString).scanHexInt(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    
}
