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