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
        if count(self.utf8) > length {
            return self.substringToIndex(advance(self.startIndex,length)) + trailing!
        } else {
            return self
        }
    }
}