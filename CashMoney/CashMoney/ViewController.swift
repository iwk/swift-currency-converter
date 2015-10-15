//
//  ViewController.swift
//  CashMoney
//
//  Created by Philip Ip on 14/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var txtInputAmount: UITextField!
    
    var inputNumber:Double = 10.00008
    
    let inputTextCharLimit = 30
    
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
        
    }
    
    
    
    /* sepcial cases:
    non number characters
    trailing decimial 0
    trailing .
    diplicated .
    empty string
    max length
    */
    func textFieldDidChange(textField:UITextField){
        
        print("=========")
        let inputText:String = textField.text!
        var processedText:String = ""
        var outputText:String = ""
        var trailingDecimalZero = 0

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
        
        //filter invalid characters
        let validSet:NSCharacterSet = NSCharacterSet(charactersInString: "0123456789.")
        processedText = processedText.stringByTrimmingCharactersInSet(validSet.invertedSet)
        processedText = processedText.stringByReplacingOccurrencesOfString(",", withString: "")
        
        //empty string
        if (processedText == "")
        {
            processedText = "0"
        }
        
        let newNumber:Double = Double.init(processedText)!
        print("processed number: \(newNumber)")
        
        
        //format display
        let lastChar = processedText.substringFromIndex(processedText.endIndex.predecessor())
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.minimumSignificantDigits = 0
        formatter.maximumSignificantDigits = 99
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        
        if (lastChar == ".")
        {
            //format tailing .
            processedText = formatter.stringFromNumber(newNumber)!
            processedText = processedText + "."
        } else
        if (lastChar == "0" && isDecimal)
        {
            //format tailing decimial 0
            processedText = formatter.stringFromNumber(newNumber)!
            print("processedText: "+processedText)
            
            //prevent formatter from removing .0 while user is still entering 0
            if (newNumber % 1 == 0)
            {
                processedText = processedText+"."
            }
            
            //append trailing zeros
            for var i = 0; i < trailingDecimalZero; i++ {
                processedText = processedText+"0"
            }
            
            
        }else
        {
            //format normal case
            processedText = formatter.stringFromNumber(newNumber)!
            
            
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
    
    
    /*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    //test new string by NSString function
    let newCharacter:NSString = NSString(string: string)
    let originalString:NSString = NSString(string: txtInputAmount.text!)
    let newString = originalString.stringByReplacingCharactersInRange(range, withString: newCharacter as String)
    
    var isStringValid:Bool = checkStringFormat(newString)
    
    
    
    return isStringValid
    }
    */
    
    
    
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

