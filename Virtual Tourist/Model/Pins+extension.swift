//
//  Pins+extension.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/22/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import MapKit

extension Pins: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        
        if latitude == nil || longitude == nil {
            return kCLLocationCoordinate2DInvalid
        }
        
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
}
