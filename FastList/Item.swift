//
//  Item.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/29/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit

extension Item {
    
    // MARK: - Initialization
    convenience init?(name: String) {
        self.init()
        
        // The name must not be empty.
        guard !name.isEmpty else {
            return nil
        }
        
        // Initialize properties.
        self.name = name
    }
    
}

