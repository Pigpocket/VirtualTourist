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
import Imaginary

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
    var imageData: [Data?] = []
    var selectedIndexes = [IndexPath]()
    
    // MARK: Actions
    
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        print("selectedIndexes count is: \(selectedIndexes.count)")
        
        // If no images are selected, get a new image collection
        if selectedIndexes.isEmpty {
            
            // Increment the page count
            pageCount += 1
            
            // Delete existing images
            self.deleteImages()

            // Get new images from Flickr
            FlickrClient.sharedInstance().getImagesFromFlickr(pin: selectedPin, context: CoreDataStack.sharedInstance().context, page: pageCount, completionHandlerForGetImages: { (images, error) in
                print("1. There are now \(String(describing: self.selectedPin.images?.count)) images in the pin")
                
                // Make sure there were no errors
                guard error == nil else {
                    print("There was an error getting the images")
                    return
                }
                
                // If we got images
                if let images = images {
                    print("\(images.count) images were sent to the completionHandler")
                    print("2. There are now \(String(describing: self.selectedPin.images?.count)) images in the pin")
                    
                    // Add them to our class level image array
                    self.photos = images

                    print("There are \(self.photos.count) images in photos after completionHandler")
                    print("3. There are now \(String(describing: self.selectedPin.images?.count)) images in the pin")

                    print("4. There are now \(String(describing: self.selectedPin.images?.count)) images in the pin")
                    self.selectedPin.images?.adding(images)
                        performUIUpdatesOnMain {
                            self.collectionView.reloadData()
                        }
                }
            })
            
        // If there were images selected, remove them
        } else {
            
            // Create a local array of Images
            var selectedPhotos = [Images]()
            
            collectionView.performBatchUpdates ({
            
                // Sort the indexes
                let sortedIndexes = self.selectedIndexes.sorted(by: {$0.row > $1.row})
                
                for indexPath in sortedIndexes {
                    
                    // If an image exists
                    if let photoObject = self.photos[indexPath.row] {
                        
                        // Remove it from the class array
                        self.photos.remove(at: indexPath.row)
                        
                        // Remove it from the collectionView
                        self.collectionView.deleteItems(at: [indexPath])
                        
                        // Remove it from the selectedPin object
                        self.selectedPin.removeFromImages(photoObject)
                        print("3. Number of images in pin: \(String(describing: self.selectedPin.images?.count))")
                        print("3. Number of images in photos array: \(self.photos.count)")
                        
                        // Add the selected image object to the local array of Images
                        selectedPhotos.append(photoObject)
                    }
                }
            }
                // When completed....
                , completion: { (completed) in
                    
                    // If there are no images in the local array of Images
                    if self.photos.count == 0 {
                        performUIUpdatesOnMain {
                            //self.noImagesLabel.text = "Album is Empty"
                            //self.noImagesLabel.hidden = false
                            
                            // Save the context
                            CoreDataStack.sharedInstance().saveContext()
                        }
                    }
            })
            
            
            for photo in selectedPhotos {
                self.selectedPin.removeFromImages(photo)
                CoreDataStack.sharedInstance().context.delete(photo)
                print("4. There are now \(String(describing: self.selectedPin.images?.count)) images in the pin")
                print("5. There are now \(String(describing: self.photos.count)) images in the photos array")
                
            }
            
            CoreDataStack.sharedInstance().saveContext()
            
            selectedIndexes.removeAll()
            collectionView.reloadData()
            
            setBarButtonText()
        }
    }

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
 
        setAnnotations()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
        print("This pin has \(String(describing: selectedPin.images?.count)) images")
        
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
        annotation.coordinate = coordinates
        
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
        print("There are \(String(describing: selectedPin.images?.count)) images in the pin when cellForRowAt is called")
        print("There are \(String(describing: photos.count)) images in the photos when cellForItemAt is called")
        
        let photo = photos[indexPath.row]
        
        if let photo = photo {
            performUIUpdatesOnMain {
                let url = URL(string: photo.imageURL!)
                cell.imageView.setImage(url: url!)
                cell.imageView.alpha = 1.0
            }
        }
        print("The pin image quantity in new viewController is \(String(describing: self.selectedPin.images?.count))")
        return cell
    }
    
    func deleteImages(){
        if selectedPin.images!.count > 0 {
            selectedPin.removePhotos(context: CoreDataStack.sharedInstance().context)
            selectedPin.images = []
            photos.removeAll()
            print("Pin contains \(selectedPin.images!.count) images")
            print("Photos contains \(photos.count) photos")
        }
    }
    
    func setBarButtonText() {
        newCollectionButton.title = selectedIndexes.count > 0 ? "Remove Selected Photos" : "New Collection"
        newCollectionButton.tintColor = newCollectionButton.title == "Remove Selected Photos" ? UIColor.red : UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        
        let cell = collectionView.cellForItem(at: indexPath) as! CollectionViewCell
        
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
            cell.imageView.alpha = 1.0
        } else {
            selectedIndexes.append(indexPath)
            cell.imageView.alpha = 0.3
        }
        setBarButtonText()
    }
}

