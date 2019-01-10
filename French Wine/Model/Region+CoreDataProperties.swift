//
//  Region+CoreDataProperties.swift
//  French Wine
//
//  Created by Jan Polzer on 1/9/19.
//  Copyright © 2019 Apps KC. All rights reserved.
//
//

import Foundation
import CoreData


extension Region {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Region> {
        return NSFetchRequest<Region>(entityName: "Region")
    }

    @NSManaged public var name: String?
    @NSManaged public var summary: String?
    @NSManaged public var type: String?
    @NSManaged public var varieties: NSSet?

}

// MARK: Generated accessors for varieties
extension Region {

    @objc(addVarietiesObject:)
    @NSManaged public func addToVarieties(_ value: Variety)

    @objc(removeVarietiesObject:)
    @NSManaged public func removeFromVarieties(_ value: Variety)

    @objc(addVarieties:)
    @NSManaged public func addToVarieties(_ values: NSSet)

    @objc(removeVarieties:)
    @NSManaged public func removeFromVarieties(_ values: NSSet)

}
