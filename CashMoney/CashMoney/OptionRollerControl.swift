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
    
    //set colors of elements in interface builder
    @IBInspectable var textColor: UIColor = UIColor.black {
        didSet {
            setHightLight(index: selectedIndex)
        }
    }
    @IBInspectable var topMarginColor: UIColor = UIColor.clear {
        didSet {
            self.topMargin.backgroundColor = topMarginColor
        }
    }
    @IBInspectable var bgColor: UIColor = UIColor.clear {
        didSet {
            background.backgroundColor = bgColor
        }
    }
    @IBInspectable var bottomMarginColor: UIColor = UIColor.clear {
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
        
        //swipe guestures
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.addGestureRecognizer(swipeRight)
        
        //finished init, wait for adding options in view controller
    }
    
    //init from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForInterfaceBuilder() {
        addUIDeco()
        
        addOption(optionName: "CAD")
        addOption(optionName: "EUR")
        addOption(optionName: "GBP")
        addOption(optionName: "JPY")
        addOption(optionName: "USD")
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
        self.addSubview(topIndicator)
        self.addSubview(bottomIndicator)
        
    }
    
    
    
    
    
    func refreshView()
    {
        selectedIndex = Int(floor(Float(optionList.count/2)))
        setHightLight(index: selectedIndex)
        updateItemPosition(animated: false)
    }
    
    
    //add currency
    func addOption(optionName:String)
    {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 56))
        label.textAlignment = NSTextAlignment.center
        label.text = optionName
        label.font = UIFont(name: "Helvetica Bold", size: 56)
        label.textColor = textColor
        //set id for reference
        label.tag = optionList.count
        self.addSubview(label)
        optionList.append(label)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "optionTapped:")
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapRecognizer)
    }
    
    
    
    //MARK:- handling interactions
    //tap handler
    func optionTapped(gesture: UITapGestureRecognizer)
    {
        print("tapped")
        selectedIndex = gesture.view!.tag
        updateItemPosition(animated: true)
        setHightLight(index: selectedIndex)
        if (delegate != nil)
        {
            delegate?.optionDidChange(option: getSelectedOption())
        }
    }
    //swipe handler
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                shiftLeft()
                
            case UISwipeGestureRecognizer.Direction.right:
                shiftRight()
                
            default:
                break
            }
        }
    }
    
    
    
    
    
    //MARK:- handling state changes
    func setHightLight(index:Int)
    {
     
        if optionList.count == 0 {return}
        for i in 0...optionList.count-1 {
        
            if (i == index)
            {
                    optionList[i].textColor = UIColor.white
                
            } else {
                optionList[i].textColor = textColor
            }
        }
    }
    
    func updateItemPosition(animated:Bool)
    {
        if optionList.count == 0 {return}
        for i in 0...optionList.count-1 {
            if (animated)
            {
                UIView.animate(withDuration: 0.2, animations: {
                    self.optionList[i].center = CGPoint(x: self.bounds.size.width/2 + CGFloat(i-self.selectedIndex) * self.optionMarginX, y: self.bounds.size.height/2)
                })
            } else
            {
                optionList[i].center = CGPoint(x: self.bounds.size.width/2 + CGFloat(i-selectedIndex) * optionMarginX, y: self.bounds.size.height/2)
            }
        }
        
    }
    func resetDeco()
    {
        topIndicator.frame.origin.y = 0
        topIndicator.center.x = self.center.x
        
        bottomIndicator.frame.origin.y = self.bounds.size.height - bottomIndicator.bounds.size.height
        bottomIndicator.center.x = self.center.x
        
        topMargin.frame = CGRect(x: 0, y: topIndicator.bounds.size.height/2, width: self.bounds.size.width, height: 2)
        background.frame = CGRect(x: 0, y: 2+topIndicator.bounds.size.height/2, width: self.bounds.size.width, height: self.bounds.size.height-1-topIndicator.bounds.height/2 - bottomIndicator.bounds.height/2)
        bottomMargin.frame = CGRect(x: 0, y: self.bounds.size.height-1-bottomIndicator.bounds.height/2, width: self.bounds.size.width, height: 1)
        
    }
    
    override func layoutSubviews() {
        updateItemPosition(animated: false)
        resetDeco()
    }
    
    //try to shift position triggered by swipe guestures
    func shiftLeft()
    {
        if (selectedIndex < optionList.count - 1)
        {
            selectedIndex += 1
            setHightLight(index: selectedIndex)
            updateItemPosition(animated: true)
            if (delegate != nil)
            {
                delegate?.optionDidChange(option: getSelectedOption())
            }
        }
    }
    func shiftRight()
    {
        if (selectedIndex > 0)
        {
            selectedIndex -= 1
            setHightLight(index: selectedIndex)
            updateItemPosition(animated: true)
            if (delegate != nil)
            {
                delegate?.optionDidChange(option: getSelectedOption())
            }
        }
    }
    
    
    
    

}
