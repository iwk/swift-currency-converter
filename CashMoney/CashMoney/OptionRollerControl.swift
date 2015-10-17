//
//  OptionRollerControl.swift
//  CashMoney
//
//  Created by Philip Ip on 15/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit

protocol OptionRollerDelegate {
    func optionDidChange(option:String)
}

@IBDesignable 
class OptionRollerControl: UIControl {
    
    //config
    @IBInspectable var textColor: UIColor = UIColor.blackColor() {
        didSet {
            setHightLight(selectedIndex)
        }
    }
    @IBInspectable var topMarginColor: UIColor = UIColor.clearColor() {
        didSet {
            self.topMargin.backgroundColor = topMarginColor
        }
    }
    @IBInspectable var bgColor: UIColor = UIColor.clearColor() {
        didSet {
            background.backgroundColor = bgColor
        }
    }
    @IBInspectable var bottomMarginColor: UIColor = UIColor.clearColor() {
        didSet {
            bottomMargin.backgroundColor = bottomMarginColor
        }
    }
    
    var delegate:OptionRollerDelegate?
    
    let optionMarginX:CGFloat = 140
    
    var selectedIndex:Int = 2
    private var optionList:[UILabel] = [UILabel]()
    private var optionOffsetX:CGFloat = 0.0
    private var topMargin:UIView = UIView()
    private var bottomMargin:UIView = UIView()
    private var background:UIView = UIView()
    private var topIndicator:UIImageView = UIImageView(image: UIImage(named: "Indicator_1"))
    private var bottomIndicator:UIImageView = UIImageView(image: UIImage(named: "Indicator_2"))
    
    func getSelectedOption() -> String
    {
        return optionList[selectedIndex].text!
    }
    
    //init from IB
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        addUIDeco()
        
        //swipe
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(swipeRight)
    }
    
    //init from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForInterfaceBuilder() {
        addUIDeco()
        
        addOption("CAD")
        addOption("EUR")
        addOption("GBP")
        addOption("JPY")
        addOption("USD")
        refreshView()
        
    }
    
    func addUIDeco()
    {
        //top
        self.addSubview(topMargin)
        
        //bg
        
        self.addSubview(background)
        
        //bottom
        
        self.addSubview(bottomMargin)
        
        //indicators
        //topIndicator = UIImageView(image: UIImage(named: "Indicator_1"))
        //bottomIndicator = UIImageView(image: UIImage(named: "Indicator_2"))
        self.addSubview(topIndicator)
        
        self.addSubview(bottomIndicator)
        
    }
    
    
    
    
    
    func refreshView()
    {
        selectedIndex = Int(floor(Float(optionList.count/2)))
        setHightLight(selectedIndex)
        updateItemPosition(false)
    }
    
    
    //add currency
    func addOption(optionName:String)
    {
        let label = UILabel(frame: CGRectMake(0, 0, 140, 56))
        label.textAlignment = NSTextAlignment.Center
        label.text = optionName
        label.font = UIFont(name: "Helvetica Bold", size: 56)
        label.textColor = textColor
        //set id for reference
        label.tag = optionList.count
        self.addSubview(label)
        optionList.append(label)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "optionTapped:")
        label.userInteractionEnabled = true
        label.addGestureRecognizer(tapRecognizer)
    }
    
    
    
    //MARK:- handling interactions
    //tap handler
    func optionTapped(gesture: UITapGestureRecognizer)
    {
        print("tapped")
        selectedIndex = gesture.view!.tag
        updateItemPosition(true)
        setHightLight(selectedIndex)
        if (delegate != nil)
        {
            delegate?.optionDidChange(getSelectedOption())
        }
    }
    //swipe handler
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                shiftLeft()
                
            case UISwipeGestureRecognizerDirection.Right:
                shiftRight()
                
            default:
                break
            }
        }
    }
    
    
    
    
    
    //MARK:- handling state changes
    func setHightLight(index:Int)
    {
        for (var i=0; i<optionList.count;i++){
            if (i == index)
            {
                
                    optionList[i].textColor = UIColor.whiteColor()
                
                
            } else {
                
                    optionList[i].textColor = textColor
                
                
            }
        }
    }
    
    func updateItemPosition(animated:Bool)
    {
        for (var i=0; i<optionList.count;i++)
        {
            if (animated)
            {
                UIView.animateWithDuration(0.2, animations: {
                    self.optionList[i].center = CGPointMake(self.bounds.size.width/2 + CGFloat(i-self.selectedIndex) * self.optionMarginX, self.bounds.size.height/2)
                })
            } else
            {
                optionList[i].center = CGPointMake(self.bounds.size.width/2 + CGFloat(i-selectedIndex) * optionMarginX, self.bounds.size.height/2)
            }
        }
        
    }
    func resetDeco()
    {
        topIndicator.frame.origin.y = 0
        topIndicator.center.x = self.center.x
        
        bottomIndicator.frame.origin.y = self.bounds.size.height - bottomIndicator.bounds.size.height
        bottomIndicator.center.x = self.center.x
        
        topMargin.frame = CGRectMake(0, topIndicator.bounds.size.height/2, self.bounds.size.width, 2)
        background.frame = CGRectMake(0, 2+topIndicator.bounds.size.height/2, self.bounds.size.width, self.bounds.size.height-1-topIndicator.bounds.height/2 - bottomIndicator.bounds.height/2)
        bottomMargin.frame = CGRectMake(0, self.bounds.size.height-1-bottomIndicator.bounds.height/2, self.bounds.size.width, 1)
        
        
        
        
    }
    
    override func layoutSubviews() {
        updateItemPosition(false)
        resetDeco()
    }
    
    func shiftLeft()
    {
        if (selectedIndex < optionList.count - 1)
        {
            selectedIndex += 1
            setHightLight(selectedIndex)
            updateItemPosition(true)
            if (delegate != nil)
            {
                delegate?.optionDidChange(getSelectedOption())
            }
        }
    }
    
    func shiftRight()
    {
        if (selectedIndex > 0)
        {
            selectedIndex -= 1
            setHightLight(selectedIndex)
            updateItemPosition(true)
            if (delegate != nil)
            {
                delegate?.optionDidChange(getSelectedOption())
            }
        }
    }
    
    
    
    

}
