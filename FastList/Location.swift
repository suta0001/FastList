//
//  Location.swift
//  FastList
//
//  Created by Abdullah on 3/12/17.
//  Copyright © 2017 FastListTeam. All rights reserved.
//

import UIKit
import CoreData

extension Location {
    
    @NSManaged var uniqueIdentifier: NSString
    @NSManaged var number: NSNumber
    class func numberHolderInContext(_ context:NSManagedObjectContext) -> Location {
        var holder:Location?
        context.performAndWait {
            let fetch = NSFetchRequest<Location>(entityName: "Location")
            holder = try! fetch.execute().last
            if holder == nil {
                holder = Location(context:context)
            }
        }
        return holder!
    }
}
