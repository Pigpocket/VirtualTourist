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
    
    static var imageGallery: [Image] = []
    
    var imageURL: URL
    var farm: Int
    var id: String
    var isFamily: Int
    var isFriend: Int
    var isPublic: Int
    var owner: String
    var secret: String
    var server: String
    var title: String
    
    var photoUrl: NSURL {
        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")!
    }
    
    init(imageURL: URL, farm: Int, id: String, isFamily: Int, isFriend: Int, isPublic: Int, owner: String, secret: String, server: String, title: String) {
    
        self.imageURL = imageURL
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
 /*
    init?(dictionary: [String:AnyObject]) {
        
        // GUARD: Do all dictionary keys have values?
        guard
            let farm = dictionary["farm"] as? Int,
            let id = dictionary["id"] as? String,
            let isFamily = dictionary["isfamily"] as? Int,
            let isFriend = dictionary["isfriend"] as? Int,
            let isPublic = dictionary["ispublic"] as? Int,
            let owner = dictionary["owner"] as? String,
            let secret = dictionary["secret"] as? String,
            let server = dictionary["server"] as? String,
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
 

    static func imageGalleryFromResults(_ results: [[String:AnyObject]]) -> [Image] {
            
        var imageGallery = [Image]()
            
        // iterate through array of dictionaries, each Image is a dictionary
        for result in results {
            if let image = Image(dictionary: result) {
                imageGallery.append(image)
            }
        }
        return imageGallery
    } */
}


