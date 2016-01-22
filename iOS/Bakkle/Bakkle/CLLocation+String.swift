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
        let parts = locationString.characters.split {$0 == ","}.map { String($0) } as [NSString]
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
                distanceString = "<10"
            case 10...19:
                distanceString = "<20"
            case 20...29:
                distanceString = "<30"
            case 30...39:
                distanceString = "<40"
            case 40...49:
                distanceString = "<50"
            case 50...99:
                distanceString = "<100"
            case 100...499:
                distanceString = "<500"
            default:
                distanceString = "500+"
        }
        return distanceString
    }
}