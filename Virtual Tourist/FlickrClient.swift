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

    func getImageFromFlickr(completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.GalleryID: Constants.FlickrParameterValues.GalleryID,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
        ]
        
        // create url and request
        let session = URLSession.shared
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandler(false, "There was an error")
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "There was an error")
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                completionHandler(false, "There was an error")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                completionHandler(false, "There was an error")
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                completionHandler(false, "There was an error")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                completionHandler(false, "There was an error")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                completionHandler(false, "There was an error")
                return
            }
            
            // select a random photo
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
         
 
            // GUARD: Does our photo have a key for 'url_m'?
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                completionHandler(false, "There was an error")
                return
            }
            
            // if an image exists at the url, set the image and title
            let imageURL = URL(string: imageUrlString)
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                    Photos.shared.image = UIImage(data: imageData)!
                    print("The image data is: \(UIImage(data: imageData)!)")
                    Photos.shared.photoTitleLabel = photoTitle ?? "(Untitled)"
                    completionHandler(true, nil)
                }
            } else {
                displayError("Image does not exist at \(imageURL!)")
            }
        }

        // start the task!
        task.resume()
    }
    
    func getImagesFromFlicker(latitude: Any, longitude: Any, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.FlickrPhotosSearch,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Lat: latitude as Any,
            Constants.FlickrParameterKeys.Lon: longitude as Any,
            Constants.FlickrParameterKeys.PerPage: Constants.FlickrParameterValues.PerPage,
        ]
        
        // create url and request
        let session = URLSession.shared
        let urlString = Constants.Flickr.APIBaseURL + escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        //print("This is what the URL request looks like: \n ****** \n \(url) \n ********")
        let request = URLRequest(url: url)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandler(false, "There was an error")
                performUIUpdatesOnMain {
                    //self.setUIEnabled(true)
                }
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(false, "There was an error")
                displayError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2xx!")
                completionHandler(false, "There was an error")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError("No data was returned by the request!")
                completionHandler(false, "There was an error")
                return
            }
            
            // parse the data
            let parsedResult: [String:Any]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
            } catch {
                displayError("Could not parse the data as JSON: '\(data)'")
                completionHandler(false, "There was an error")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)?
            guard let stat = parsedResult[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                displayError("Flickr API returned an error. See error code and message in \(parsedResult)")
                completionHandler(false, "There was an error")
                return
            } */
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                displayError("Cannot find keys '\(Constants.FlickrResponseKeys.Photos)' and '\(Constants.FlickrResponseKeys.Photo)' in \(parsedResult)")
                completionHandler(false, "There was an error")
                return
            }
            
            //var imageGallery: [Image] = []
            
            for photo in photoArray {
                
                // GUARD: Does our photo have a key for 'url_m'?
                guard let imageUrlString = photo[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    displayError("Cannot find key '\(Constants.FlickrResponseKeys.MediumURL)' in \(photo)")
                    completionHandler(false, "There was an error")
                    return
                }
                
                var image = UIImage()
                // if an image exists at the url, set the image and title
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                        //self.setUIEnabled(true)
                        image = UIImage(data: imageData)!
                        print("The image data is: \(UIImage(data: imageData)!)")
                        completionHandler(true, nil)
                }
                
                // get the photo
                /*let imageUrlString = photo["url-m"] as? String ?? ""
                let imageURL = URL(string: imageUrlString)
                var image = UIImage()
                if let imageData = try? Data(contentsOf: imageURL!) {
                    image = UIImage(data: imageData)!
                } */
 
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
            
                Image.imageGallery.append(Image(image: image, farm: farm, id: id, isFamily: isFamily, isFriend: isFriend, isPublic: isPublic, owner: owner, secret: secret, server: server, title: title))
            }
            completionHandler(true, nil)

            print("There are \(Image.imageGallery.count) images in the imageGallery")
            //print("These is the fourth image in the imageGallery: \(imageGallery[3].image)")
        }
        print("We connected with the Flickr API")
        // start the task!
        task.resume()
    }
    
    // MARK: Helper for Escaping Parameters in URL
    
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
