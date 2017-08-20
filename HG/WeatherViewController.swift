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
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        activity.isHidden = true
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
            activity.startAnimating()
            activity.isHidden = false
            WeatherController.weatherBySearchCity(searchText) { (result) in
                guard let weatherResult = result else {
                    let controller = UIAlertController(title: "No Internet Detected", message: "Connection Failure", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    self.activity.stopAnimating()
                    self.activity.isHidden = true
                    controller.addAction(ok)
                    controller.addAction(cancel)
                    
                    self.present(controller, animated: true, completion: nil)
                    return
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
        
        searchBar.resignFirstResponder()
    }
}
