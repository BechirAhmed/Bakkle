//
//  NSDate+String.swift
//  Bakkle
//
//  Created by Carroll, Joseph B on 6/16/15.
//  Copyright (c) 2015 Ishank Tandon. All rights reserved.
//

import Foundation

extension NSDate {
    func dateFromString(date: String, format: String) -> NSDate {
        let formatter = NSDateFormatter()
        let locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        formatter.locale = locale
        formatter.dateFormat = format
        
        return formatter.dateFromString(date)!
    }
}