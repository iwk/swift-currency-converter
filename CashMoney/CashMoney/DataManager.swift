//
//  DataManager.swift
//  CashMoney
//
//  Created by Philip Ip on 17/10/2015.
//  Copyright © 2015 Philip. All rights reserved.
//

import Foundation


class DataManager:NSObject, NSURLConnectionDelegate {
    static let sharedInstance = DataManager()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: invalid JSON format"
        case UnexpectedElement = "ERROR: unexpected JSON element"
    }
    
    func loadJsonFromUrl(urlPath:String)
    {
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                guard let dat = data else { throw JSONError.NoData }
                guard let json = try NSJSONSerialization.JSONObjectWithData(dat, options: []) as? NSDictionary else { throw JSONError.ConversionFailed }
                //guard let rates:NSDictionary = json["rates"] as? NSDictionary else { throw JSONError.UnexpectedElement }
                
                self.parseJson(json)
            } catch let error as JSONError {
                print(error.rawValue)
                self.handleFailed()
            } catch {
                print(error)
                self.handleFailed()
            }
            }.resume()
    }
    
    
    
    func parseJson(json:NSDictionary)
    {
        
        do {
            
            guard let _ = json["rates"]!["AUD"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["CAD"]! else { throw JSONError.UnexpectedElement }
            //guard let _ = json["rates"]?["EUR"] else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["GBP"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["JPY"]! else { throw JSONError.UnexpectedElement }
            guard let _ = json["rates"]?["USD"]! else { throw JSONError.UnexpectedElement }
           
            handleSuccess(json)
            
        } catch let error as JSONError {
            print(error.rawValue)
            handleFailed()
        } catch {
            print(error)
            handleFailed()
        }
    }
    
    func handleSuccess(json:NSDictionary)
    {
        print(json)
    }
    func handleFailed()
    {
        
    }
    
    
}