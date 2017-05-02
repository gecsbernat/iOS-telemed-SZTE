//
//  NaploEntity+CoreDataProperties.swift
//  ios-telemed
//
//  Created by Rita Sumegi on 2017. 05. 02..
//  Copyright © 2017. ios2017. All rights reserved.
//

import Foundation
import CoreData


extension NaploEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NaploEntity> {
        return NSFetchRequest<NaploEntity>(entityName: "NaploEntity")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var sys: Double
    @NSManaged public var dia: Double
    @NSManaged public var event: String?

}
