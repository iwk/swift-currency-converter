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
        DataManager.sharedInstance.loadJsonFromUrl(urlPath: "https://api.fixer.io/latest")
        //delegate -> jsonLoaded or jsonFailed
        
        
        //custom constrains for iphone4. Other iphones and ipad constrains are configured in storyboard
        updateConstrainsForSmallphones()

    }
    
    
    func updateConstrainsForSmallphones()
    {
        if (UIScreen.main.bounds.size.height <= 480.0) {
            self.view.layoutIfNeeded()
            textTopConstrain.constant = 20
            controlTopConstrain.constant = 20
            self.view.layoutIfNeeded()
        }
    }
    
    func jsonLoaded(json: NSDictionary) {
        print("json")
        currencyData = json
        DispatchQueue.main.async {
            self.initControls()
        }
       
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
        ExchangeCalculator.sharedInstance.addCurrencyWithValue(currencyCode: "EUR", value: 1.0 )
        for currencyCode in ["AUD","CAD","GBP", "JPY", "USD"]
        {
            //verify JSON format
            do {
                //guard let _ = ((currencyData!["rates"]) as! Dictionary )[currencyCode]! else { throw DataManager.JSONError.UnexpectedElement }
                
                ExchangeCalculator.sharedInstance.addCurrencyWithValue(currencyCode: currencyCode, value: ((currencyData!["rates"] as! [String:Any])[currencyCode]) as! Double )
            } catch {
                print(error)
            }
            
        }
        
        
        //setup view
        currencyControl.delegate = self
        for currencyCode in ["CAD", "EUR", "GBP", "JPY", "USD"]
        {
            currencyControl.addOption(optionName: currencyCode)
        }
        currencyControl.refreshView()
        
        
        //enable interactions
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        txtInputAmount.delegate = self
        txtInputAmount.addTarget(self, action: "textFieldDidChange:", for: UIControl.Event.editingChanged)
        
        formatInputCurrency()
        convert()
        drawDashedUnderline()
        
    }
    
    func drawDashedUnderline()
    {
        let color = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1).cgColor
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = txtInputAmount.frame.size
        let lineWidth = (frameSize.width - (frameSize.width.truncatingRemainder(dividingBy: 18)))
        let shapeRect = CGRect(x: 0, y: 0, width: lineWidth, height: 1)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height)
        shapeLayer.fillColor = color
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 3
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [10,8]
        //for rect
        //shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).CGPath
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: lineWidth, y: 0))
        shapeLayer.path = path.cgPath
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
        for c in inputText
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
                    decimalPlace = decimalPlace + 1
                }
                //count trailing zeros
                if (decimalPlace <= DECIMAL_LIMIT)
                {
                    //append character
                    processedText.append(c)
                    
                    //count decimal 0
                    if (c == "0" && isDecimal)
                    {
                        trailingDecimalZero = trailingDecimalZero + 1
                    } else
                    {
                        trailingDecimalZero = 0
                    }
                }
                
            }
        }
        
        //filter invalid characters
        let validSet:NSCharacterSet = NSCharacterSet(charactersIn: "0123456789.")
        processedText = processedText.trimmingCharacters(in: validSet.inverted)
        //processedText = processedText.stringByTrimmingCharactersInSet(validSet.invertedSet)
        processedText = processedText.replacingOccurrences(of: ",", with: "")
        //processedText = processedText.stringByReplacingOccurrencesOfString(",", withString: "")
        
        //handle empty string
        if (processedText == "")
        {
            processedText = "0"
        }
        
        //format display
        let lastChar = processedText.last//.substringFrom(processedText.endIndex.predecessor())
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumSignificantDigits = 99
        formatter.maximumFractionDigits = 6
        //formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        
        
        let processedNumber:Double = Double.init(processedText)!
        print("processed number: \(processedNumber)")
        
        
        
        
        if (lastChar == ".")
        {
            //format tailing .
            processedText = formatter.string(from: NSNumber(value: processedNumber))!
            processedText = processedText + "."
        } else
            if (lastChar == "0" && isDecimal)
            {
                //format tailing decimial 0
                
                processedText = formatter.string(from: NSNumber(value: processedNumber))!
                print("processedText: "+processedText)
                
                //prevent formatter from removing .0 while user is still entering 0
                if (processedNumber.truncatingRemainder(dividingBy: 1.0) == 0)
                {
                    processedText = processedText+"."
                }
                
                //append trailing zeros
                for i in 0...trailingDecimalZero-1{
                
                    processedText = processedText+"0"
                    print("add 0")
                }
                
                
            }else
            {
                //format normal case
                processedText = " "+formatter.string(from: NSNumber(value: processedNumber))!
                
                
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
//    override func preferredStatusBarStyle() -> UIStatusBarStyle {
//        return UIStatusBarStyle.lightContent
//    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        let newString = originalString.replacingCharacters(in: range, with: newCharacter as String)
        
        
        if (newString.count > INPUT_CHAR_LIMIT)
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
        outputNumber = ExchangeCalculator.sharedInstance.getCurrencyValue(fromCurrencyCode: "AUD", toCurrencyCode: currencyControl.getSelectedOption(), amount: inputNumber)
        formatOuputCurrency()
    }
    
    
    func formatOuputCurrency(){
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyControl.getSelectedOption()
        formatter.maximumFractionDigits = 2
        txtOutputAmount.text = formatter.string(from: NSNumber(value: outputNumber))
    }
    
    
    
    func formatInputCurrency(){
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        //formatter.currencyCode = "USD"
        formatter.currencySymbol = "$"
        //formatter.maximumSignificantDigits = 99
        formatter.maximumFractionDigits = 6
        //print(inputNumber)
        txtInputAmount.text = formatter.string(from: NSNumber(value: inputNumber))
        
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
