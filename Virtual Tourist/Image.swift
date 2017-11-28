//
//  ImageGallery.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/27/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit

struct Image {
    
    var farm: Int
    var id: Int
    var isFamily: Int
    var isFriend: Int
    var isPublic: Int
    var owner: Int
    var secret: Int
    var server: Int
    var title: String
    
    init(farm: Int, id: Int, isFamily: Int, isFriend: Int, isPublic: Int, owner: Int, secret: Int, server: Int, title: String) {
    
        self.farm = farm
        self.id = id
        self.isFamily = isFamily
        self.isFriend = isFriend
        self.isPublic = isPublic
        self.owner = owner
        self.secret = secret
        self.server = server
        self.title = title

    }
 
    init?(dictionary: [String:AnyObject]) {
        
        // GUARD: Do all dictionary keys have values?
        guard
            let farm = dictionary["farm"] as? Int,
            let id = dictionary["id"] as? Int,
            let isFamily = dictionary["isfamily"] as? Int,
            let isFriend = dictionary["isfriend"] as? Int,
            let isPublic = dictionary["ispublic"] as? Int,
            let owner = dictionary["owner"] as? Int,
            let secret = dictionary["secret"] as? Int,
            let server = dictionary["server"] as? Int,
            let title = dictionary["longitude"] as? String
        
            // If not, return nil
            else { return nil }
        
            // Otherwise initalize values
            self.farm = farm
            self.id = id
            self.isFamily = isFamily
            self.isFriend = isFriend
            self.isPublic = isPublic
            self.owner = owner
            self.secret = secret
            self.server = server
            self.title = title
    }
}
 
 
    /*
    static func imageGalleryFromResults(_ results: [[String:Any]]) -> [Image] {
            
        var imageGallery = [Image]()
            
        // iterate through array of dictionaries, each Image is a dictionary
        for result in results {
            if let image = Image(dictionary: result) {
                imageGallery.append(image)
            }
        }
        return imageGallery
    }
 
 */


