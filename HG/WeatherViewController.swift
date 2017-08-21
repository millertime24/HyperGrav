//
//  WeatherViewController.swift
//  HG
//
//  Created by Andrew on 8/18/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    // Bool to indicate whether or not we need to save the location
    var shouldSaveLocation = false
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        activity.isHidden = true
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
            // Now check if you have a previous location
            if let location = UserDefaults.standard.value(forKey: "location") as? String {
                getWheatherFor(location: location)
            }
        }
        else
        {
            let controller = UIAlertController(title: "No Internet Detected", message: "This app requires an Internet connection", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            controller.addAction(ok)
            controller.addAction(cancel)
            
            present(controller, animated: true, completion: nil)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            shouldSaveLocation = true
            getWheatherFor(location: searchText)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func getWheatherFor(location: String) {
        activity.startAnimating()
        activity.isHidden = false
        WeatherController.weatherBySearchCity(location) { (result) in
            // always stop/hide activity
            DispatchQueue.main.async {
                self.activity.stopAnimating()
                self.activity.isHidden = true
            }
            
            guard let weatherResult = result else {
                let controller = UIAlertController(title: "No Internet Detected", message: "Connection Failure", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                controller.addAction(ok)
                controller.addAction(cancel)
                
                self.present(controller, animated: true, completion: nil)
                return
            }
            
            // check if need to save this location
            if self.shouldSaveLocation {
                UserDefaults.standard.set(location, forKey: "location")
            }
            
            DispatchQueue.main.async { () in
                self.cityNameLabel.text = weatherResult.cityName
                if let temperatureC = weatherResult.temperatureC {
             
                    self.temperatureLabel.text = String(temperatureC) + " °C"
                } else {
                    self.temperatureLabel.text = "No temperature available"
                }
                self.mainLabel.text = weatherResult.main
                self.descriptionLabel.text = weatherResult.description
            }
            
            WeatherController.weatherIconForIconCode(weatherResult.iconString, completion: { (image) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    self.iconImageView.image = image
                })
            })
        }
        
    }
}
