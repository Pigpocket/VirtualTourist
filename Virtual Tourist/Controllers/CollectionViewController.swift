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
//import Imaginary
import CoreData

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // Initialize FetchedResultsController
    
    lazy var fetchedResultsController: NSFetchedResultsController<Images> = { () -> NSFetchedResultsController<Images> in
        
        let fetchRequest = NSFetchRequest<Images>(entityName: "Images")
        fetchRequest.sortDescriptors = []
        
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [selectedPin])
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance().context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: Properties
    
    // Keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    var selectedPin: Pin!
    var innerSpace: CGFloat = 1.0
    var numberOfCellsOnRow: CGFloat = 3.0
    var annotation = MKPointAnnotation()
    var pageCount: Int = 1
    var selectedIndexes = [IndexPath]()
    
    // MARK: Actions
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
        // If no images are selected, get a new image collection
        if selectedIndexes.isEmpty {
            
            // Increment the page count
            pageCount += 1
            
            // Delete existing images
            self.deleteImages()

            // Get new images from Flickr
            FlickrClient.sharedInstance().getImagesFromFlickr(pin: selectedPin, context: CoreDataStack.sharedInstance().context, page: pageCount, completionHandlerForGetImages: { (success, error) in
                
                // Make sure there were no errors
                guard error == nil else {
                    print("There was an error getting the images")
                    return
                }
                
                if success {
                    performUIUpdatesOnMain {
                        self.configureLabel()
                        self.collectionView.reloadData()
                    }
                }
            })
            
        // If there were images selected, remove them
        } else {
            
            self.deleteImages()
            
            collectionView.performBatchUpdates ({
            
            }
            // When completed....
            , completion: { (completed) in

                performUIUpdatesOnMain {
                    CoreDataStack.sharedInstance().saveContext()
                }
            })
            
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
        
        performUIUpdatesOnMain {
            self.configureLabel()
        }
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
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
        annotation.coordinate = coordinates
        
        // Add the annotation
        mapView.addAnnotation(self.annotation)
        self.mapView.addAnnotation(self.annotation)
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]

        return sectionInfo.numberOfObjects // photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath) as! CollectionViewCell
        
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        cell.activityIndicator.center = CGPoint(x: cell.frame.size.width/2, y: cell.frame.size.height/2)
        
        performUIUpdatesOnMain {
            cell.activityIndicator.startAnimating()
        }
        let image = self.fetchedResultsController.object(at: indexPath)
        //let url = URL(string: image.imageURL!)
        
        cell.imageView.image = image.image
        
        
//        cell.imageView.setImage(url: url!) { result in
//            performUIUpdatesOnMain {
//                cell.activityIndicator.stopAnimating()
//            }
//        }
        
        if let _ = self.selectedIndexes.index(of: indexPath) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }
    
        return cell
    }
    
    func configureLabel() {
        if self.selectedPin.images?.count != 0 {
            self.noImagesLabel.isHidden = true
        } else {
            self.noImagesLabel.isHidden = false
        }
    }
    
    func deleteImages() {
        var imagesToDelete = [Images]()
        
        if selectedIndexes.isEmpty {
            for image in selectedPin.images! {
                CoreDataStack.sharedInstance().context.delete(image as! NSManagedObject)
            }
        }
        
        for indexPath in selectedIndexes {
            imagesToDelete.append(fetchedResultsController.object(at: indexPath) )
        }
        
        for image in imagesToDelete {
            CoreDataStack.sharedInstance().context.delete(image)
        }
        
        selectedIndexes = [IndexPath]()
    }
    
    func setBarButtonText() {
        newCollectionButton.title = selectedIndexes.count > 0 ? "Remove Selected Photos" : "New Collection"
        newCollectionButton.tintColor = newCollectionButton.title == "Remove Selected Photos" ? UIColor.red : UIColor(red: 0, green: 0.48, blue: 1, alpha: 1)
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
  
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
}

