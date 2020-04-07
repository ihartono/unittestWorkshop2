//
//  CreateShop+String.swift
//  UnitTestWorkshop
//
//  Created by Bondan Eko Prasetyo on 19/07/19.
//  Copyright © 2019 Tokopedia. All rights reserved.
//

import Foundation

extension String {
    static var postalCodePlaceholder: String {
        return "Postal Code"
    }
    
//    static var below3Characters: String {
//        return "Should not less than 3 characters"
//    }
//
//    static var requiredField: String {
//        return "This field should not empty"
//    }
//
//    static var shouldNotStartOrEndWithWhiteSpace: String {
//        return "Shop name should not end with whitespace"
//    }
//
//    static var shouldNotContainEmoji: String {
//        return "Should not contain emoji"
//    }
    
    internal var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF, // Misc symbols
            0x2700...0x27BF, // Dingbats
            0xFE00...0xFE0F: // Variation Selectors
                return true
            default:
                continue
            }
        }
        return false
    }
    
    internal var wrappedInWhitespace: Bool {
        self.hasPrefix(" ") || self.hasSuffix(" ")
    }
}
