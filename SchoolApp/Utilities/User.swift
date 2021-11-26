//
//  User.swift
//  Live
//
//  Created by ITPATH on 4/5/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import CoreData


enum UserType:String,Codable{
    case student
    case admin
}

class User: NSObject,Codable {
    
    var userId: String = ""
    var username: String = ""
    var userschoolname: String = ""
    var student_id: String = ""
    var gr_no: String = ""
    var roll_no: String = ""
    var surname: String = ""
    var student_name: String = ""
    var father_name: String = ""
    var gender: String = ""
    var birth_date: String = ""
    var phone_number1: String = ""
    var phone_number2: String = ""
    var email1: String = ""
    var email2: String = ""
    var student_photo: String = ""
    var current_address: String = ""
    var class_id: String = ""
    var class_name: String = ""
    var divison_name: String = ""
    var teacher: String = ""
    var schoolLat:String = ""
    var schoolLong:String = ""
    var userrole:String = ""
    var userrole_id:String = ""
    var userType:UserType = .student
    init(userDetail:[String:Any]){
        super.init()
       
        if let userID = userDetail["userId"]{
           self.userId = "\(userID)"
        }
        if let studentID = userDetail["student_id"]{
            self.student_id = "\(studentID)"
        }
        if let gr_no = userDetail["gr_no"]{
            self.gr_no = "\(gr_no)"
        }
        if let roll_no = userDetail["roll_no"]{
            self.roll_no = "\(roll_no)"
        }
        if let surname = userDetail["surname"]{
            self.surname = "\(surname)"
        }
        if let student_name = userDetail["student_name"]{
            self.student_name = "\(student_name)"
        }
        if let student_name = userDetail["student_name"],let surname = userDetail["surname"]{
            self.username = "\(student_name) \(surname)"
        }
        if let father_name = userDetail["father_name"]{
            self.father_name = "\(father_name)"
        }
        if let gender = userDetail["gender"]{
            self.gender = "\(gender)"
        }
        if let birth_date = userDetail["birth_date"]{
            self.birth_date = "\(birth_date)"
        }
        if let phone_number1 = userDetail["phone_number1"]{
            self.phone_number1 = "\(phone_number1)"
        }
        if let phone_number2 = userDetail["phone_number2"]{
            self.phone_number2 = "\(phone_number2)"
        }
        if let email1 = userDetail["email1"]{
            self.email1 = "\(email1)"
        }
        if let email2 = userDetail["email2"]{
            self.email2 = "\(email2)"
        }
        if let student_photo = userDetail["student_photo"]{
            self.student_photo = "\(student_photo)"
        }
        if let student_photo = userDetail["student_photo"]{
            self.student_photo = "\(student_photo)"
        }
        if let current_address = userDetail["current_address"]{
            self.current_address = "\(current_address)"
        }
        if let class_id = userDetail["class_id"]{
            self.class_id = "\(class_id)"
        }
        if let class_name = userDetail["class_name"]{
            self.class_name = "\(class_name)"
        }
        if let divison_name = userDetail["divison_name"]{
            self.divison_name = "\(divison_name)"
        }
        if let objteacher = userDetail["teacher"],!(objteacher is NSNull){
            self.teacher = ("\(objteacher)" == "<null>" ? "" : "\(objteacher)")
        }
        if let lat = userDetail["school_lat"]{
            self.schoolLat = "\(lat)"
        }
        if let long = userDetail["school_long"]{
            self.schoolLong = "\(long)"
        }
        if let userRole = userDetail["userrole"]{
            self.userrole = "\(userRole)"
        }
        if let userRoleID = userDetail["userrole_id"]{
            self.userrole_id = "\(userRoleID)"
        }
        if let userRoleID = userDetail["userrole_id"]{
            if "\(userRoleID)" == "1"{
                self.userType = .admin
            }else if "\(userRoleID)" == "2"{
                self.userType = .student
            }
        }
    }
}
extension User{
    
    static var isUserLoggedIn:Bool{
        if let userDetail  = kUserDefault.value(forKey: kUserDetail) as? Data{
            return self.isValiduserDetail(data: userDetail)
        }else{
          return false
        }
    }
    func setuserDetailToUserDefault(){
        do{
            let userDetail = try JSONEncoder().encode(self)
            kUserDefault.setValue(userDetail, forKey:kUserDetail)
            kUserDefault.synchronize()
        }catch{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: kCommonError)
            }
        }
    }
    static func isValiduserDetail(data:Data)->Bool{
        do {
            let _ = try JSONDecoder().decode(User.self, from: data)
            return true
        }catch{
            return false
        }
    }
    static func getUserFromUserDefault() -> User?{
        if let userDetail = kUserDefault.value(forKey: kUserDetail) as? Data{
            do {
                let user:User = try JSONDecoder().decode(User.self, from: userDetail)
                return user
            }catch{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: kCommonError)
                }
                return nil
            }
        }
        DispatchQueue.main.async {
            //ShowToast.show(toatMessage: kCommonError)
        }
        return nil
    }
    static func removeUserFromUserDefault(){
        kUserDefault.removeObject(forKey:kUserDetail)
    }
    
}
struct SchoolClass {
    var strClassId:String
    var strTeacherId:String
    var strName:String
}
class DashBoardModule: NSObject {
    var moduleID: String = ""
    var moduleName: String = ""
    var slug: String = ""
    var moduleIcon: String = ""
    
    
    init(dashBoardDetail:[String:Any]){
        super.init()
        if let id = dashBoardDetail["module_id"]{
            self.moduleID = "\(id)"
        }
        if let name = dashBoardDetail["module_name"]{
            self.moduleName = "\(name)"
        }
        if let objSlug = dashBoardDetail["slug"]{
            self.slug = "\(objSlug)"
        }
        if let objIcon = dashBoardDetail["module_icon"] as? String,
            let objImage = objIcon.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){

            self.moduleIcon = "\(objImage)"
        }
    }
}
class PhotoGalleryAlbum: NSObject {
    var albumID: String = ""
    var albumName: String = ""
    var albumClasses: String = ""
    var albumDescription: String = ""
    var albumStatus: String = ""
    var albumCreated: String = ""
    var albumModified: String = ""
    var albumImage:String = ""
    
