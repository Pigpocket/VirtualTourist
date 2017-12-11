//
//  Images+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/10/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//
//

import Foundation
import CoreData


extension Images {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Images> {
        return NSFetchRequest<Images>(entityName: "Images")
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var title: String?
    @NSManaged public var pin: Pin?

}
