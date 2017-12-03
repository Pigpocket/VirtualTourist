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
    
    static var shared: Pin = Pin()
    
    var lat: Double = 0.0
    var lon: Double = 0.0
    var images: [Image] = []
    
}
