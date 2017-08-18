//
//  NetworkController.swift
//  HG
//
//  Created by Andrew on 8/18/17.
//  Copyright © 2017 Andrew. All rights reserved.
//


import Foundation

class NetworkController {
    
    fileprivate static let API_KEY = "e8d877fd5ddb345f42df18a3ce10ab40"
    static let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    
    static func searchURLByCity(_ city: String) -> URL {
        let escapedCityString = city.addingPercentEncoding(withAllowedCharacters: CharacterSet())
        
        return URL(string: baseURL + "?q=\(escapedCityString!)" + "&appid=\(API_KEY)")!
    }
    
    static func urlForIcon(_ iconString: String) -> URL {
        return URL(string: "http://openweathermap.org/img/w/\(iconString).png")!
    }
    
    static func dataAtURL(_ url: URL, completion:@escaping (_ resultData: Data?) -> Void) {
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url, completionHandler: { (data, _, error) -> Void in
            
            guard let data = data  else {
                print(error?.localizedDescription as Any)
                completion(nil)
                return
            }
            
            completion(data)
        })
        
        dataTask.resume()
    }
}
