//
//  String+Truncate.swift
//  Bakkle
//
//  Created by Sándor A. Pethes on 2/5/16.
//  Copyright (c) 2016 Bakkle. All rights reserved.
//

import Foundation

extension String {
    func truncate(length: Int, trailing: String? = "...") -> String {
        if self.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}