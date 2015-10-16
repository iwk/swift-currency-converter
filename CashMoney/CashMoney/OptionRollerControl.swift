//
//  OptionRollerControl.swift
//  CashMoney
//
//  Created by Philip Ip on 15/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit

@IBDesignable 
class OptionRollerControl: UIControl {
    
    //config
    @IBInspectable var textColor: UIColor = UIColor(red: (74.0/255.0), green: (219.0/255), blue: (140.0/255.0), alpha: 1.0)
    @IBInspectable var topMarginColor: UIColor = UIColor(red: (74.0/255.0), green: (219.0/255), blue: (140.0/255.0), alpha: 1.0)
    @IBInspectable var bgColor: UIColor = UIColor(red: (74.0/255.0), green: (219.0/255), blue: (140.0/255.0), alpha: 1.0)
    @IBInspectable var bottomMarginColor: UIColor = UIColor(red: (74.0/255.0), green: (219.0/255), blue: (140.0/255.0), alpha: 1.0)
    
    let optionMarginX:CGFloat = 140
    
    var selectedIndex:Int = 0
    private var optionList:[UILabel] = [UILabel]()
    private var optionOffsetX:CGFloat = 0.0
    private var topMargin:UIView = UIView()
    private var bottomMargin:UIView = UIView()
    private var background:UIView = UIView()
    private var topIndicator:UIImageView!
    private var bottomIndicator:UIImageView!
    
    //init from IB
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        addUIDeco()
        initCurrencies()
    }
    
    //init from code
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func prepareForInterfaceBuilder() {
        addUIDeco()
        initCurrencies()
    }
    
    func addUIDeco()
    {
        //top
        topMargin.backgroundColor = topMarginColor
        self.addSubview(topMargin)
        
        //bg
        background.backgroundColor = bgColor
        self.addSubview(background)
        
        //bottom
        bottomMargin.backgroundColor = topMarginColor
        self.addSubview(bottomMargin)
        
        //indicators
        topIndicator = UIImageView(image: UIImage(named: "Indicator_1"))
        bottomIndicator = UIImageView(image: UIImage(named: "Indicator_2"))
        self.addSubview(topIndicator)
        self.addSubview(bottomIndicator)
    }
    
    
    
    
    //This control uses storyboard live rendering. Currency init is put here instead of view controller so that it can be viewed in storyboard dynamically in real time without running the app
    func initCurrencies()
    {
        addOption("CAD")
        addOption("EUR")
        addOption("GBP")
        addOption("JPY")
        addOption("USD")
        
        selectedIndex = Int(floor(Float(optionList.count/2)))
        setHightLight(selectedIndex)
        updateItemPosition(false)
        
        initInteractions()
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
    }
    
    
    
    /*
    HANDLING INTERACTIONS
    */
    //init recognizers
    func initInteractions()
    {
        //swipe
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        self.addGestureRecognizer(swipeRight)
        
        //tap
        for (var i=0; i<optionList.count;i++){
            let tapRecognizer = UITapGestureRecognizer(target: self, action: "optionTapped:")
            optionList[i].userInteractionEnabled = true
            optionList[i].addGestureRecognizer(tapRecognizer)
        }
   
    }
    //tap handler
    func optionTapped(gesture: UITapGestureRecognizer)
    {
        print("tapped")
        selectedIndex = gesture.view!.tag
        updateItemPosition(true)
        setHightLight(selectedIndex)
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
    
    
    
    
    /*
    HANDLING STATE CHANGES
    */
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
                UIView.animateWithDuration(0.5, animations: {
                    self.optionList[i].center = CGPointMake(self.bounds.size.width/2 + CGFloat(i-self.selectedIndex) * self.optionMarginX, self.bounds.size.height/2)
                })
            } else
            {
                optionList[i].center = CGPointMake(self.bounds.size.width/2 + CGFloat(i-selectedIndex) * optionMarginX, self.bounds.size.height/2)
            }
        }
    }
    
    override func layoutSubviews() {
        updateItemPosition(false)
    }
    
    func shiftLeft()
    {
        if (selectedIndex < optionList.count - 1)
        {
            selectedIndex += 1
            setHightLight(selectedIndex)
            updateItemPosition(true)
        }
    }
    
    func shiftRight()
    {
        if (selectedIndex > 0)
        {
            selectedIndex -= 1
            setHightLight(selectedIndex)
            updateItemPosition(true)
        }
    }
    
    
    
    

}
