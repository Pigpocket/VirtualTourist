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
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionFlow: UICollectionViewFlowLayout!
    //var gridCollectionView: UICollectionView!
    //var collectionViewFlowLayout: CollectionViewFlowLayout!
    
    var innerSpace: CGFloat = 1.0
    var numberOfCellsOnRow: CGFloat = 3.0
    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath) as! CollectionViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.collectionCellLabel.text = self.items[indexPath.item]
        cell.backgroundColor = UIColor.cyan // make cell more visible in our example project
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionFlow.minimumLineSpacing = 1.0
        collectionFlow.minimumInteritemSpacing = 1.0
        collectionFlow.scrollDirection = .vertical
        
        //collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
//        collectionViewFlowLayout = CollectionViewFlowLayout()
//        gridCollectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewFlowLayout)
//        gridCollectionView.backgroundColor = UIColor.orange
//        gridCollectionView.showsVerticalScrollIndicator = false
//        gridCollectionView.showsHorizontalScrollIndicator = false
//        self.view.addSubview(gridCollectionView)
//
//        gridCollectionView!.register(CollectionViewCell.self, forCellWithReuseIdentifier: "imageCell")
//        gridCollectionView.dataSource = self
//        gridCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    
        
    collectionFlow.itemSize = CGSize(width:itemWidth(), height: itemWidth())
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
//        var frame = gridCollectionView.frame
//        frame.size.height = self.view.frame.size.height
//        frame.size.width = self.view.frame.size.width
//        frame.origin.x = 0
//        frame.origin.y = 0
//        gridCollectionView.frame = frame
    }
    
    func itemWidth() -> CGFloat {
        print("This is the width: \(collectionView.frame.size.width)")
        print("This is width minus space: \(collectionView.frame.size.width - (self.innerSpace * 2))")
        print("Final value is: \((collectionView!.frame.size.width - (self.innerSpace * 2)) / self.numberOfCellsOnRow)")
        print("Application width is: \(UIScreen.main.bounds.width)")
        return ((UIScreen.main.bounds.width - (self.innerSpace * 2)) / self.numberOfCellsOnRow)
    }

}

