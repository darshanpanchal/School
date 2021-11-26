//
//  NoticeViewController.swift
//  SchoolApp
//
//  Created by user on 19/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class NoticeViewController: UIViewController {
    //Navigation
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
    
    //Notice
    @IBOutlet var tableViewNotice:UITableView!
    @IBOutlet var objSegmentController:UISegmentedControl!
    
    @IBOutlet var buttonAddNotice:UIButton!
    @IBOutlet var buttonFilter:UIButton!
    
    var refreshControl = UIRefreshControl()
    
    var isPullToRefresh:Bool = false
    
    var filterParameters:[String:Any] = [:]
    var isCircular:Bool = false
    var isCircularSelected:Bool{
        get{
            return isCircular
        }
        set{
            isCircular = newValue
            //Configure Circular
            self.configureCircularAllView()
        }
    }
    var isLoadMoreNotice:Bool = false
    var currentPage:Int = 0
    var currentView:String = "All" //Circular
    var arrayOfNotice:[Notice] = []
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureNoticeTableView()
     
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
        }
        self.isCircularSelected = false
    }
    
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.Notice")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.objSegmentController.tintColor = kSchoolThemeColor
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key:"genral.NoticeAll"), forSegmentAt: 0)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key:"genral.NoticeCircular"), forSegmentAt: 1)
        let font = UIFont.systemFont(ofSize: 18)
        self.objSegmentController.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                for: .normal)
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        
        self.buttonAddNotice.tintColor = kSchoolThemeColor
        self.buttonAddNotice.backgroundColor = kSchoolThemeColor
        
        self.configureCurrentUserRole()
        
    }
    func configureCurrentUserRole(){
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userType == .student{
                self.buttonAddNotice.isHidden = true
            }else{
                self.buttonAddNotice.isHidden = false
            }
        }else{
            self.buttonAddNotice.isHidden = false
        }
    }
    func configureSavedUserProfileData(){
        APIRequestClient.shared.fetchAllUserDetailFromDataBase{ (response) in
            self.arrayOfUserDetail = response
            self.tableViewProfile.reloadData()
            if let user = User.getUserFromUserDefault(){
                self.buttonUserProfile.isHidden = !(self.arrayOfUserDetail.count > 0 && user.userType == .student) // 2 for student and 1 for admin
                if user.userType == .student{
                  self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
                }else{
                  self.buttonDropDown.isHidden = true //hide for admin
                }
                self.buttonFilter.isHidden = !(self.buttonUserProfile.isHidden)
            }
            
        }
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    func configureNoticeTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewNotice.rowHeight = UITableView.automaticDimension
        self.tableViewNotice.estimatedRowHeight = 100.0
        self.tableViewNotice.delegate = self
        self.tableViewNotice.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewNotice.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewNotice.separatorStyle = .none
        self.tableViewNotice.isScrollEnabled = true
        if let user = User.getUserFromUserDefault(),user.userType == .student{ //hide footer for students
            self.tableViewNotice.tableFooterView = UIView()
        }
        self.tableViewNotice.tableHeaderView = UIView()
        self.tableViewNotice.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewNotice.addSubview(refreshControl) // not required when using UITableViewController
        
        
    }
    @objc func refreshTableView() {
        DispatchQueue.main.async {
            self.filterParameters = [:]
            self.isPullToRefresh = true
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                // Code to refresh table view
                DispatchQueue.global(qos: .background).async {
                    self.currentPage = 0
                    if let user = User.getUserFromUserDefault(){
                        self.getNotificationListAPIRequest(userID: user.userId)
                    }
                }
            })
       }
    }
    func configureCurrentUserDetail(userID:String){
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: userID) { (response) in
            if let objUserCoreData:Users =  response as? Users{
                if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
//                     self.buttonUserProfile.sd_setImage(with: objURl, for: .normal, placeholderImage:UIImage.init(named: "ic_profile_circle"), options: .refreshCached, completed: nil)
                    self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                }else{
                    self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal)
                }
            }
        }
    }
    func configureCircularAllView(){
        DispatchQueue.main.async {
            self.currentPage = 0
            self.arrayOfNotice.removeAll()
            self.tableViewNotice.reloadData()
            if self.isCircularSelected{
                self.currentView = "Circular"
            }else{
                self.currentView = "All"
            }
            if let user = User.getUserFromUserDefault(){
                self.getNotificationListAPIRequest(userID: user.userId)
            }
        }
        
    }
    // MARK: - API Request Methods
    func getNotificationListAPIRequest(userID:String){
           var notificationParameters = ["user_id":"\(userID)","page":"\(self.currentPage)","view":"\(self.currentView)"]
            let _ = self.filterParameters.map{
                notificationParameters[$0.0] = "\($0.1)"
            }
            APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kGetNotification, parameter:notificationParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let arrayNotice = success["data"] as? [[String:Any]]{//,let arrayNotice = jsonData["notice"] as? [[String:Any]]{
                    DispatchQueue.main.async {
                        if self.currentPage == 0{
                            self.arrayOfNotice.removeAll()
                        }
                        self.isLoadMoreNotice = arrayNotice.count > 0
                        for objNotice:[String:Any] in arrayNotice{
                            let notice = Notice.init(noticeDetail: objNotice)
                            self.arrayOfNotice.append(notice)
                        }
                        self.tableViewNotice.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }, fail: { (responseFail) in
                self.isLoadMoreNotice = false
                DispatchQueue.main.async {
                   // self.currentPage = 0
                    //self.arrayOfNotice.removeAll()
                    self.tableViewNotice.reloadData()
                }
                if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                    if "\(errorMessage)".range(of:"notice",options: .caseInsensitive) != nil{
                        return
                    }
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
    @IBAction func buttonSegmentSelected(sender:UISegmentedControl){
        self.isCircularSelected = !self.isCircularSelected
    }
    @IBAction func buttonAddNoticeSelector(sender:UIButton){
        //self.pushToAddLeaveController()
        self.pushToAddNoticeViewController()
    }
    @IBAction func buttonFilterSelector(sender:UIButton){
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountViewController") as? AddAccountViewController{
            if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
            {    dvc.modalPresentationStyle = .overFullScreen
                dvc.isForClassSectionFilter = true
                dvc.delegate = self
                dvc.filterParameters = self.filterParameters
                rootVC.present(dvc, animated: false, completion: nil)
            }
        }
    }
    // MARK: - Navigation
    func pushToNotificationDetailView(objNotice:Notice){
        if let notificationDetailView = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            notificationDetailView.objNoticeDetail = objNotice
            self.navigationController?.pushViewController(notificationDetailView, animated: true)
        }
    }
    func pushToAddNoticeViewController(){
        if let addNotice = self.storyboard?.instantiateViewController(withIdentifier: "AddNoticeViewController") as? AddNoticeViewController{
            self.navigationController?.pushViewController(addNotice, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension NoticeViewController:FilterDelegate{
    func didConfirmfilterParameters(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.currentPage = 0
        self.arrayOfNotice.removeAll()
        //self.refreshTableView()
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getNotificationListAPIRequest(userID: user.userId)
            }
        }
        
    }
}
extension NoticeViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewNotice{
            if self.arrayOfNotice.count == 0{
                tableView.showMessageLabel(msg: "No notice available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfNotice.count
        }else{
            return self.arrayOfUserDetail.count
        }
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewNotice{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let objNotice:Notice = self.arrayOfNotice[indexPath.row]
            if let objCurrentUser = User.getUserFromUserDefault(){
                if objCurrentUser.userType == .student{
                    homeworkCell.lblHomeWorkDetail.text = "\(objNotice.noticeContent)\n"
                }else{ //add class name and section name and student name for admin role
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    //updated class name
                    let classUpdatedValue = NSAttributedString.init(string: "\(objNotice.className)", attributes: self.attributesNormal)
                    /*let classValue = NSMutableAttributedString.init(string: "\(objNotice.className) - \(objNotice.sectionName)\n", attributes: self.attributesNormal)
                    classString.append(classValue)*/
                    classString.append(classUpdatedValue)
                    let notificationContent = NSAttributedString.init(string:"\n\(objNotice.noticeContent)\n", attributes: self.attributesNormal)
                    classString.append(notificationContent)
                    homeworkCell.lblHomeWorkDetail.attributedText = classString
                }
            }
            
            
            homeworkCell.lblHomeWorkDate.text = objNotice.noticeDate.changeDateFormateddMMYYYY
            homeworkCell.shadowView.isHidden = false
            homeworkCell.separatorInset = UIEdgeInsets.zero
            homeworkCell.layoutMargins = UIEdgeInsets.zero
            homeworkCell.attachMentImageView.isHidden = !(objNotice.attachmentType.count > 0)
            if objNotice.attachmentType == "pdf"{
               homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
            }else{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
            }

            homeworkCell.lblHomeWorkDate.clipsToBounds = true
            homeworkCell.lblHomeWorkDate.layer.cornerRadius = 10.0
            if indexPath.row+1 == self.arrayOfNotice.count, self.isLoadMoreNotice{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getNotificationListAPIRequest(userID: user.userId)
                    }
                }
            }
            return homeworkCell
        }else{
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
            return profileCell
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewNotice{
            let objNotice:Notice = self.arrayOfNotice[indexPath.row]
            return (objNotice.noticeContent.count > 200) ? 200.0:UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewNotice{
            if self.arrayOfNotice.count > indexPath.row{
                self.pushToNotificationDetailView(objNotice: self.arrayOfNotice[indexPath.row])
            }
        }else{
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
}
class Notice: NSObject {
    var noticeID:String = ""
    var noticeContent:String = ""
    var noticeDate: String = ""
    var attachment: String = ""
    var attachmentType: String = ""
    var classID:String = ""
    var className:String = ""
    var sectionID:String = ""
    var sectionName:String = ""
    
    init(noticeDetail:[String:Any]){
        super.init()
        if let id = noticeDetail["notice_id"]{
            self.noticeID = "\(id)"
        }
        if let content = noticeDetail["notice_content"]{
            self.noticeContent = "\(content)"
        }
        if let date = noticeDetail["notice_date"]{
            self.noticeDate = "\(date)"
        }
        if let objAttachment = noticeDetail["attachment"]{
            self.attachment = "\(objAttachment)"
        }
        if let type = noticeDetail["attachment_type"]{
            self.attachmentType = "\(type)"
        }
        if let classid = noticeDetail["class_id"]{
            self.classID = "\(classid)"
        }
        if let classname = noticeDetail["class_name"]{
            self.className = "\(classname)"
        }
        if let sectionid = noticeDetail["divison_id"]{
            self.sectionID = "\(sectionid)"
        }
        if let sectionname = noticeDetail["divison_name"]{
            self.sectionName = "\(sectionname)"
        }
    }
}
