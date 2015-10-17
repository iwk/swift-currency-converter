//
//  ViewController.swift
//  CashMoney
//
//  Created by Philip Ip on 14/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UITextFieldDelegate, JsonLoaderDelegate, OptionRollerDelegate {
    
    @IBOutlet weak var txtOutputAmount: UITextField!
    
    @IBOutlet weak var txtInputAmount: UITextField!
    
    @IBOutlet weak var currencyControl: OptionRollerControl!
    var inputNumber:Double = 0
    var outputNumber:Double = 0
    
    let INPUT_CHAR_LIMIT = 20
    let DECIMAL_LIMIT = 8
    
    var currencyData:NSDictionary?
    
    @IBOutlet weak var controlTopConstrain: NSLayoutConstraint!
    
    @IBOutlet weak var textTopConstrain: NSLayoutConstraint!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //status bar color
        self.setNeedsStatusBarAppearanceUpdate()
        
        //load and check data from DataManager and wait for callback -> jsonLoaded
        DataManager.sharedInstance.delegate = self
        DataManager.sharedInstance.loadJsonFromUrl("https://api.fixer.io/latest")
        //delegate -> jsonLoaded or jsonFailed
        
        
        //custom constrains for iphone4. Other iphones and ipad constrains are configured in storyboard
        updateConstrainsForSmallphones()

    }
    
    
    func updateConstrainsForSmallphones()
    {
        if (UIScreen.mainScreen().bounds.size.height <= 480.0) {
            self.view.layoutIfNeeded()
            textTopConstrain.constant = 20
            controlTopConstrain.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    func jsonLoaded(json: NSDictionary) {
        print("json")
        currencyData = json
        dispatch_async(dispatch_get_main_queue(), {
            //main queue update ui and states
            self.initControls()
        })
    }
    func jsonFailed(message:String) {
        print("error message received")
        print(message)
    }
    
    
    
    func initControls()
    {
        //stop loading animation
        self.activityIndicator.stopAnimating()
        
        //setup caculator model
        ExchangeCalculator.sharedInstance.addCurrencyWithValue("EUR", value: 1.0 )
        for currencyCode in ["AUD","CAD","GBP", "JPY", "USD"]
        {
            //verify JSON format
            do {
                guard let _ = currencyData!["rates"]?[currencyCode]! else { throw DataManager.JSONError.UnexpectedElement }
                ExchangeCalculator.sharedInstance.addCurrencyWithValue(currencyCode, value: (currencyData!["rates"]?[currencyCode]) as! Double )
            } catch {
                print(error)
            }
            
        }
        
        
        //setup view
        currencyControl.delegate = self
        for currencyCode in ["CAD", "EUR", "GBP", "JPY", "USD"]
        {
            currencyControl.addOption(currencyCode)
        }
        currencyControl.refreshView()
        
        
        //enable interactions
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        txtInputAmount.delegate = self
        txtInputAmount.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        formatInputCurrency()
        convert()
        drawDashedUnderline()
        
    }
    
    func drawDashedUnderline()
    {
        let color = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1).CGColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = txtInputAmount.frame.size
        let lineWidth = (frameSize.width - (frameSize.width % 18))
        let shapeRect = CGRect(x: 0, y: 0, width: lineWidth, height: 1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height)
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 3
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [10,8]
        //for rect
        //shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).CGPath
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(lineWidth, 0))
        shapeLayer.path = path.CGPath
        txtInputAmount.layer.addSublayer(shapeLayer)
    }
    
    
    
    
    //process and format input while user is editing textfield
    /* sepcial cases:
    filtering non number characters
    enable intermediate trailing decimial 0 during input
    enable trailing .
    filter duplicated .
    format empty string
    limit to max length
    handle super small double out of range
    */
    func textFieldDidChange(textField:UITextField){
        
        print("=========")
        let inputText:String = textField.text!
        var processedText:String = ""
        var outputText:String = ""
        var trailingDecimalZero = 0
        var decimalPlace = 0
        
        print("inputText: "+inputText)
        
        //filter duplicated .
        var isDecimal = false
        for c in inputText.characters
        {
            if ( c == ".") {
                if (isDecimal) {
                    //ignore duplicated .
                } else {
                    //append only first "."
                    isDecimal = true
                    processedText.append(c)
                }
            } else {
                //count decimal place
                if (isDecimal) {
                    decimalPlace++
                }
                //count trailing zeros
                if (decimalPlace <= DECIMAL_LIMIT)
                {
                    //append character
                    processedText.append(c)
                    
                    //count decimal 0
                    if (c == "0" && isDecimal)
                    {
                        trailingDecimalZero++
                    } else
                    {
                        trailingDecimalZero = 0
                    }
                }
                
            }
        }
        
        //filter invalid characters
        let validSet:NSCharacterSet = NSCharacterSet(charactersInString: "0123456789.")
        processedText = processedText.stringByTrimmingCharactersInSet(validSet.invertedSet)
        processedText = processedText.stringByReplacingOccurrencesOfString(",", withString: "")
        
        //handle empty string
        if (processedText == "")
        {
            processedText = "0"
        }
        
        //format display
        let lastChar = processedText.substringFromIndex(processedText.endIndex.predecessor())
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.maximumSignificantDigits = 99
        formatter.maximumFractionDigits = 6
        formatter.currencyCode = "USD"
        
        
        let processedNumber:Double = Double.init(processedText)!
        print("processed number: \(processedNumber)")
        
        
        
        
        if (lastChar == ".")
        {
            //format tailing .
            processedText = formatter.stringFromNumber(processedNumber)!
            processedText = processedText + "."
        } else
            if (lastChar == "0" && isDecimal)
            {
                //format tailing decimial 0
                
                processedText = formatter.stringFromNumber(processedNumber)!
                print("processedText: "+processedText)
                
                //prevent formatter from removing .0 while user is still entering 0
                if (processedNumber % 1 == 0)
                {
                    processedText = processedText+"."
                }
                
                //append trailing zeros
                for var i = 0; i < trailingDecimalZero; i++ {
                    processedText = processedText+"0"
                    print("add 0")
                }
                
                
            }else
            {
                //format normal case
                processedText = " "+formatter.stringFromNumber(processedNumber)!
                
                
        }
        
        //show text
        outputText = processedText
        print("outputText: "+outputText)
        textField.text = outputText
        inputNumber = processedNumber
        convert()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //status bar color
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    
    //dismiss keyboard
    func dismissKeyboard(){
        view.endEditing(true)
        
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //format input after editing, e.g. remove trailing zeros
    func textFieldDidEndEditing(textField: UITextField) {
        formatInputCurrency()
    }
    
    //reserver the "$" when textfield is empty
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = "$"
    }
    
    
    //prevent change when max character is reached
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //test new string by NSString function
        let newCharacter:NSString = NSString(string: string)
        let originalString:NSString = NSString(string: txtInputAmount.text!)
        let newString = originalString.stringByReplacingCharactersInRange(range, withString: newCharacter as String)
        
        
        if (newString.characters.count > INPUT_CHAR_LIMIT)
        {
            return false
        } else
        {
            return true
        }
        
    }
    
    
    
    func optionDidChange(option: String) {
        print(option)
        convert()
        
        
    }
    
    func convert()
    {
        outputNumber = ExchangeCalculator.sharedInstance.getCurrencyValue("AUD", toCurrencyCode: currencyControl.getSelectedOption(), amount: inputNumber)
        formatOuputCurrency()
    }
    
    
    func formatOuputCurrency(){
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = currencyControl.getSelectedOption()
        formatter.maximumFractionDigits = 2
        txtOutputAmount.text = formatter.stringFromNumber(outputNumber)
    }
    
    
    
    func formatInputCurrency(){
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.currencyCode = "USD"
        //formatter.maximumSignificantDigits = 99
        formatter.maximumFractionDigits = 6
        //print(inputNumber)
        txtInputAmount.text = formatter.stringFromNumber(inputNumber)
        
    }
    
    
    
    
    
    
}

/*
extension Double {
/// Rounds the double to decimal places value
func floorToPlaces(places:Int) -> Double {
let divisor = pow(10.0, Double(places))
return floor(self * divisor) / divisor
}
}*/