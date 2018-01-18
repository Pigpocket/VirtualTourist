//
//  Images+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/10/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//
//

import UIKit
import Foundation
import CoreData

@objc(Images)
public class Images: NSManagedObject {

    // MARK: - Initializer
    convenience init(data: NSData, pin: Pin, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Images", in: context) {
            self.init(entity: entity, insertInto: context)
            self.imageData = data
            self.pin = pin
            //self.imageURL = dictionary[Constants.FlickrResponseKeys.MediumURL] as? String
        } else {
            fatalError("Unable to find entity name")
        }
    }
    
    var image: UIImage? {
        if imageData != nil {
            return UIImage(data: imageData! as Data)
        }
        return nil
    }

}
