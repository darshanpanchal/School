//
//  Constant.swift
//  Live
//
//  Created by ITPATH on 4/5/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//
import UIKit
import Foundation
let kDarkOrange:UIColor = UIColor.init(red: 158.0/255.0, green: 63.0/255.0, blue: 15.0/255.0, alpha: 1.0)
let kDarkBlue:UIColor = UIColor.init(red: 9.0/255.0, green: 79.0/255.0, blue: 129.0/255.0, alpha: 1.0)
let kThemeOrangeColor:UIColor = UIColor.init(red: 234.0/255.0, green: 121.0/255.0, blue: 41.0/255.0, alpha: 1.0)
let kSchoolThemeColor:UIColor = UIColor.init(hexString: "38A3D9")//UIColor.init(red: 0/255.0, green:107.0/255.0, blue: 180.0/255.0, alpha: 1.0)
let kSchoolDarkThemeColor:UIColor = UIColor.init(hexString: "0B80C3") //0B80C3

let kAppDel = UIApplication.shared.delegate as! AppDelegate
let kUserDefault = UserDefaults.standard
let kAppName = "SchoolApp"
let kBookingStoryBoard = UIStoryboard(name:"BooknowDetailSB", bundle: nil)
typealias SUCCESS = (_ response:Any)->()
typealias FAIL = (_ response:Any)->()
let kCommonError = Vocabulary.getWordFromKey(key:"commonError")
let kNoInternetError = Vocabulary.getWordFromKey(key:"NoInternet")
let kUserDetail = "UserDetail"
let kUserName = "UserName"
let kUserPassword = "Password"
let MAP_API_KEY = "AIzaSyAyFEVEJUFaAdDAcxDGf88zo4DwYFzM5bo"//"AIzaSyC5N0EGpVw0zFQyrTF1alLsSzP07Kygy4E"//"AIzaSyAxF1kCqFsYN69ylm65zz-NNHzT9gawbWk"//"AIzaSyBf00qqnOcvrXHbnyoVnVj9lSbpoRMafMg"  // API_Key for GMS Map
let kPendingExperience = "PendingExperience"
let kUserRoleForSettingMenu = "UserRoleForSettingMenu"
let kShowCaseForLocationButton = "ShowCaseForLocationButton"
let kPushNotificationToken = "PushNotificationToken"
let kIsAppShareViaMSG = "AppSharingViaMSG"
let kExperienceDetail = "ExperienceDetail"

