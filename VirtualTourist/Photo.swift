//
//  Photo.swift
//  VirtualTourist
//
//  Created by Laura Evans on 2/18/16.
//  Copyright © 2016 Laura Evans. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let FilePath = "file_path"
    }
    
    @NSManaged var filePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        filePath = dictionary[Keys.FilePath] as? String
    }
    
}
