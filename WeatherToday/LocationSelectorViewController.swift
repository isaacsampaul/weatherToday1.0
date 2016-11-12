//
//  LocationSelectorViewController.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/10/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit
class LocationSelectorViewController: UIViewController,UITextFieldDelegate,MKMapViewDelegate
{
    
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cancel: UIBarButtonItem!
    
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)
    let network = networkCodes()
    
    override func viewDidLoad() {
        activityView.isHidden = true
    }
    
    @IBAction func FindLocation(_ sender: AnyObject) {
        activityView.isHidden = false
        searchButton.isEnabled = false
        searchTextField.isEnabled = false
        cancel.isEnabled = false
        getLocation { (sucess) in
            if sucess == true
            {
                self.network.getWeatherUsingMap(latitude: Constants.latitude,longitude: Constants.longitude,completionHandlerForgetWeatherUsingMap: { (sucess, error) in
                    if sucess == true
                    {
                        performUIUpdatesOnMain {
                        self.activityView.isHidden = true
                        self.searchButton.isEnabled = true
                        self.searchTextField.isEnabled = true
                        self.cancel.isEnabled = true
                        self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else
                    {
                        self.activityView.isHidden = true
                        self.searchButton.isEnabled = true
                        self.searchTextField.isEnabled = true
                        self.cancel.isEnabled = true
                        self.displayAlert(title: "Unable To Get Weather Info", message: "Please Check Your Internet Connection")
                    }
                })
            }
            else
            {
                performUIUpdatesOnMain {
                    self.activityView.isHidden = true
                    self.searchButton.isEnabled = true
                    self.searchTextField.isEnabled = true
                    self.cancel.isEnabled = true
                    
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getLocation(completionHandlerForGeoLocation: @escaping(_ sucess: Bool) -> Void )
    {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(self.searchTextField.text!, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) in
            
            guard error == nil else
            {
                
                let error = ((error?.localizedDescription)!)
                print(error)
                if error == "The operation couldn’t be completed. (kCLErrorDomain error 2.)"
                {
                    print(error)
                    performUIUpdatesOnMain {
                        self.displayAlert(title: "Cannot Connect to Server", message: "Please Check Your Internet Connection")
                    }
                    return completionHandlerForGeoLocation(false)
                }
                else if error == "The operation couldn’t be completed. (kCLErrorDomain error 8.)"
                {
                    performUIUpdatesOnMain {
                        self.displayAlert(title: "Location Not Found", message: "Please Try Another Location")
                    }
                    return completionHandlerForGeoLocation(false)
                    
                }
                return completionHandlerForGeoLocation(false)
            }
            guard let placemark = placemarks else
            {
                print("no placemark available")
                return
            }
            guard let latitude = placemark[0].location?.coordinate.latitude else
            {
                
                print("couldnt copy")
                return
            }
            guard let longitude = placemark[0].location?.coordinate.longitude else
            {
                
                print("couldnt copy")
                return
            }
            Constants.latitude = latitude
            Constants.longitude = longitude
            let entityDescription = NSEntityDescription.entity(forEntityName: "Pin", in: self.moc)
            let pin = Pin(entity: entityDescription!, insertInto: self.moc)
            pin.latitude = latitude
            pin.longitude = longitude
            self.application.saveContext()
            completionHandlerForGeoLocation(true)
            
        })
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
