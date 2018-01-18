//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 1/18/18.
//  Copyright © 2018 Tomas Sidenfaden. All rights reserved.
//

import UIKit
import Foundation
import CoreData

extension FlickrClient {
    
    func getImagesFromFlickr(pin: Pin, context: NSManagedObjectContext, page: Any, completionHandlerForGetImages: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.FlickrPhotosSearch,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: pin.latitude as Any,
            Constants.FlickrParameterKeys.Lon: pin.longitude as Any,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: page
        ]
        
        taskForGetImages(nil, parameters: methodParameters as [String : AnyObject], latitude: pin.latitude, longitude: pin.longitude) { (results, error) in
            
            if let error = error {
                completionHandlerForGetImages(false, "There was an error getting the images: \(error)")
            } else {
                
                // Create a dictionary from the data:
                
                /* GUARD: Are the "photos" and "photo" keys in our result? */
                    if let photosDictionary = results![Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {

                        print("This the photosDictionary: \(photosDictionary)")
                    var imageCount = 0
                    if photoArray.isEmpty {
                        completionHandlerForGetImages(false, "Unable to download photos")
                    }
                    for photo in photoArray {
                        
                        //let image = Images(context: CoreDataStack.sharedInstance().context)
                        
                        // GUARD: Does our photo have a key for 'url_m'?
                        guard let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                            completionHandlerForGetImages(false, "Unable to find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)")
                            return
                        }
                        
                        self.downloadImageFromURLPath(path: imageUrlString, pin: pin, completionHandler: { (completed, errorMessage) in
                            if completed {
                                imageCount += 1
                                if imageCount == photoArray.count {
                                    completionHandlerForGetImages(true, nil)
                                }
                            }
                            if (errorMessage != nil) {
                                completionHandlerForGetImages(false, errorMessage)
                            }
                        })
                    }
                } else {
                    completionHandlerForGetImages(false, "Unable to get images")
                }
            }
        }
    }
    
    
    func downloadImageFromURLPath(path: String, pin: Pin, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        taskForGetImages(path, parameters: nil, latitude: pin.latitude, longitude: pin.longitude) { (result, error) in
            if error != nil {
                completionHandler(false, "Photo download failed")
            } else {
                if let result = result as? NSData {
                    let image = Images(data: result, pin: pin, context: CoreDataStack.sharedInstance().context)
                    CoreDataStack.sharedInstance().context.insert(image)
                    CoreDataStack.sharedInstance().saveContext()
                    completionHandler(true, nil)
                } else {
                    completionHandler(false, "Photo download failed")
                }
            }
        }
        //task.resume()
    }
    
}
