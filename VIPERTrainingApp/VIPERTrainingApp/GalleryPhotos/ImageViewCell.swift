//
//  ImageViewCell.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import Foundation
import UIKit

class ImageViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgVwGalleryImage: UIImageView!
    
    var representedAssetIdentifier: String!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgVwGalleryImage.image = nil
    }
}
