//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/10/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
        } else {
            fatalError("Unable to find entity name")
        }
    }
    
    // MARK: Remove photos
    
    func removePhotos(context: NSManagedObjectContext) {
        if let images = images {
            for image in images {
                context.delete(image as! NSManagedObject)
            }
        }
    }
}
