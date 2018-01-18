//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 1/18/18.
//  Copyright © 2018 Tomas Sidenfaden. All rights reserved.
//

import Foundation

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
        
        taskForGetImages(methodParameters: methodParameters, latitude: pin.latitude, longitude: pin.longitude) { (results, error) in
            
            if let error = error {
                completionHandlerForGetImages(false, "There was an error getting the images: \(error)")
            } else {
                
                // Create a dictionary from the data:
                
                /* GUARD: Are the "photos" and "photo" keys in our result? */
                if let photosDictionary = results![Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                    
                    for photo in photoArray {
                        
                        let image = Images(context: CoreDataStack.sharedInstance().context)
                        
                        // GUARD: Does our photo have a key for 'url_m'?
                        guard let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                            completionHandlerForGetImages(false, "Unable to find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)")
                            return
                        }
                        
                        // Get metadata
                        let imageURL = URL(string: imageUrlString)!
                        let title = photo["title"] as? String ?? ""
                        
                        // Assign the metadata to images NSManagedObject
                        image.imageURL = String(describing: imageURL)
                        image.pin = pin
                        image.title = title
                        
                        CoreDataStack.sharedInstance().context.insert(image)
                    }
                    CoreDataStack.sharedInstance().saveContext()
                }
                completionHandlerForGetImages(true, nil)
            }
        }
    }
    
}
