//
//  TableViewController.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/10/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TableViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate
{
    
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    @IBOutlet weak var tableView: UITableView!
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)
    var frc: NSFetchedResultsController<Pin>!
    var data: [Pin]!

    override func viewDidLoad() {
        frc = fetchResultsController()
        data = frc.fetchedObjects
    }
    override func viewWillAppear(_ animated: Bool) {
        frc = fetchResultsController()
        data = frc.fetchedObjects
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = data[indexPath.row].cityName
        cell?.detailTextLabel?.text = "Weather: \(data[indexPath.row].weather!) \t Temperature: \(data[indexPath.row].temperature)°C"
        return cell!
    }
    
    func fetchResultsController() -> NSFetchedResultsController<Pin>
    {
        self.fr.sortDescriptors = [NSSortDescriptor(key: "cityName", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: self.fr, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        do
        {

            try frc.performFetch()
        }
        catch
        {
            print("unable to fetch the objects using frc")
            return frc
        }

        return frc
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "weatherViewController") as! WeatherViewController
        controller.Pin = data[indexPath.row]
        performUIUpdatesOnMain {
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func longPress(_ sender: AnyObject) {
        if longPress.state == .began
        {
        let point = sender.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)
        let data = self.data[(indexPath?.row)!]
        let dataArray:[Pin]!
        do{
            dataArray = try self.moc.fetch(self.fr)
        }
        catch{
            
            print("unable to retrieve data")
            return
        }
        
        for items in dataArray
        {
            if items == data
            {
                self.moc.delete(items)
                self.application.saveContext()
            }
        }
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .delete
        {
            data = frc.fetchedObjects
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
        if type == .update
        {
            data = frc.fetchedObjects
            performUIUpdatesOnMain {
                self.tableView.reloadData()
            }
        }
    }
    @IBAction func addLocation(_ sender: AnyObject) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "locationViewController") as! LocationSelectorViewController
        performUIUpdatesOnMain {
        self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func refresh(_ sender: AnyObject) {
        let data = frc.fetchedObjects
        for items in data!
        {
            Constants.latitude = items.latitude
            Constants.longitude = items.longitude
            let network = networkCodes()
            network.getWeatherUsingMap(latitude: items.latitude,longitude: items.longitude,completionHandlerForgetWeatherUsingMap: { (sucess, error) in
                if sucess == false
                {
                    performUIUpdatesOnMain {
                        self.displayAlert(title: "Unable To Get Weather Info", message: "Please Check Your Internet connection")
                    }
                }
            })
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
