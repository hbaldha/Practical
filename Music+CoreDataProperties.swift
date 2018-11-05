//
//  Music+CoreDataProperties.swift
//  
//
//  Created by Hardik on 26/10/18.
//
//

import Foundation
import CoreData


extension Music {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Music> {
        return NSFetchRequest<Music>(entityName: "Music")
    }

    @NSManaged public var artistName: String?
    @NSManaged public var artworkUrl100: String?

}
