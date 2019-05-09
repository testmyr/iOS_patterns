//
//  ImageUrl.swift
//  VIPERTrainingApp
//
//  Created by sdk on 5/8/19.
//  Copyright © 2019 Sdk. All rights reserved.
//

import UIKit
import CoreData

class ImageUrl: NSManagedObject {
    @NSManaged var timeStamp: Date
    @NSManaged var url: String
}
