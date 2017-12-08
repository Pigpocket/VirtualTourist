//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/23/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import UIKit
import Foundation

class FlickrClient: NSObject {
    
    func taskForGetImages(methodParameters: [String:Any], latitude: Any, longitude: Any, completionHandlerForGetImages: @escaping (_ results: AnyObject?, _ error: NSError?) -> Void) {
        
        // create url and request
        let session = URLSession.shared
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        //print("This is what the URL request looks like: \n ****** \n \(url) \n ********")
        let request = URLRequest(url: url)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                let userInfo = [NSLocalizedDescriptionKey: "There was an error with your request: \(error! as NSError)"]
                completionHandlerForGetImages(nil, NSError(domain: "taskForGetImages", code: 0, userInfo: userInfo))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                let userInfo = [NSLocalizedDescriptionKey: "Your request return an invalid response: \(error! as NSError)"]
                completionHandlerForGetImages(nil, NSError(domain: "taskForGetImages", code: 1, userInfo: userInfo))
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                let userInfo = [NSLocalizedDescriptionKey: "No data was returned by the request: \(error! as NSError)"]
                completionHandlerForGetImages(nil, NSError(domain: "taskForGetImages", code: 2, userInfo: userInfo))
                return
            }
            
            self.parseJSONObject(data, completionHandlerForConvertData: completionHandlerForGetImages)
            
        // start the task!
        }
        task.resume()
    }
    
    // MARK: Helper for Escaping Parameters in URL
    
    func parseJSONObject(_ data: Data, completionHandlerForConvertData: (_ results: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: \(data)"]
            completionHandlerForConvertData(nil, NSError(domain: "parseJSONObject", code: 0, userInfo: userInfo))
        }
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    private func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}

extension FlickrClient {
    
    func getImagesFromFlickr(latitude: Any, longitude: Any, page: Any, completionHandlerForGetImages: @escaping (_ pin: Pin?, _ errorString: String?) -> Void) {
        
        var pin = Pin()
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.FlickrPhotosSearch,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: latitude as Any,
            Constants.FlickrParameterKeys.Lon: longitude as Any,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
            Constants.FlickrParameterKeys.Page: page
            ]
        
        taskForGetImages(methodParameters: methodParameters, latitude: latitude, longitude: longitude) { (results, error) in
            
            print("This is the latitude in the taskForGetImages: \(latitude)")
            
            pin.lat = latitude as! Double
            pin.lon = longitude as! Double
            
            print("This is the latitude of the pin in taskForGetImages: \(pin.lat)")
            
            if let error = error {
                completionHandlerForGetImages(nil, "There was an error getting the images: \(error)")
            } else {
                
                // Create a dictionary from the data:
                
                /* GUARD: Are the "photos" and "photo" keys in our result? */
                if let photosDictionary = results![Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                    //displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                    
                for photo in photoArray {
                    
                    // GUARD: Does our photo have a key for 'url_m'?
                    guard let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                        completionHandlerForGetImages(nil, "Unable to find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)")
                        return
                    }
                    
                    //var image = UIImage()
                    // if an image exists at the url, set the image and title
                    let imageURL = URL(string: imageUrlString)!
                    
                    
                    // get the remaining metadata
                    let farm = photo["farm"] as? Int ?? 0
                    let id = photo["id"] as? String ?? ""
                    let isFamily = photo["isfamily"] as? Int ?? 0
                    let isFriend = photo["isfriend"] as? Int ?? 0
                    let isPublic = photo["ispublic"] as? Int ?? 0
                    let owner = photo["owner"] as? String ?? ""
                    let secret = photo["secret"] as? String ?? ""
                    let server = photo["server"] as? String ?? ""
                    let title = photo["title"] as? String ?? ""
                    
                    pin.images.append(Image(imageURL: imageURL, farm: farm, id: id, isFamily: isFamily, isFriend: isFriend, isPublic: isPublic, owner: owner, secret: secret, server: server, title: title))
                    
                }
                print("There are \(pin.images.count) images in the image array")
                print("This the latitude of the pin after the for loop: \(pin.lat)")
                Pin.inventory.append(pin)
                    print("Pin inventory count is: \(Pin.inventory.count)")
            }
                print("This is the latitude of the pin being sent the completion handler: \(pin.lat)")
            completionHandlerForGetImages(pin, nil)
            print("We connected with the Flickr API")
            }
        }
    }
    
}
