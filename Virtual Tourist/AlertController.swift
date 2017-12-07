//
//  AlertController.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 12/6/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit

class AlertView {
    
    class func showAlert(view: UIViewController , message: String) {
        let alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        performUIUpdatesOnMain {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    class func showAlertDialog(view: UIViewController, message: String) {
        
        let alert = UIAlertController(title: "Overwrite location?", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        performUIUpdatesOnMain {
            view.present(alert, animated: true, completion: nil)
        }
    }
    
    static func startActivityIndicator(_ view: CollectionViewCell, activityIndicator: UIActivityIndicatorView) {
        
        activityIndicator.center = view.center
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        let centerX =  NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let centerY =  NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        view.addSubview(activityIndicator)
        view.addConstraints([centerX,centerY])
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    static func stopActivityController(_ view: CollectionViewCell, activityIndicator: UIActivityIndicatorView) {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
}
