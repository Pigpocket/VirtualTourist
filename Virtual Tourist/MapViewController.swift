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

class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    let annotation = MKPointAnnotation()
    let annotationArray: [MKPointAnnotation] = []
    
    var pin: Pin = Pin()
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Implement the tap gesture recognizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        mapView.addGestureRecognizer(longPressRecognizer)
        
        self.mapView.delegate = self
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
        annotation.title = "placeholder"
        
        // Add the annotation
        mapView.addAnnotation(annotation)
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is MKPinAnnotationView)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            // Set the coordinates in the Pin struct
            pin.lat = pinView!.annotation!.coordinate.latitude as Double
            pin.lon = pinView!.annotation!.coordinate.longitude as Double
            
            // Download the images for the coordinates
            FlickrClient.sharedInstance().getImagesFromFlickr(latitude: pin.lat, longitude: pin.lon, page: 1, completionHandlerForGetImages: { (pin, error) in
                
                if let pin = pin {
                    self.pin = pin
                    print("Networking pin unwrapping latitude= \(pin.lat)")
                    print("Networking pin unwrapping longitude= \(pin.lon)")
                }
            })
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if view.annotation?.title != nil {
            print("Pin was selected")
            self.performSegue(withIdentifier: "collectionViewSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "collectionViewSegue" {
            
            performUIUpdatesOnMain {
            let controller = segue.destination as! CollectionViewController
                print("Pin inventory in prepForSegue is \(Pin.inventory.count)")
            for pinFag in Pin.inventory {
                if pinFag.lat == self.annotation.coordinate.longitude && pinFag.lon == self.annotation.coordinate.longitude {
                        controller.pin = pinFag
                    print("prepareForSegue pin properties in exsiting pin are: \(pinFag)")
                } else {
                        controller.pin = self.pin
                        print("PrepareForSegue pin properties are: \(self.pin)")
                    }
                }
            }
        }
    }
}


