//
//  APIRequestClient.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

let kAppStoreURLSurat = "https://apps.apple.com/us/app/shanti-asiatic-school-surat/id1460219343?ls=1"
let kAppStoreURLVastral = "https://apps.apple.com/us/app/shanti-asiatic-school-vastral/id1462049446?ls=1"
let kAppStoreURLKheda = "https://apps.apple.com/us/app/shanti-asiatic-school-kheda/id1462049324?ls=1"

let kLiveSurat = "http://sasconnectsurat.com/api/"
let kLiveVastral = "http://sasconnectvastral.com/api/"
let kLiveKheda = "http://sasconnectkheda.com/api/"



let kBaseURL =  kLiveSurat//"http://sas-surat.project-demo.info/api/"//"http://schoolerp.project-demo.info/api/"

let kWebKheda = "http://shantiasiatickheda.com/"
let kWebVastral = "http://shantiasiaticvastral.com/"
let kWebSurat = "http://shantiasiaticsurat.com/"



let kXAPIKey = "52d882c50bd9a45e04180467a7d04b51" 
let kLogInString = "auth/login"
let kFacebookLogIn = "auth/facebook"
let kForgotpassword = "auth/recover/password"
let kDashBoard = "users/getAppModules"
let kGetClass = "users/getClasses"
let kGetSchool = "users/getSchools"
let kRecoveryCode = "users/native/recovery"
let kGetNotification = "students/notice"
let kStudentAttendance = "students/attendance"
let kStudentHomework = "students/homework"

let kPhotoGalleryAlbum = "students/events"
let kPhotoGalleryAlbumGallery = "students/eventGallery"
let kStudentLeaves = "students/getLeaves"
let kGETHolidayHomework = "students/getHolidayHomework"
let kStudentLeaveType = "users/getLeaveType"
let kAddStudentLeave = "students/addLeave"
let kStudentSyllabus = "students/getSyllabus"
let kStudentAssignment = "students/getAssignment"
let kStudentTimeTable = "students/getTimetable"
let kStudentExamTimeTable = "students/getExamSchedule"
let kStudentRemark = "students/getRemarks"
let kStudentFees = "students/getFees"
let kStudentPTM = "students/getPTM"
let kCalendarMonthly = "students/getCalendar" //yearly 
let kTransportBusStop = "students/getTransport"
let kTransportDriver = "students/getDriverDetails"
let kStudentAchievement = "students/getAchievements"
let kStudentMealDetail = "students/getMeal"
let kUserLogout = "auth/logout"

