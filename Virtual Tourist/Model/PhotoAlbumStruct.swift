//
//  PhotoAlbumStruct.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/18/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import CoreLocation
import UIKit

struct PhotoAlbumStruct {
    var selectedPin : CLLocationCoordinate2D?
    var images : [UIImage]?
//    var photosObject : [[String: AnyObject]]?
//    var photoCount: Int?

    
    
    init(selectedPin : CLLocationCoordinate2D?, images: [UIImage]?) {
      
        if let selectedPin = selectedPin {
            self.selectedPin = selectedPin
        }

        if let images = images {
            self.images = images
        }


        
    }
    
}


