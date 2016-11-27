//
//  Transaction+CoreDataProperties.swift
//  
//
//  Created by KOBOKKYUNG on 2016. 11. 27..
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction");
    }

    @NSManaged public var currency: String?
    @NSManaged public var time: NSDate?
    @NSManaged public var amount: Float
    @NSManaged public var decision: String?
    @NSManaged public var profit: Float

}