    init(photoGalleryDetail:[String:Any]){
        super.init()
        if let id = photoGalleryDetail["event_galllery_id"]{
            self.albumID = "\(id)"
        }
        if let name = photoGalleryDetail["album_name"]{
            self.albumName = "\(name)"
        }
        if let classes = photoGalleryDetail["classes"]{
            self.albumClasses = "\(classes)"
        }
        if let description = photoGalleryDetail["description"]{
            self.albumDescription = "\(description)"
        }
        if let status = photoGalleryDetail["status"]{
            self.albumStatus = "\(status)"
        }
        if let created = photoGalleryDetail["created"]{
            self.albumCreated = "\(created)"
        }
        if let modifies = photoGalleryDetail["modifies"]{
            self.albumModified = "\(modifies)"
        }
        if let attachment = photoGalleryDetail["attachment"] as? String,
            let objImage = attachment.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
            self.albumImage = "\(objImage)"
        }
    }
}
class SchoolStudent: NSObject {
    
    fileprivate var kStudentRelID = "stud_rel_id"
    fileprivate var kStudentRollNo =  "roll_no"
    fileprivate var kStudentAcademiYearID =  "academic_year_id"
    fileprivate var kStudentGRNO =  "gr_no"
    fileprivate var kStudentID =  "student_id"
    fileprivate var kStudentSurName =  "surname"
    fileprivate var kStudentName =  "student_name"
    fileprivate var kStudentFatherName =  "father_name"
    fileprivate var kStudentClassName = "class_name"
    fileprivate var kStudentDiVisonName = "divison_name"
    fileprivate var kStudentISNew = "is_new"
    fileprivate var kStudentDateOfAddmission = "date_of_admission"
    fileprivate var kStudentClassID =  "class_id"
    fileprivate var kStudentDivisionID = "divison_id"
    fileprivate var kStudentIsAbsent = "is_absent"
    
    var relID: String = ""
    var rollNo: String = ""
    var accedemicYearID: String = ""
    var grNo: String = ""
    var studentID: String = ""
    var surName: String = ""
    var studentName:String = ""
    var fatherName: String = ""
    var className:String = ""
    var divisionName:String = ""
    var isNew:String = ""
    var dateOfAddmission:String = ""
    var classID:String = ""
    var devisionID:String = ""
    var fullName:String = ""
    var isAbsent:Bool = false
    
    init(studentDetail:[String:Any]){
        super.init()
        if let id = studentDetail[kStudentRelID]{
            self.relID = "\(id)"
        }
        if let roll_no = studentDetail[kStudentRollNo]{
            self.rollNo = "\(roll_no)"
        }
        if let academic_year_id = studentDetail[kStudentAcademiYearID]{
            self.accedemicYearID = "\(academic_year_id)"
        }
        if let gr_no = studentDetail["gr_no"]{
            self.grNo = "\(gr_no)"
        }
        if let student_id = studentDetail["student_id"]{
            self.studentID = "\(student_id)"
        }
        if let sur_name = studentDetail["surname"]{
            self.surName = "\(sur_name)"
        }
        if let student_name = studentDetail["student_name"]{
            self.studentName = "\(student_name)"
        }
        if let father_name = studentDetail["father_name"]{
            self.fatherName = "\(father_name)"
        }
        if let class_name = studentDetail["class_name"]{
            self.className = "\(class_name)"
        }
        if let divison_name = studentDetail["divison_name"]{
            self.divisionName = "\(divison_name)"
        }
        if let is_new = studentDetail["is_new"]{
            self.isNew = "\(is_new)"
        }
        if let date_of_admission = studentDetail["date_of_admission"]{
            self.dateOfAddmission = "\(date_of_admission)"
        }
        if let class_id = studentDetail["class_id"]{
            self.classID = "\(class_id)"
        }
        if let divison_id = studentDetail["divison_id"]{
            self.devisionID = "\(divison_id)"
        }
        if let objIsAbsent = studentDetail[kStudentIsAbsent] as? Bool{
            self.isAbsent = objIsAbsent
        }
        self.fullName = "\(self.studentName) \(self.fatherName) \(self.surName)"
        
    }
}
