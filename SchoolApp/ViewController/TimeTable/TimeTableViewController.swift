//
//  TimeTableViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import QuickLook

class TimeTableViewController: UIViewController {
    //navigation view
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewProfile:UITableView!
    @IBOutlet var tableViewHeight:NSLayoutConstraint!
    @IBOutlet var buttonDropDown:UIButton!
    
    
    var heightOfUserProfileTableViewCell:CGFloat{
        get{
            return 50.0
        }
    }
    
    var arrayOfUserDetail:[NSManagedObject] = []
    
    @IBOutlet var buttonPreview:UIButton!
    @IBOutlet var buttonCalendar:UIButton!
    
    var objTimeTable:Syllabus?
    var previewItem:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getTimetableListAPIRequest(userID: user.userId)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.timetable")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.buttonPreview.setTitle("VIEW", for: .normal)
        self.buttonPreview.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonPreview.setTitleColor(UIColor.white, for: .normal)
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        
    }
    func configureCurrentUserDetail(userID:String){
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: userID) { (response) in
            if let objUserCoreData:Users =  response as? Users{
                if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
                    self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                }else{
                    self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal)
                }
            }
        }
    }
    func configureSavedUserProfileData(){
        APIRequestClient.shared.fetchAllUserDetailFromDataBase{ (response) in
            self.arrayOfUserDetail = response
            self.tableViewProfile.reloadData()
            self.buttonUserProfile.isEnabled = self.arrayOfUserDetail.count > 0
            self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
        }
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    // MARK: - API Request Methods
    func getTimetableListAPIRequest(userID:String){
        let notificationParameters = ["user_id":"\(userID)","page":"0"]
        
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kStudentTimeTable, parameter:notificationParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayNotice = success["data"] as? [[String:Any]]{//,let arrayNotice = jsonData["notice"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    for objSyllabus:[String:Any] in arrayNotice{
                        self.objTimeTable = Syllabus.init(syllabusDetail: objSyllabus)
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                guard !"\(errorMessage)".contains("No more notice available.") else {
                    return
                }
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        })
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonDrawerSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
//        SideMenu.show()
    }
    @IBAction func buttonProfileNavigationSelector(sender:UIButton){
        if self.arrayOfUserDetail.count > 0{
            UIView.animate(withDuration: 0.3) {
                if self.tableViewHeight.constant == 0{
                    self.tableViewHeight.constant = CGFloat(self.arrayOfUserDetail.count) * self.heightOfUserProfileTableViewCell
                }else{
                    self.tableViewHeight.constant = 0
                }
            }
        }
    }
    @IBAction func buttonCalendarSelector(sender:UIButton){
        self.presentPDFInQuickLook()
    }
    func presentPDFInQuickLook(){
        
        var strURL = ""
        if let _ = self.objTimeTable{
            strURL = self.objTimeTable!.attachment
        }
        guard strURL.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "No time table available.")
            }
            return
        }
        APIRequestClient.shared.saveFileFromURL(urlString: "\(strURL)") { (path) in
            DispatchQueue.main.async {
                self.previewItem = NSURL.init(string: "\(path)")
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.delegate = self
                previewController.currentPreviewItemIndex = 0
                self.present(previewController, animated: true, completion: {
                    UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
                })
                
            }
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension TimeTableViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let _ = previewItem{
            return self.previewItem!
        }else{
            return URL.init(fileURLWithPath:"") as QLPreviewItem
        }
        
    }
    
}
extension TimeTableViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfUserDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let profileCell:UserProfileTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileTableViewCell", for: indexPath) as! UserProfileTableViewCell
        if self.arrayOfUserDetail.count > indexPath.row{
            let objUser = self.arrayOfUserDetail[indexPath.row]
            if let username = objUser.value(forKey: "username"){
                profileCell.lblUserName.text = "\(username)"
            }
            
            if let user = User.getUserFromUserDefault(){
                if let userId = objUser.value(forKey: "userId"){
                    profileCell.selectImageView.isHidden = !(user.userId == "\(userId)")
                }
            }
        }
        profileCell.backgroundColor = kSchoolDarkThemeColor
        profileCell.selectionStyle = .none
        return profileCell//UITableViewCell()
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfUserProfileTableViewCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.arrayOfUserDetail.count > indexPath.row{
            let objUser = self.arrayOfUserDetail[indexPath.row]
            if let user = User.getUserFromUserDefault(){
                if let userId = objUser.value(forKey: "userId"){
                    if user.userId != "\(userId)"{
                        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: "\(userId)", userData: { (result) in
                            DispatchQueue.main.async {
                                self.configureCurrentUserDetail(userID: "\(userId)")
                            }
                        })
                        DispatchQueue.main.async {
                            if let nvc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                if let dashBoardView = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController{
                                    nvc.pushViewController(dashBoardView, animated: false)
                                }
                            }
                            self.buttonProfileNavigationSelector(sender: self.buttonUserProfile)
                            tableView.reloadData()
                        }
                    }else{
                        DispatchQueue.main.async {
                            self.buttonProfileNavigationSelector(sender: self.buttonUserProfile)
                            tableView.reloadData()
                        }
                    }
                }
            }
            
        }
    }
}
