//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/17/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    let annotation = MKPointAnnotation()
    let annotationArray: [MKPointAnnotation] = []
    
    var selectedPin: Pin?
    var images: [Images?] = []
    
    // MARK: Outlets
    
    @IBOutlet weak var editButtonLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        self.mapView.delegate = self
        
        // Implement the tap gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(longPressRecognizer)
        
        loadAnnotations()
    }
    
    // MARK: Lifecycle
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer) {
        if gestureRecognizer.state != .began { return }
        print("Tap gesture recognized")
        
        // Create the annotation
        let touchPoint = gestureRecognizer.location(in: mapView)
        let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom:self.mapView)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newCoordinate

        // Initialize NSManagedObject 'Pin' with properties
        selectedPin = Pin(context: CoreDataStack.sharedInstance().context)
        selectedPin?.latitude = annotation.coordinate.latitude
        selectedPin?.longitude = annotation.coordinate.longitude
            
        if let selectedPin = selectedPin {
            let pinAnnotation = PinAnnotation(objectID: selectedPin.objectID, title: nil, subtitle: nil, coordinate: annotation.coordinate)
            mapView.addAnnotation(pinAnnotation)
        
            FlickrClient.sharedInstance().getImagesFromFlickr(pin: selectedPin, context: CoreDataStack.sharedInstance().context, page: 1) { (images, error) in
            
                guard error == nil else {
                    print("There was an error get images objects")
                    return
                }
                }
            }
        print("The context has changes: \(CoreDataStack.sharedInstance().context.hasChanges)")
    }
    
    func loadAnnotations() {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")

        do {
            if let pins = try? CoreDataStack.sharedInstance().context.fetch(fetchRequest) as! [Pin] {
                var pinAnnotations = [PinAnnotation]()
                
                for pin in pins {
                    let latitude = CLLocationDegrees(pin.latitude)
                    let longitude = CLLocationDegrees(pin.longitude)
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    pinAnnotations.append(PinAnnotation(objectID: pin.objectID, title: nil, subtitle: nil, coordinate: coordinate))
                }
                mapView.addAnnotations(pinAnnotations)
            }
        }
    }

    @IBAction func editPinAction(_ sender: Any) {
        editButtonItem.isEnabled = true
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is MKPinAnnotationView)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if !isEditing {
            do {
                let pinAnnotation = view.annotation as! PinAnnotation
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
                fetchRequest.predicate = predicate
                let pins = try CoreDataStack.sharedInstance().context.fetch(fetchRequest) as? [Pin]
                selectedPin = pins![0]
            } catch let error as NSError {
                print("failed to get pin by object id")
                print(error.localizedDescription)
                return
            }
            self.performSegue(withIdentifier: "collectionViewSegue", sender: self)
        }
        
        if isEditing {
            print("We're in editing mode")
            do {
                let pinAnnotation = view.annotation as! PinAnnotation
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
                let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", argumentArray: [pinAnnotation.coordinate.latitude, pinAnnotation.coordinate.longitude])
                fetchRequest.predicate = predicate
                let pins = try CoreDataStack.sharedInstance().context.fetch(fetchRequest) as? [Pin]
                selectedPin = pins![0]
                CoreDataStack.sharedInstance().context.delete(selectedPin!)
                mapView.removeAnnotation(view.annotation!)
                CoreDataStack.sharedInstance().saveContext()
                return
            } catch let error as NSError {
                print("failed to get by object id")
                print(error.localizedDescription)
                return
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionViewSegue" {
            let controller = segue.destination as! CollectionViewController
            print("CoreDataStack context in segue= \(CoreDataStack.sharedInstance().context)")
            if let selectedPin = selectedPin {
                controller.selectedPin = selectedPin
            }
        }
    }
    
}




