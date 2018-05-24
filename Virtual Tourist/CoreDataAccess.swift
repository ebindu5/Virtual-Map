//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/23/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import CoreData
import UIKit

class CoreDataAccess {
  
    var dataController : DataController!
    
    static let sharedInstance = CoreDataAccess()
    
    private init() {
        dataController = DataController("VirtualTouristModel")
        dataController.load()
    }
    
    func fetchAllPinPhotos(_ selectedPin : Pins)-> [PinPhotos] {
        let fetchRequest : NSFetchRequest<PinPhotos> = PinPhotos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "pins == %@", selectedPin)
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
           return result
        }
        return []
    }
    
     func fetchAllPins()-> [Pins] {
        let fetchRequest: NSFetchRequest<Pins> = Pins.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptors]
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            return result
        }
        return []
    }
    
    func createPin(_ latitude: Double, _ longitude: Double)->Pins? {
        let pin = Pins(context: dataController.viewContext)
        pin.latitude = latitude
        pin.longitude = longitude
        pin.creationDate = Date()
        try? dataController.viewContext.save()
        return pin
    }
    
    func deletePin(_ selectedPin: Pins)-> Bool{
        dataController.viewContext.delete(selectedPin)
        do{
        try dataController.viewContext.save()
            return true
        }catch{
            return false
        }
    }
    
    func deleteAllImages(_ allImages : [PinPhotos]){
        if allImages.count != 0 {
            for object in allImages {
                try? dataController.viewContext.delete(object)
            }
            try? dataController.viewContext.save()
        }
    }
    
    
    func saveImageData(_ imageData: Data, _ selectedPin: Pins)-> PinPhotos?{
        let pinData = PinPhotos(context: self.dataController.viewContext)
        pinData.images = imageData
        pinData.pins = selectedPin
        pinData.creationDate = Date()
        do {
            try self.dataController.viewContext.save()
            return pinData
        } catch {
            return nil
        }
    }
    
}
