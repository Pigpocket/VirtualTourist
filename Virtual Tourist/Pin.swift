//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/30/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import MapKit

struct Pin {
    
    let lat: Double
    let lon: Double
    var images: [Image]
    
    init(lat: Double, lon: Double, images: [Image]) {
        self.lat = lat
        self.lon = lon
        self.images = images
    }
    
}
