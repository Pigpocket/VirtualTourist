//
//  CollectionViewController.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/18/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    
    // MARK: Properties
    
    var selectedPin: Pin!
    var innerSpace: CGFloat = 1.0
    var numberOfCellsOnRow: CGFloat = 3.0
    var annotation = MKPointAnnotation()
    var pageCount: Int = 1
    var activityIndicator = UIActivityIndicatorView()
    var photos: [Images?] = []
    
    // MARK: Actions
    
    /*
    @IBAction func newCollectionAction(_ sender: Any) {
        
        pageCount += 1
            
        self.deleteImages()

        FlickrClient.sharedInstance().getImagesFromFlickr(latitude: selectedPin.latitude, longitude: selectedPin.longitude, page: pageCount, completionHandlerForGetImages: { (pin, error) in
            
            if let pin = pin {
                self.selectedPin = pin
                print("latitude= \(pin.latitude)")
                print("longitude= \(pin.longitude)")
                performUIUpdatesOnMain {
                    self.collectionView.reloadData()
                }
            }
        })
    }
 */
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
 
        setAnnotations()
        
        /*
        if self.photos.count == 0 {
            FlickrClient.sharedInstance().getImagesFromFlickr(pin: self.selectedPin, context: CoreDataStack.sharedInstance().context, page: self.pageCount, completionHandlerForGetImages: { (images, error) in
                
                if let images = images {
                    
                    performUIUpdatesOnMain {
                    for image in images {
                        self.photos.append(image)
                        print("This is the photos count in the photos array: \(self.photos.count)")
                    }
                    }
                } else {
                    print("No images existed")
                }
            })
        } */
        print("Final count of photos in the photos array: \(photos.count)")
        //print("This is what selectedPin looks like: \n \(selectedPin)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
        
    }
    
    func itemWidth() -> CGFloat {
        return ((UIScreen.main.bounds.width - (self.innerSpace * 2)) / self.numberOfCellsOnRow)
    }
    
    // MARK: Map functions
    
    func setAnnotations() {
        
        // Set the coordinates
        let coordinates = CLLocationCoordinate2D(latitude: selectedPin.latitude, longitude: selectedPin.longitude)
        
        // Set the map region
        let region = MKCoordinateRegionMake(coordinates, MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        self.mapView.setRegion(region, animated: true)
        self.mapView.delegate = self
        
        // Set the annotation
        //let title = "\((pin.images) + " " + (User.shared.lastName))"
        //let subtitle = locationData.mediaURL
        annotation.coordinate = coordinates
        //annotation.title = title
        //annotation.subtitle = subtitle
        
        // Add the annotation
        mapView.addAnnotation(self.annotation)
        self.mapView.addAnnotation(self.annotation)
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath) as! CollectionViewCell
        let photo = photos[indexPath.row]
        
        // Get a photo if it already exists
        if let photo = photo {
            performUIUpdatesOnMain {
                cell.imageView.image = photo.getImage()
                print("This is what getImage function looks like: \(String(describing: photo.getImage()))")
            }
        }
        //} else {
            
            /*FlickrClient.sharedInstance().imageDataForPhoto(image: photo, completionHandler: { (imageData, error) in
                
                guard error == nil else {
                    return
                }
                
                performUIUpdatesOnMain {
                    cell.imageView.image = UIImage(data: imageData!)
                }
            }) */
            
            /* Otherwise get the
            FlickrClient.sharedInstance().getImagesFromFlickr(latitude: selectedPin.latitude, longitude: selectedPin.longitude, page: pageCount) { (pin, error) in
                
                if let pin = pin {
                    let url = pin.images[indexPath.item].imageURL
                    let data = try? Data(contentsOf: url)
                    performUIUpdatesOnMain {
                        cell.imageView.image = UIImage(data: data!)
                        cell.imageView.contentMode = .scaleAspectFill
                        }
                    }
                } */
            //}
        return cell
    }
    
    func deleteImages(){
        //if selectedPin.images.count > 0 {
            
            selectedPin.images = []
          //  print("Pin contains \(selectedPin.images.count) images")
            
            //sharedContext.deleteObject(photo)
            
            
            // Remove from documents directory
            /*let id: String = "\(photo.imageID).jpg"
            photo.removeFromDocumentsDirectory(id) */
        //}
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}

