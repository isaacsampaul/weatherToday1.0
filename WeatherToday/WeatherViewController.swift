//
//  WeatherViewController.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/10/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class WeatherViewController: UIViewController, MKMapViewDelegate
{
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var currentWeather: UITextField!
    @IBOutlet weak var currentWeatherDescription: UITextField!
    @IBOutlet weak var temperature: UITextField!
    @IBOutlet weak var pressure: UITextField!
    @IBOutlet weak var humidity: UITextField!
    @IBOutlet weak var min_temp: UITextField!
    @IBOutlet weak var max_temp: UITextField!
    @IBOutlet weak var map: MKMapView!
    var Pin: Pin!
    
    override func viewWillAppear(_ animated: Bool) {
        performUIUpdatesOnMain {
        self.uiEnabler(status: false)
        let coordinate = CLLocationCoordinate2DMake(self.Pin.latitude, self.Pin.longitude)
        let region = MKCoordinateRegionMake(coordinate, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.map.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.map.addAnnotation(annotation)
        self.cityName.text = self.Pin.cityName
        self.currentWeather.text = self.Pin.weather
        self.currentWeatherDescription.text = self.Pin.weatherDescription
        self.temperature.text = "\(self.Pin.temperature)°C"
        self.pressure.text = "\(self.Pin.pressure) hPa"
        self.humidity.text = "\(self.Pin.humidity)%"
        self.min_temp.text = "\(self.Pin.min_temp)°C"
        self.max_temp.text = "\(self.Pin.max_temp)°C"
    }
    }
    
    func uiEnabler(status: Bool)
    {
        cityName.isEnabled = status
        currentWeather.isEnabled = status
        currentWeatherDescription.isEnabled = status
        temperature.isEnabled = status
        pressure.isEnabled = status
        humidity.isEnabled = status
        min_temp.isEnabled = status
        max_temp.isEnabled = status
    }
    @IBAction func done(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
