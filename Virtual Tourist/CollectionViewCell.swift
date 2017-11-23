//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Tomas Sidenfaden on 11/18/17.
//  Copyright © 2017 Tomas Sidenfaden. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var collectionCellLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    //var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
    
}
