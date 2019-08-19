//
//  SSTSwitchColors.swift
//  SSTSwitch
//
//  Created by Ye Wai Yan on 8/1/19.
//  Copyright © 2019 Ye Wai Yan. All rights reserved.
//

import UIKit

extension UIColor {
    static let materialOnKnob = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 1)
    static let materialOnCrease = UIColor(red: 0/255, green: 150/255, blue: 136/255, alpha: 0.5)
    static let materialOffKnob = UIColor(red: 241/255, green: 241/255, blue: 241/255, alpha: 1)
    static let materialOffCrease = UIColor(red: 34/255, green: 31/255, blue: 31/255, alpha: 0.26)
    
    static let iOSOnCrease = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
    static let iOSOffCrease = UIColor(red: 120/255, green: 120/255, blue: 128/255, alpha: 0.16)
    
    static let iOSCreaseBorder = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
}


/** Loops through all the subviews and removes them all */
extension UIView {
    func removeAllChildViews() {
        for view in self.subviews {
            view.removeFromSuperview()
        }
    }
}