let kResetPassword = "users/native/recovery/resetpassword"
let kSignUp = "users/register"
let kCountriesExperience = "base/native/countries/experience" //Get Counties which has experience
let kWhereToNextSearch = "base/native/whereto/freesearch"
let kCityLocations = "base/native/locations/" //Get All cities based on country id(append)
let kInstantExperience = "experience/native/locations/" //Append 1/instantexperiences 10 default pagesize and 0 default page index
let kBestRatedExperience = "experience/native/locations/" // Append 1/bestreview 10 default pagesize and 0 default page index
let kExploreCollection = "experience/native/collection"
let kTopRatedGuides = "guides/native/location/" // append locationid 1/toprated"
let kAllExperience = "experience/native/locations/"// append location1/allexperiences"
let kPendingBookingCount = "users/" //append userID 1/pendingbooking
let kUserExperience = "experience/native/users/" //append (userID)/('future','wishlist','past')?pagesize=10&pageindex=0
let kGuideTours = "experience/native/guides/"    //append (userID)/mytours?pagesize=10&pageindex=0"
let kDeleteExperience = "experience/"  //append ExperieceID 1/native/locations/2(locationID)
let kBecomGuideCountries = "base/native/country"
let kUploadImage = "amazons3/native/experience/image/upload/image"
let kUploadVideo = "amazons3/native/experience/video/upload/video"
let kAllLanguage = "base/native/languages"
let kAllCurrency = "base/native/stripeallowcurrency"
let kAllLocation = "base/native/locations"
let kGetExperience = "experience/native/users/" //Get Experience NameP
let kGetPendingOtherChat = "experience/native/users/" // GetPending Other ChatP
let kGetUserType = "users/native/usertype" //Get UserTypeP
let kAddNewExperience = "experience/native/save" //Add New Experience
let kIsValidExperienceTime = "experience/native/booking/" //Get uppeend 22/bookingtime
let kExperienceBookingCancelWithOutRefund = "experience/native/bookings/cancel"
let kExperienceBookingCancelWithRefund = "experience/native/bookingcancel"
let kExperiencePendingSchedule = "experience/native/guide/"
let kGuideRequest = "travellers/native/guiderequest"
let kGuideUploadImage = "amazons3/native/guide/image/upload/image"
let kGuideBadgeUploadImage = "amazons3/native/guide/badgeimage/upload/image"
let kBecomeGuide = "travellers/native/becomeguide"
let kInquiry = "users/native/inquiry"
let kGetLatestBooking = "experience/native/latestBooking"
let kExperienceBookingWithOutPayment = "users/native/bookingwithoutpayment"
let kTravelerPendingBooking = "experience/native/users/"
let kGETOrganizationList = "experience/native/csrorganisations"
let kSaveOrganization = "experience/native/csrdetails"


let kAddNotice = "users/createNotice"
let kUpdateStudentLeaveStatus = "students/updateLeavestatus"
let kGetRemarkCategory = "users/getRemarkCategory"
let kGetRemarkNameByCategory = "users/getRemarkByCategory"
let kGetStudentByClass = "students/getStudentByClass"
let kCreateRemark = "users/createRemark"
let kGETSection = "students/getSection"
let kGETAdminAttendance = "users/getAttendance"

let kAddHomeWork = "users/createHomework"

let kCheckAppVersion = "auth/check_version"
let kAddEventAlbum = "users/createEventAlbum"
let kUploadAlbumSingleImage = "users/createAlbum"

let kDeleteSingleImage = "users/deleteImg"

class APIRequestClient: NSObject {
    
    enum RequestType {
        case POST
        case GET
        case PUT
        case DELETE
        case PATCH
        case OPTIONS
    }
    
