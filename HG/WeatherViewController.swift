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
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == true
        {
            print("Connected")
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
            WeatherController.weatherBySearchCity(searchText) { (result) in
                guard let weatherResult = result else { return }
                DispatchQueue.main.async { () in
                    self.cityNameLabel.text = weatherResult.cityName
                    if let temperatureC = weatherResult.temperatureC {
                        self.temperatureLabel.text = String(temperatureC) + " °C"
                    } else {
                        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
        
        searchBar.resignFirstResponder()
    }
}
