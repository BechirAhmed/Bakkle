//
//  CLLocation+String.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 5/9/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

extension CLLocation {
    // Specific to this app string of format "latdegrees, londegrees"
    convenience init(locationString: String) {
        let parts = split(locationString) {$0 == " "} as [NSString]
        var lat: Double = 0
        var lon: Double = 0
        if parts.count == 2 {
            lat = parts[0].doubleValue
            lon = parts[1].doubleValue
        }
        self.init(latitude: lat, longitude: lon)
    }
    public func toString() -> NSString {
        return "\(self.coordinate.latitude), \(self.coordinate.longitude)"
    }
    public func toJSON() -> NSString {
        return "{ \"latitude\": \(self.coordinate.latitude), \"longitude\": \(self.coordinate.longitude) }"
    }
}

extension CLLocationDistance {
    public func rangeString() -> ( String ) {
        var distanceString = ""
        switch Int(self) {
            case 0...9:
                distanceString = "0 to 10"
            case 10...19:
                distanceString = "10 to 20"
            case 20...29:
                distanceString = "20 to 30"
            case 30...39:
                distanceString = "30 to 40"
            case 40...49:
                distanceString = "40 to 50"
            case 50...1000:
                distanceString = "50 to 100"
            case 100...500:
                distanceString = "100 to 500"
            case 100...500:
                distanceString = "500 to 1,000"
            default:
                distanceString = "1,000+"
        }
        return distanceString
    }
}