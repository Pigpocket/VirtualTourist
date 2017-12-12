//
//  PinAnnotation.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/10/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import MapKit
import CoreData

class PinAnnotation: NSObject, MKAnnotation {

    // MARK: Properties
    
    let title: String?
    let subtitle: String?
    var coordinate: CLLocationCoordinate2D
    
    // MARK: Initializers
    
    init(objectID: NSManagedObjectID, title: String?, subtitle: String?, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        super.init()
    }
}
