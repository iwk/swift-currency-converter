//
//  ViewController.swift
//  CashMoney
//
//  Created by Philip Ip on 14/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtOutputAmount: UITextField!
    
    @IBOutlet weak var txtInputAmount: UITextField!
    
    var inputNumber:Double = 10.00008
    
    let INPUT_CHAR_LIMIT = 20
    let DECIMAL_LIMIT = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //status bar color
        self.setNeedsStatusBarAppearanceUpdate()
        
        //dismiss keyboard
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        txtInputAmount.delegate = self
        
        
        //test
        formatInputCurrency()
        txtInputAmount.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        DataManager.sharedInstance.loadJsonFromUrl("https://api.fixer.io/latest")
        
    }
    
    
    
    
    /* sepcial cases:
    non number characters
    trailing decimial 0
    trailing .
    duplicated .
    empty string
    max length
    double out of range
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
        for c in inputText.characters{
            
            
            
            if ( c == ".") {
                if (isDecimal) {
                    //ignore duplicated .
                } else {
                    //append only first "."
                    isDecimal = true
                    processedText.append(c)
                }
            } else {
                if (isDecimal) {
                    decimalPlace++
                }
                
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
        
        //empty string
        if (processedText == "")
        {
            processedText = "0"
        }
        
        //format display
        let lastChar = processedText.substringFromIndex(processedText.endIndex.predecessor())
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        //formatter.minimumSignificantDigits = 0
        formatter.maximumSignificantDigits = 99
        formatter.maximumFractionDigits = 8
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        
        var processedNumber:Double = Double.init(processedText)!
        processedNumber = floor(processedNumber*100000000)/100000000
        
        //processedNumber = Double(processedNumber).floorToPlaces(10)
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
    
    
    
    //format inputCurrency
    func textFieldDidBeginEditing(textField: UITextField) {
        
        
    }
    
    
    
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
    
    
    
    
    func checkStringFormat(testString:String) -> Bool{
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        let testNumber = formatter.numberFromString(testString)
        
        if (testString == "$")
        {
            inputNumber = 0
            return true
        }
        
        if (testNumber != nil) {
            inputNumber = testNumber!.doubleValue
            return true
        } else {
            return false
        }
        
        
    }
    
    
    
    func formatInputCurrency(){
        
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        
        formatter.locale = NSLocale(localeIdentifier: "en_US")
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