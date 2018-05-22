//
//  DataController.swift
//  Virtual Tourist
//
//  Created by NISHANTH NAGELLA on 5/22/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(_ modelName : String) {
        self.persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion : (()-> Void)? = nil) {
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            
            
        }
        
    }
}
