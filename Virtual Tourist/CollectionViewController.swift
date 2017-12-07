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
    
    var pin = Pin()
    var innerSpace: CGFloat = 1.0
    var numberOfCellsOnRow: CGFloat = 3.0
    var annotation = MKPointAnnotation()
    var pageCount: Int = 1
    var activityIndicator = UIActivityIndicatorView()
    
    // MARK: Actions
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        pageCount += 1
            
        self.deleteImages()
        
        let collectionViewCell = CollectionViewCell()
        
        AlertView.startActivityIndicator(collectionViewCell, activityIndicator: activityIndicator)
        
        FlickrClient.sharedInstance().getImagesFromFlickr(latitude: pin.lat, longitude: pin.lon, page: pageCount, completionHandlerForGetImages: { (pin, error) in
            
            if let pin = pin {
                self.pin = pin
                print("latitude= \(pin.lat)")
                print("longitude= \(pin.lon)")
                performUIUpdatesOnMain {
                    AlertView.stopActivityController(collectionViewCell, activityIndicator: self.activityIndicator)
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        print("viewDidLoad latitude= \(pin.lat)")
        print("viewDidLoad longtiude= \(pin.lon)")
        
        self.collectionView.reloadData()
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
        
        print("Images quantity in Pin in CollectionViewController: \(pin.images.count)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
        setAnnotations()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    func itemWidth() -> CGFloat {
        return ((UIScreen.main.bounds.width - (self.innerSpace * 2)) / self.numberOfCellsOnRow)
    }
    
    // MARK: Map functions
    
    func setAnnotations() {
        
        // Set the coordinates
        let coordinates = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lon)
        
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
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.pin.images.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath) as! CollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        
        if cell.imageView.image != nil {
            cell.prepareForReuse()
        }
        
        cell.imageView.image = pin.images[indexPath.item].image
        cell.imageView.contentMode = .scaleAspectFill
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    func deleteImages(){
        if pin.images.count > 0 {
            
            print("Before deleteImages, pin latitude= \(pin.lat)")
            print("Before deleteImages, pin longitude= \(pin.lon)")
            pin.images = []
            print("Pin contains \(pin.images.count) images")
            print("After deleteImages, pin latitude= \(pin.lat)")
            print("After deleteImages, pin longitude= \(pin.lon)")
            
            //sharedContext.deleteObject(photo)
            
            
            // Remove from documents directory
            /*let id: String = "\(photo.imageID).jpg"
            photo.removeFromDocumentsDirectory(id) */
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}

