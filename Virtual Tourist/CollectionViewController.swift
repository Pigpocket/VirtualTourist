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
    
    // MARK: Actions
    
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
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
                    self.collectionView.reloadData()
                }
            }
        })
    }

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
 
        setAnnotations()
        
//        for photo in photos {
//            FlickrClient.sharedInstance().imageDataForPhoto(image: photo) { (imageData, error) in
//
//                guard error == nil else {
//                    print("There is an error: \(String(describing: error))")
//                    return
//                }
//
//                if let imageData = imageData {
//                    performUIUpdatesOnMain {
//                        self.imageData.append(imageData)
//
//                    }
//                }
//            }
//        }
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
        
        if let photo = photo {
            performUIUpdatesOnMain {
                let url = URL(string: photo.imageURL!)
                //let data = try? Data(contentsOf: url!)
                cell.imageView.setImage(url: url!)
                print("The pin image quantity in new viewController is \(String(describing: self.selectedPin.images?.count))")
            }
        }
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
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}

