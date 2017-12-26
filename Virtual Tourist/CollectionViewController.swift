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
        if selectedIndexes.isEmpty {
            pageCount += 1
            
            self.deleteImages()

            FlickrClient.sharedInstance().getImagesFromFlickr(pin: selectedPin, context: CoreDataStack.sharedInstance().context, page: pageCount, completionHandlerForGetImages: { (images, error) in
                
                guard error == nil else {
                    print("There was an error getting the images")
                    return
                }
                
                if let images = images {
                    self.photos = images
                    performUIUpdatesOnMain {
                        for image in images {
                            self.selectedPin.addToImages(image)
                        }
                        self.collectionView.reloadData()
                    }
                }
            })
        } else {
            //var selectedPhotos = [Images]()
            
            collectionView.performBatchUpdates ({
                
                let sortedIndexes = self.selectedIndexes.sorted(by: {$0.row > $1.row})
                
                for indexPath in sortedIndexes {
                    if let photoObject = self.photos[indexPath.row] {
                        self.photos.remove(at: indexPath.row)
                        self.collectionView.deleteItems(at: [indexPath])
                        self.selectedPin.removeFromImages(photoObject)
                        print("Number of images in pin: \(String(describing: self.selectedPin.images?.count))")
                        print("Number of images in photos array: \(self.photos.count)")
                        //selectedPhotos.append(photoObject)
                    }
                }
            }
                , completion: { (completed) in
                    
                    if self.photos.count == 0 {
                        performUIUpdatesOnMain {
                            //self.noImagesLabel.text = "Album is Empty"
                            //self.noImagesLabel.hidden = false
                            CoreDataStack.sharedInstance().saveContext()
                        }
                    }
            })
            
            //for photo in selectedPhotos {
              //  CoreDataStack.sharedInstance().context.delete(photo)
            //}
            
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
        let photo = photos[indexPath.row]
        
        if let photo = photo {
            performUIUpdatesOnMain {
                let url = URL(string: photo.imageURL!)
                //let data = try? Data(contentsOf: url!)
                
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

