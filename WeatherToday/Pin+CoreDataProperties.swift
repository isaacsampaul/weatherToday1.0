//
//  Pin+CoreDataProperties.swift
//  WeatherToday
//
//  Created by Isaac sam paul on 11/11/16.
//  Copyright © 2016 Isaac sam paul. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var cityName: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var weather: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var temperature: Double
    @NSManaged public var pressure: Double
    @NSManaged public var humidity: Double
    @NSManaged public var min_temp: Double
    @NSManaged public var max_temp: Double

}
