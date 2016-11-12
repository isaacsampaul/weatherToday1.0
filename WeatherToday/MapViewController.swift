//
//  MapViewController.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/10/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate
{
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var map: MKMapView!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)
    let network = networkCodes()
    
    override func viewWillAppear(_ animated: Bool) {
        let annotations = self.map.annotations
        self.map.removeAnnotations(annotations)
        let data:[Pin]!
        do{
            data = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        if data.count > 0
        {
            for items in data
            {
                performUIUpdatesOnMain {
                let lat = items.latitude
                let long = items.longitude
                Constants.latitude = lat
                Constants.longitude = long
                self.network.getWeatherUsingMap(latitude: items.latitude,longitude: items.longitude,completionHandlerForgetWeatherUsingMap: { (sucess, error) in
                    if sucess == false
                    {
                        performUIUpdatesOnMain {
                            self.displayAlert(title: "Unable To Get Weather Info", message: "Please Check Your Internet connection")
                        }
                    }
                })
                let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinates
                self.map.removeAnnotation(annotation)
                self.map.addAnnotation(annotation)
            }
            }
        }
        map.reloadInputViews()

    }
    
    @IBAction func AddPin(_ sender: AnyObject) {
        if longPress.state == .began
        {
            let touchPoint = sender.location(in: map)
            let coordinates = map.convert(touchPoint, toCoordinateFrom: map)
            let anotation = MKPointAnnotation()
            anotation.coordinate = coordinates
            Constants.latitude = coordinates.latitude
            Constants.longitude = coordinates.longitude
            let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
            let pin = Pin(entity: entityDescription!, insertInto: self.moc)
            pin.latitude = coordinates.latitude
            pin.longitude = coordinates.longitude
            self.application.saveContext()
            map.addAnnotation(anotation)
            network.getWeatherUsingMap(latitude: Constants.latitude,longitude: Constants.longitude,completionHandlerForgetWeatherUsingMap: { (sucess, error) in
                
                if sucess == false
                {
                    pin.humidity = 0
                    pin.cityName = ""
                    pin.max_temp = 0
                    pin.min_temp = 0
                    pin.pressure = 0
                    pin.temperature = 0
                    pin.weather = ""
                    pin.weatherDescription = ""
                    self.application.saveContext()
                    performUIUpdatesOnMain {
                        self.displayAlert(title: "Unable To Get Weather Info", message: "Please Check Your Internet connection")
                    }
                }
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let lat = (view.annotation?.coordinate.latitude)!
        let long = (view.annotation?.coordinate.longitude)!
        Constants.latitude = view.annotation?.coordinate.latitude
        Constants.longitude = view.annotation?.coordinate.longitude
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "weatherViewController") as! WeatherViewController
                let data:[Pin]!
                do{
                    data = try self.moc.fetch(self.fr)
                }
                catch{
                    
                    print("unable to retrieve data")
                    return
                }
                
                for items in data
                {
                    if items.latitude == Constants.latitude && items.longitude == Constants.longitude && items.humidity == 0
                    {
                        self.network.getWeatherUsingMap(latitude: lat,longitude: long,completionHandlerForgetWeatherUsingMap: { (sucess, error) in
                            if sucess == false
                            {
                                performUIUpdatesOnMain {
                                    self.displayAlert(title: "Unable To Get Weather Info", message: "Please Check Your Internet connection")
                                }
                            }
                            else
                            {
                                controller.Pin = data[data.index(of: items)!]
                                performUIUpdatesOnMain {
                                    self.present(controller, animated: true, completion: nil)
                                }
                            }
                        })
                    }
                    else if items.latitude == Constants.latitude && items.longitude == Constants.longitude
                    {
                        controller.Pin = data[data.index(of: items)!]
                        performUIUpdatesOnMain {
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                }
            }
    
    func displayAlert(title: String, message: String)
    {
        let alert = UIAlertController()
        alert.title = title
        alert.message = message
        let continueAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default){
            
            action in alert.dismiss(animated: true, completion: nil)
            
        }
        alert.addAction(continueAction)
        self.present(alert, animated: true, completion: nil)
        
    }

}
