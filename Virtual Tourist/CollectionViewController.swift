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

class CollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var MapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    
    // MARK: Properties
    
    var pin = Pin()
    var innerSpace: CGFloat = 1.0
    var numberOfCellsOnRow: CGFloat = 3.0
    
    // MARK: Actions
    
    @IBAction func newCollectionAction(_ sender: Any) {
        
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
        
        print("Images quantity in Pin in CollectionViewController: \(pin.images.count)")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

    }
    
    func itemWidth() -> CGFloat {
        return ((UIScreen.main.bounds.width - (self.innerSpace * 2)) / self.numberOfCellsOnRow)
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
        cell.imageView.image = pin.images[indexPath.item].image
        cell.imageView.contentMode = .scaleAspectFill
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
}

