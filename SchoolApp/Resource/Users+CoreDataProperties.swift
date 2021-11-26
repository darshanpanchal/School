//
//  Users+CoreDataProperties.swift
//  
//
//  Created by user on 04/07/19.
//
//

import Foundation
import CoreData


extension Users {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users> {
        return NSFetchRequest<Users>(entityName: "Users")
    }

    @NSManaged public var birth_date: String?
    @NSManaged public var class_id: String?
    @NSManaged public var class_name: String?
    @NSManaged public var current_address: String?
    @NSManaged public var divison_name: String?
    @NSManaged public var email1: String?
    @NSManaged public var email2: String?
    @NSManaged public var father_name: String?
    @NSManaged public var gender: String?
    @NSManaged public var gr_no: String?
    @NSManaged public var phone_number1: String?
    @NSManaged public var phone_number2: String?
    @NSManaged public var roll_no: String?
    @NSManaged public var school_lat: String?
    @NSManaged public var school_long: String?
    @NSManaged public var student_id: String?
    @NSManaged public var student_name: String?
    @NSManaged public var student_photo: String?
    @NSManaged public var surname: String?
    @NSManaged public var teacher: String?
    @NSManaged public var userId: String?
    @NSManaged public var username: String?
    @NSManaged public var userschoolname: String?
    @NSManaged public var userrole: String?
    @NSManaged public var userrole_id: String?

}
