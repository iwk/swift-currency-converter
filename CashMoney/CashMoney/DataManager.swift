//
//  DataManager.swift
//  CashMoney
//
//  Created by Philip Ip on 17/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import Foundation

protocol JsonLoaderDelegate {
    func jsonLoaded(json:NSDictionary)
    func jsonFailed(message:String)
}

class DataManager:NSObject, NSURLConnectionDelegate {
    static let sharedInstance = DataManager()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    var delegate: JsonLoaderDelegate?
    
    //custom error message
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: invalid JSON format"
        case UnexpectedElement = "ERROR: unexpected JSON element"
    }
    
    //generic request
    func loadJsonFromUrl(urlPath:String)
    {
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                self.parseJson(json)
            } catch let error as JSONError {
                //print(error.rawValue)
                self.handleRequestFailed(error.rawValue)
            } catch {
                print(error)
            }
            }.resume()
    }
    
    
    //custom checker
    func parseJson(json:NSDictionary)
    {
        
        do {
            
            guard let _ = json["rates"]?["AUD"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["CAD"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["GBP"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["JPY"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["USD"]! else { throw JSONError.UnexpectedElement }
            
            handleRequestSuccess(json)
            
        } catch let error as JSONError {
            handleRequestFailed(error.rawValue)
        } catch {
            print(error)
        }
    }
    
    func handleRequestSuccess(json:NSDictionary)
    {
        if (delegate != nil)
        {
            delegate!.jsonLoaded(json)
        }
        
    }
    func handleRequestFailed(message:String)
    {
        if (delegate != nil)
        {
            delegate!.jsonFailed(message)
        }
    }
    
    
}