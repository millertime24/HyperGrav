//
//  WeatherController.swift
//  HG
//
//  Created by Andrew on 8/18/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation
import UIKit

class WeatherController {
    
    static func weatherBySearchCity(_ city: String, completion:@escaping (_ result: Weather?) -> Void) {
        
        let url = NetworkController.searchURLByCity(city)
        
        NetworkController.dataAtURL(url) { (resultData) -> Void in
            
            guard let resultData = resultData
                else {
                    print("NO DATA RETURNED")
                    completion(nil)
                    return
            }
            
            do {
                let weatherAnyObject = try JSONSerialization.jsonObject(with: resultData, options: JSONSerialization.ReadingOptions.allowFragments)
                
                var weatherModelObject: Weather?
                
                if let weatherDictionary = weatherAnyObject as? [String : AnyObject] {
                    weatherModelObject = Weather(jsonDictionary: weatherDictionary)
                }
                
                completion(weatherModelObject)
                
            } catch {
                completion(nil)
            }
            
        }
    }
    
    static func weatherIconForIconCode(_ iconCode: String, completion:@escaping (_ image: UIImage?) -> Void) {
        let url = NetworkController.urlForIcon(iconCode)
        
        NetworkController.dataAtURL(url) { (resultData) -> Void in
            guard let resultData = resultData
                else {
                    print("NO DATA RETURNED")
                    completion(nil)
                    return
            }
            completion(UIImage(data: resultData))
        }
    }
}
