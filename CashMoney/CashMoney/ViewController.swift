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
    
    var inputNumber:Double = 10.8;
    
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
    
    func textFieldDidChange(textField:UITextField){
        
        let lastChar = ""
        //let lastChar = textField.text!.substringFromIndex(textField.text!.endIndex)
        print(textField.text)
        if (lastChar == ".")
        {
            
        } else
        {
            
            //replace string
            var newText:String = textField.text!.stringByReplacingOccurrencesOfString(",", withString: "")
            newText = newText.stringByReplacingOccurrencesOfString("$", withString: "")
            
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            //formatter.generatesDecimalNumbers = false
            formatter.minimumSignificantDigits = 0
            formatter.locale = NSLocale(localeIdentifier: "en_US")
            
            //let newNumber:NSNumber = formatter.numberFromString(newText)!
            //print(newNumber)
            
            //textField.text = formatter.stringFromNumber(newNumber)
        }
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
        print(inputNumber)
        txtInputAmount.text = formatter.stringFromNumber(inputNumber)
        
    }
    
    
    
}

