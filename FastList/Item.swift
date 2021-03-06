//
//  Item.swift
//  FastList
//
//  Created by Agustinus Sutandi and Abdullah Syed on 1/29/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

extension Item {
    
    @NSManaged var uniqueIdentifier: NSString
    @NSManaged var number: NSNumber
    class func numberHolderInContext(_ context:NSManagedObjectContext) -> Item {
        var holder:Item?
        context.performAndWait {
            let fetch = NSFetchRequest<Item>(entityName: "Item")
            holder = try! fetch.execute().last
            if holder == nil {
                holder = Item(context:context)
            }
        }
        return holder!
    }
}

