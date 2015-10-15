//
//  OptionRollerControl.swift
//  CashMoney
//
//  Created by Philip Ip on 15/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit

@IBDesignable 
class OptionRollerControl: UIView {

    @IBInspectable var textColor: UIColor = UIColor(red: (74.0/255.0), green: (219.0/255), blue: (140.0/255.0), alpha: 1.0)
    
    var optionList:[UIView] = [UIView]()
    
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        //init from IB
        addOption("USD")
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //init from code
    }
    
    override func prepareForInterfaceBuilder() {
        addOption("USD")
    }
    
    
    func addOption(optionName:String)
    {
        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.center = CGPointMake(0, 0)
        label.textAlignment = NSTextAlignment.Center
        label.text = optionName
        self.addSubview(label)
    }

}
