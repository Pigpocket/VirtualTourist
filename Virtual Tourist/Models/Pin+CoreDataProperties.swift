//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/10/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//
//

import Foundation
import CoreData


extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var images: NSSet?

}

// MARK: Generated accessors for images
extension Pin {

    @objc(addImagesObject:)
    @NSManaged public func addToImages(_ value: Images)

    @objc(removeImagesObject:)
    @NSManaged public func removeFromImages(_ value: Images)

    @objc(addImages:)
    @NSManaged public func addToImages(_ values: NSSet)

    @objc(removeImages:)
    @NSManaged public func removeFromImages(_ values: NSSet)

}
