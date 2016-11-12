//
//  Network.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/10/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class networkCodes
{
    let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fr: NSFetchRequest<Pin> = Pin.fetchRequest()
    var application = (UIApplication.shared.delegate as! AppDelegate)

    
    func getWeatherUsingMap(latitude: Double, longitude: Double,completionHandlerForgetWeatherUsingMap: @escaping(_ sucess: Bool, _ error: String) -> Void)
    {

        let method = "http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(Constants.apiKey)"
        let url = URL(string: method)!
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else
            {
                print("error in geting weather information")
                return completionHandlerForgetWeatherUsingMap(false, (error?.localizedDescription)!)
            }
            
            guard let data = data else
            {
                print("no data is present in the request")
                return
            }
            
            var parsedJsonData: NSDictionary!
            do
            {
               parsedJsonData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
            }
            catch
            {
                print("unable to parse data")
                return
            }
            guard let cityName = parsedJsonData["name"] as? String else
            {
                print("unable to get city name")
                return
            }
            guard let mainInfo = parsedJsonData["main"] as? NSDictionary else
            {
                print("unable to get weather Info")
                return
            }
            guard let currentTemp = mainInfo["temp"] as? Double else
            {
                print("unable to get current temperature")
                return
            }
            guard let pressure = mainInfo["pressure"] as? Double else
            {
                print("unable to get current pressure")
                return
            }
            guard let humidity = mainInfo["humidity"] as? Double else
            {
                print("unable to get humidity")
                return
            }
            guard let minTemp = mainInfo["temp_min"] as? Double else
            {
                print("unable to get minimum temperature")
                return
            }
            guard let maxTemp = mainInfo["temp_max"] as? Double else
            {
                print("unable to get maximum temperature")
                return
            }
            guard let weather = parsedJsonData["weather"] as? [[String: Any]] else
            {
                print("unable to get weather info")
                return
            }
            var climate1: String!
            var climateDescription1: String!
            for items in weather
            {
                guard let climate = items["main"] as? String else
                {
                    print("unable to get main data")
                    return
                }
                climate1 = climate
                guard let climateDescription = items["description"] as? String else
                {
                    print("unable to get climate Description")
                    return
                }
                climateDescription1 = climateDescription
            }
            guard let sys = parsedJsonData["sys"] as? NSDictionary else
            {
                print("unable to get sys info")
                return
            }
            guard let country = sys["country"] as? String else
            {
                print("unale to get country info")
                return
            }
            Constants.cityName = "\(cityName),\(country)"
            Constants.humidity = humidity
            Constants.maxTemperature = maxTemp
            Constants.minTemperature = minTemp
            Constants.pressure = pressure
            Constants.temperature = currentTemp
            Constants.watherDescription = climateDescription1
            Constants.weatherToday = climate1
            self.saveDataToContext(latitude: latitude, longitude: longitude)
            return completionHandlerForgetWeatherUsingMap(true, "")
        }
        task.resume()
    }
    
    func saveDataToContext(latitude: Double, longitude: Double)
    {
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
            if items.latitude == latitude && items.longitude == longitude
            {
                items.cityName = Constants.cityName
                items.humidity = Constants.humidity
                items.max_temp = Constants.maxTemperature
                items.min_temp = Constants.minTemperature
                items.pressure = Constants.pressure
                items.temperature = Constants.temperature
                items.weather = Constants.weatherToday
                items.weatherDescription = Constants.watherDescription
                self.application.saveContext()
            }
        }
    }
}