    static let shared:APIRequestClient = APIRequestClient()
    func cancelAllAPIRequest(json:Any?){
        
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
        if let url  = URL.init(string:kBaseURL){
            let task:URLSessionDataTask = URLSession.shared.dataTask(with:url)
            task.cancel()
        }
        if let _ = json{
            if let arrayFail = json as? NSArray , let fail = arrayFail.firstObject as? [String:Any],let errorMessage = fail["ErrorMessage"]{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                    ShowToast.show(toatMessage:"invalid access token")
                }
            }
        }
        if let _ = json{
            DispatchQueue.main.async {
                if let appDel = UIApplication.shared.delegate as? AppDelegate ,let navigation = appDel.window?.rootViewController as? UINavigationController{
                    kUserDefault.removeObject(forKey: "isLocationPushToHome")
                    User.removeUserFromUserDefault()
                    kUserDefault.removeObject(forKey: kExperienceDetail)
                    kUserDefault.synchronize()
                    navigation.popToRootViewController(animated: false)
                }
            }
        }
    }
    //Post LogIn API
    func sendLogInRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(kXAPIKey, forHTTPHeaderField:"X-API-KEY")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                request.setValue("\(user.userrole_id)", forHTTPHeaderField: "roll_id")
            }
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                //fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                    do{
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                        (httpStatus.statusCode == 200) ? success(json):fail(json)
                    }
                    catch{
                        //ShowToast.show(toatMessage: kCommonError)
                        //fail(["error":kCommonError])
                    }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    
    // GET ExperienceP
    func getExperience(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
//        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
//            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
//        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Post Facebook LogIn
    func sendFacebookLogInAPI(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Patch Forgotpassword
    func forgotPasswordRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Post SignUp Request
    func sendSignUpRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)

                
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //GET Countries with atleast one experiences
    func getCoutriesWithExperience(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                 ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                 fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    //ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                //ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //GET Cities on countryid
    func getCitiesOnCountyID(requestType:RequestType,queryString:String?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        } else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Send Request
    func sendRequest(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
//        DispatchQueue.main.async {
//            ShowToast.show(toatMessage: "\(urlString)")
//        }
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        request.setValue(kXAPIKey, forHTTPHeaderField:"X-API-KEY")
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                request.setValue("\(user.userrole_id)", forHTTPHeaderField: "roll_id")
            }
        }
//        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
//            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
//        } else {
//            request.setValue("1", forHTTPHeaderField: "LanguageId")
//        }
//        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
//            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
//            //request.setValue("Bearer 2a34e935-c3a6-4ed3-8c83-0c86ae5b38a9", forHTTPHeaderField: "Authorization")
//        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                   ShowToast.show(toatMessage: error.localizedDescription)
                    
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Add New Experience
    func addNewExperience(requestType:RequestType,queryString:String?,parameter:[String:AnyObject]?,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        var request = URLRequest(url: URL(string: urlString.removeWhiteSpaces())!)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.httpMethod = String(describing: requestType)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            request.setValue("\(languageId)", forHTTPHeaderField: "LanguageId")
        }else {
            request.setValue("1", forHTTPHeaderField: "LanguageId")
        }
//        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
//            request.setValue("Bearer \(currentUser.userAccessToken)", forHTTPHeaderField: "Authorization")
//        }
        if let params = parameter{
            do{
                let parameterData = try JSONSerialization.data(withJSONObject:params, options:.prettyPrinted)
                request.httpBody = parameterData
            }catch{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                ProgressHud.hide()
            }
            if error != nil{
                ShowToast.show(toatMessage: "\(error!.localizedDescription)")
                fail(["error":"\(error!.localizedDescription)"])
            }
            if let _ = data,let httpStatus = response as? HTTPURLResponse{
                do{
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    (httpStatus.statusCode == 200) ? success(json): (httpStatus.statusCode == 401) ? self.cancelAllAPIRequest(json: json):fail(json)

                }
                catch{
                    ShowToast.show(toatMessage: kCommonError)
                    fail(["error":kCommonError])
                }
            }else{
                ShowToast.show(toatMessage: kCommonError)
                fail(["error":kCommonError])
            }
        }
        task.resume()
    }
    //Upload Images
    func uploadImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:Data?,isPDF:Bool = false,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
           // fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
     
        
         //let URL = "http://staging.live.stockholmapplab.com/api/amazons3/native/experience/image/upload/image"
        var rollId:String = ""
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                rollId = "\(user.userrole_id)"
            }
        }
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data","X-API-KEY":kXAPIKey,"roll_id":"\(rollId)"]
        
         Alamofire.upload(multipartFormData: { (multipartFormData) in
            
         for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
         }
         
          if let data = imageData{
            if isPDF{
                multipartFormData.append(imageData!, withName: "file", fileName: "file.pdf", mimeType: "application/pdf")
            }else{
                multipartFormData.append(imageData!, withName: "file", fileName: "image.png", mimeType: "image/png")
            }
            
         }
         
         }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
           
         switch result{
         case .success(let upload, _, _):
         upload.responseJSON { response in
            
         if let objResponse = response.response,objResponse.statusCode == 200{
            if let successResponse = response.value as? [String:Any]{
                success(successResponse)
            }
         }else if let objResponse = response.response,objResponse.statusCode == 401{
            self.cancelAllAPIRequest(json: response.value)
         }else if let objResponse = response.response,objResponse.statusCode == 400{
            if let failResponse = response.value as? [String:Any]{
                fail(failResponse)
            }
         }else if let error = response.error{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(error.localizedDescription)")
                fail(["error":"\(error.localizedDescription)"])
            }
         }else{
            DispatchQueue.main.async {
                if let failResponse = response.value as? [String:Any]{
                    fail(failResponse)
                }
            }
           }
         }
         case .failure(let error):
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "\(error.localizedDescription)")
                fail(["error":"\(error.localizedDescription)"])
            }
         }
         }
    }
    //Upload Multiple Images
    func uploadMultipleImage(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],imageData:[Data]?,isPDF:Bool = false,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            // fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        
        //let URL = "http://staging.live.stockholmapplab.com/api/amazons3/native/experience/image/upload/image"
        var rollId:String = ""
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id.count > 0{
                rollId = "\(user.userrole_id)"
            }
        }
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data","X-API-KEY":kXAPIKey,"roll_id":"\(rollId)"]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            if let dataArray = imageData{
                for objImagedata in dataArray{
                    multipartFormData.append(objImagedata, withName: "file[]", fileName: "image.png", mimeType: "image/png")
                }
            }
            
        }, usingThreshold: UInt64.init(), to: urlString, method:HTTPMethod(rawValue:"\(requestType)")!, headers: headers) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    
                    if let objResponse = response.response,objResponse.statusCode == 200{
                        if let successResponse = response.value as? [String:Any]{
                            success(successResponse)
                        }
                    }else if let objResponse = response.response,objResponse.statusCode == 401{
                        self.cancelAllAPIRequest(json: response.value)
                    }else if let objResponse = response.response,objResponse.statusCode == 400{
                        if let failResponse = response.value as? [String:Any]{
                            fail(failResponse)
                        }
                    }else if let error = response.error{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(error.localizedDescription)")
                            fail(["error":"\(error.localizedDescription)"])
                        }
                    }else{
                        DispatchQueue.main.async {
                            if let failResponse = response.value as? [String:Any]{
                                fail(failResponse)
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(error.localizedDescription)")
                    fail(["error":"\(error.localizedDescription)"])
                }
            }
        }
    }
    //Upload Video
    func uploadVideo(requestType:RequestType,queryString:String?,parameter:[String:AnyObject],videoData:Data,isHudeShow:Bool,success:@escaping SUCCESS,fail:@escaping FAIL){
        guard CommonClass.shared.isConnectedToInternet else{
            ShowToast.show(toatMessage: kNoInternetError)
            //fail(["Error":kNoInternetError])
            return
        }
        if isHudeShow{
            DispatchQueue.main.async {
                ProgressHud.show()
            }
        }
        let urlString = kBaseURL + (queryString == nil ? "" : queryString!)
        
        
        //let URL = "http://staging.live.stockholmapplab.com/api/amazons3/native/experience/image/upload/image"
        var headers: HTTPHeaders = ["Content-type": "multipart/form-data"]
        var strAccessToken:String = ""
//        if User.isUserLoggedIn,let currentUser = User.getUserFromUserDefault(){
//            strAccessToken = "Bearer \(currentUser.userAccessToken)"
//        }
        if let languageId = kUserDefault.value(forKey: "selectedLanguageCode") as? String {
            headers = ["Content-type": "multipart/form-data","LanguageId": "\(languageId)","Authorization":"\(strAccessToken)"]
        }else{
            headers = ["Content-type": "multipart/form-data","LanguageId": "1","Authorization":"\(strAccessToken)"]
        }
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            for (key, value) in parameter {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            
            // if let data = imageData{
            multipartFormData.append(videoData, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            //}
            
        }, usingThreshold: UInt64.init(), to: urlString, method: .post, headers: headers) { (result) in
            
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let objResponse = response.response,objResponse.statusCode == 200{
                        if let successResponse = response.value as? [String:Any]{
                            success(successResponse)
                        }
                    }else if let objResponse = response.response,objResponse.statusCode == 401{
                        self.cancelAllAPIRequest(json: response.value)
                    }else if let error = response.error{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(error.localizedDescription)")
                            fail(["error":"\(error.localizedDescription)"])
                        }
                    }else{
                        DispatchQueue.main.async {
                            ShowToast.show(toatMessage: "\(kCommonError)")
                            fail(["error":"\(kCommonError)"])
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    
                    ShowToast.show(toatMessage: "\(error.localizedDescription)")
                    fail(["error":"\(error.localizedDescription)"])
                }
            }
        }
    }
    
    //FetchUser from database
    
    func fetchUserDetailFromDataBase(userId:String,userData:((_ response:NSManagedObject)->())){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            request.returnsObjectsAsFaults = false
            request.predicate = NSPredicate(format: "userId = %@", "\(userId)")
            do {
                if let result = try context.fetch(request) as? [Users]{
                    if result.count > 0{
                        let objUserCoredata:Users = result.first!
                        var objUserDetail:[String:Any] = [:]
                        for key in objUserCoredata.entity.propertiesByName.keys{
                            if let value = objUserCoredata.value(forKey: key){
                                objUserDetail["\(key)"] = "\(value)"
                            }
                        }
                        let objUserModel = User.init(userDetail: objUserDetail)
                        objUserModel.setuserDetailToUserDefault()
                        
                        userData(result.first!)
                    }
                }
            } catch {
               
            }
        }
    }
    func fetchAllUserDetailFromDataBase(userData:((_ response:[NSManagedObject])->())){

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            request.predicate = NSPredicate(format: "userrole_id = %@", "\(2)")
            request.returnsObjectsAsFaults = false
            do {
                if let result = try context.fetch(request) as? [NSManagedObject]{
                    
                    userData(result)
                }else{
                    userData([])
                }
            } catch {
                userData([])
            }
        }else{
                userData([])
        }
    }
    func removeUserIfAlreadyExist(userID:String,completionHandlar:()->()){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
            request.predicate = NSPredicate(format: "userId = %@", "\(userID)")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                }
                completionHandlar()
            } catch {
                completionHandlar()
            }
        }
    }
    func
        addUserToDB(userData:[String:Any]){
        if let userID = userData["user_id"]{
            self.removeUserIfAlreadyExist(userID: "\(userID)") {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                    let context = appDelegate.persistentContainer.viewContext
                    if let objEntityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: "Users", in: context){
                        let userCoreData:Users = Users.init(entity: objEntityDescription, insertInto: context)
                        if let userID = userData["user_id"]{
                            userCoreData.userId = "\(userID)"
                        }
                        if let studentID = userData["student_id"]{
                            userCoreData.student_id = "\(studentID)"
                        }
                        if let gr_no = userData["gr_no"]{
                            userCoreData.gr_no = "\(gr_no)"
                        }
                        if let roll_no = userData["roll_no"]{
                            userCoreData.roll_no = "\(roll_no)"
                        }
                        if let surname = userData["surname"]{
                            userCoreData.surname = "\(surname)"
                        }
                        if let student_name = userData["student_name"]{
                            userCoreData.student_name = "\(student_name)"
                        }
                        if let father_name = userData["father_name"]{
                            userCoreData.father_name = "\(father_name)"
                        }
                        if let gender = userData["gender"]{
                            userCoreData.gender = "\(gender)"
                        }
                        if let birth_date = userData["birth_date"]{
                            userCoreData.birth_date = "\(birth_date)"
                        }
                        if let phone_number1 = userData["phone_number1"]{
                            userCoreData.phone_number1 = "\(phone_number1)"
                        }
                        if let phone_number2 = userData["phone_number2"]{
                            userCoreData.phone_number2 = "\(phone_number2)"
                        }
                        if let email1 = userData["email1"]{
                            userCoreData.email1 = "\(email1)"
                        }
                        if let email2 = userData["email2"]{
                            userCoreData.email2 = "\(email2)"
                        }
                        if let student_photo = userData["student_photo"]{
                            userCoreData.student_photo = "\(student_photo)"
                        }
                        if let student_photo = userData["student_photo"]{
                            userCoreData.student_photo = "\(student_photo)"
                        }
                        if let current_address = userData["current_address"]{
                            userCoreData.current_address = "\(current_address)"
                        }
                        if let class_id = userData["class_id"]{
                            userCoreData.class_id = "\(class_id)"
                        }
                        if let class_name = userData["class_name"]{
                            userCoreData.class_name = "\(class_name)"
                        }
                        if let divison_name = userData["divison_name"]{
                            userCoreData.divison_name = "\(divison_name)"
                        }
                        if let teacher = userData["teacher"]{
                            userCoreData.teacher = "\(teacher)"
                        }
                        if let surname = userData["surname"],let student_name = userData["student_name"]{
                            userCoreData.username = "\(student_name) \(surname)"
                        }
                        if let lat = userData["school_lat"]{
                            userCoreData.school_lat = "\(lat)"
                        }
                        if let long = userData["school_lon"]{
                            userCoreData.school_long = "\(long)"
                        }
                        if let userRoleType = userData["user_type"]{
                            userCoreData.userrole = "\(userRoleType)"
                        }
                        if let userRoleID = userData["role_id"]{
                            userCoreData.userrole_id = "\(userRoleID)"
                        }
                        appDelegate.saveContext()
                    }
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
                    request.predicate = NSPredicate(format: "userId = %@", "\(userID)")
                    request.returnsObjectsAsFaults = false
                    do {
                        let result = try context.fetch(request)
                        
                        for data in result as! [NSManagedObject] {
                            let userName = data.value(forKey: "userId") as! String
                            print("\(userName)")
                        }
                    } catch {
                        print("Failed")
                    }
                }
            }
        }
    }
    
    func saveFileFromURL(urlString:String,localPath:@escaping ((_ response:String)->())) {
        DispatchQueue.main.async {

            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "\(urlString.fileName()).\(urlString.fileExtension())"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            /*
            guard !self.pdfFileAlreadySaved(urlString: urlString) else{
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                localPath(actualPath.absoluteString)
                return
            }*/
            if let objURL = URL.init(string: urlString){
                do {
                    guard CommonClass.shared.isConnectedToInternet else{
                        ShowToast.show(toatMessage: kNoInternetError)
                        return
                    }
                    DispatchQueue.main.async {
                        ProgressHud.show()
                    }
                    URLSession.shared.dataTask(with: objURL) { data, response, error in
                        DispatchQueue.main.async {
                            ProgressHud.hide()
                        }
                        guard
                            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                            let pdfData = data, error == nil else {
                                DispatchQueue.main.async {
                                    ShowToast.show(toatMessage: "\(error?.localizedDescription ?? "Server error invalid URL")")
                                }
                            return
                        }
                        try? pdfData.write(to: actualPath, options: .atomic)
                        localPath(actualPath.absoluteString)
                    }.resume()
//                    let pdfData:Data =  try Data.init(contentsOf: objURL)
                    
                }catch{
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                    }
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func showSavedPdf(url:String, fileName:String,extention:String){
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(fileName).\(extention)") {
                        // its your file! do what you want with it!
                        
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
    }
    
    // check to avoid saving a file multiple times
    func pdfFileAlreadySaved(urlString:String)-> Bool {
        var status = false
        if #available(iOS 10.0, *) {
            do {
                let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
                for url in contents {
                    if url.description.contains("\(urlString.fileName()).\(urlString.fileExtension())") {
                        status = true
                    }
                }
            } catch {
                print("could not locate pdf file !!!!!!!")
            }
        }
        return status
    }
}
