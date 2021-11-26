//
//  FeesViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class SyllabusViewController: UIViewController {
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
    var isLoadMoreSyllabus:Bool = false
    var currentPage:Int = 0
    @IBOutlet var tableViewSyllabus:UITableView!
    
    var refreshControl = UIRefreshControl()

    var arrayOfSyllabus:[Syllabus] = []
    var isForAssignment:Bool = false
    
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var isPullToRefresh = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureSyllabusTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getNotificationListAPIRequest(userID: user.userId)
        }
        
    }
    
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = self.isForAssignment ? Vocabulary.getWordFromKey(key: "genral.Assignment") : Vocabulary.getWordFromKey(key:"genral.syllabus")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
    func configureSyllabusTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewSyllabus.rowHeight = UITableView.automaticDimension
        self.tableViewSyllabus.estimatedRowHeight = 100.0
        self.tableViewSyllabus.delegate = self
        self.tableViewSyllabus.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewSyllabus.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewSyllabus.separatorStyle = .none
        self.tableViewSyllabus.isScrollEnabled = true
        self.tableViewSyllabus.tableFooterView = UIView()
        self.tableViewSyllabus.tableHeaderView = UIView()
        self.tableViewSyllabus.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewSyllabus.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.isPullToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getNotificationListAPIRequest(userID: user.userId)
            }
        }
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
    // MARK: - API Request Methods
    func getNotificationListAPIRequest(userID:String){
        let notificationParameters = ["user_id":"\(userID)","page":"\(self.currentPage)"]
        
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:self.isForAssignment ? kStudentAssignment : kStudentSyllabus, parameter:notificationParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayNotice = success["data"] as? [[String:Any]]{//,let arrayNotice = jsonData["notice"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    if self.currentPage == 0{
                        self.arrayOfSyllabus.removeAll()
                    }
                    self.isLoadMoreSyllabus = arrayNotice.count > 0
                    
                    for objSyllabus:[String:Any] in arrayNotice{
                        self.arrayOfSyllabus.append(Syllabus.init(syllabusDetail: objSyllabus))
                    }
                    DispatchQueue.main.async {
                        self.tableViewSyllabus.reloadData()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                if self.isForAssignment{
                    guard !"\(errorMessage)".contains("No assignment available.") else {
                        return
                    }
                }else{
                    guard !"\(errorMessage)".contains("No syllabus available.") else {
                        return
                    }
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
    // MARK: - Navigation
    func pushToSyllabusDetail(objSyllabus:Syllabus){
        if let homeworkDetailView:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            homeworkDetailView.isForSyllabus = true
            homeworkDetailView.objSyllabus = objSyllabus
            self.navigationController?.pushViewController(homeworkDetailView, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension SyllabusViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewSyllabus{
            if self.arrayOfSyllabus.count == 0{
                 if  self.isForAssignment{
                    tableView.showMessageLabel(msg: "No assignment available.", backgroundColor: .white, headerHeight: 0.0)
                 }else{//syllabus
                    tableView.showMessageLabel(msg: "No syllabus available.", backgroundColor: .white, headerHeight: 0.0)
                }
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfSyllabus.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewSyllabus{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let objSyllabus:Syllabus = self.arrayOfSyllabus[indexPath.row]
            
           
//            if let _ = objSyllabus.subject{
//                subject = "\(objSyllabus.subject!)"
//            }
            if  self.isForAssignment{
                let subject = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                let subjectValue = NSMutableAttributedString.init(string: "\(objSyllabus.subject)", attributes: self.attributesNormal)
                
                let desc = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                let descValue = NSMutableAttributedString.init(string: "\(objSyllabus.objDescription)\n", attributes: self.attributesNormal)
                
                subject.append(subjectValue)
                subject.append(desc)
                subject.append(descValue)
                
                homeworkCell.lblHomeWorkDetail.attributedText = subject
                //"Subject :- \(objSyllabus.subject) \nDesc :- \(objSyllabus.objDescription)"
            }else{
                let subject1 = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                let subject1Value = NSMutableAttributedString.init(string: "\(objSyllabus.subject)", attributes: self.attributesNormal)
                
                let type1 = NSMutableAttributedString.init(string: "\n\nType :- ", attributes: self.attributesBold)
                let typeValue1 = NSMutableAttributedString.init(string: "\(objSyllabus.syllabusType)", attributes: self.attributesNormal)
                
                let desc1 = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                let descValue1 = NSMutableAttributedString.init(string: "\(objSyllabus.objDescription)\n", attributes: self.attributesNormal)
                
                subject1.append(subject1Value)
                subject1.append(type1)
                subject1.append(typeValue1)
                subject1.append(desc1)
                subject1.append(descValue1)
                homeworkCell.lblHomeWorkDetail.attributedText = subject1
                
                //"Subject :- \(objSyllabus.subject) \nType :- \(objSyllabus.syllabusType) \n\(objSyllabus.objDescription)"

            }
            homeworkCell.lblHomeWorkDate.text = objSyllabus.modifie.changeDateFormat
            homeworkCell.lblHomeWorkDate.minimumScaleFactor = 0.5
            homeworkCell.shadowView.isHidden = false
            homeworkCell.separatorInset = UIEdgeInsets.zero
            homeworkCell.layoutMargins = UIEdgeInsets.zero
//            homeworkCell.lblHomeWorkDate.textColor = UIColor.white
//            homeworkCell.lblHomeWorkDate.backgroundColor = kSchoolThemeColor
            homeworkCell.attachMentImageView.isHidden = !(objSyllabus.attachment.count > 0)
            if objSyllabus.attachment.fileExtension() == "pdf"{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
            }else{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
            }
//            homeworkCell.lblHomeWorkDate.textAlignment = .center
            homeworkCell.lblHomeWorkDate.clipsToBounds = true
            homeworkCell.lblHomeWorkDate.layer.cornerRadius = 5.0
            if indexPath.row+1 == self.arrayOfSyllabus.count, self.isLoadMoreSyllabus{ //last index
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
            return profileCell//UITableViewCell()
        
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewSyllabus{
            let objSyllabus:Syllabus = self.arrayOfSyllabus[indexPath.row]

            var syllabusAttributed:NSMutableAttributedString = NSMutableAttributedString()
            if  self.isForAssignment{
                let subject = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                let subjectValue = NSMutableAttributedString.init(string: "\(objSyllabus.subject)", attributes: self.attributesNormal)
                
                let desc = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                let descValue = NSMutableAttributedString.init(string: "\(objSyllabus.objDescription)\n", attributes: self.attributesNormal)
                
                subject.append(subjectValue)
                subject.append(desc)
                subject.append(descValue)
                
               syllabusAttributed = subject
                //"Subject :- \(objSyllabus.subject) \nDesc :- \(objSyllabus.objDescription)"
            }else{
                let subject1 = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                let subject1Value = NSMutableAttributedString.init(string: "\(objSyllabus.subject)", attributes: self.attributesNormal)
                
                let type1 = NSMutableAttributedString.init(string: "\n\nType :- ", attributes: self.attributesBold)
                let typeValue1 = NSMutableAttributedString.init(string: "\(objSyllabus.syllabusType)", attributes: self.attributesNormal)
                
                let desc1 = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                let descValue1 = NSMutableAttributedString.init(string: "\(objSyllabus.objDescription)\n", attributes: self.attributesNormal)
                
                subject1.append(subject1Value)
                subject1.append(type1)
                subject1.append(typeValue1)
                subject1.append(desc1)
                subject1.append(descValue1)
                syllabusAttributed = subject1
                //"Subject :- \(objSyllabus.subject) \nType :- \(objSyllabus.syllabusType) \n\(objSyllabus.objDescription)"
            }
            return  (syllabusAttributed.string.count > 300) ? 300.0:UITableView.automaticDimension//UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewSyllabus{
            self.pushToSyllabusDetail(objSyllabus: self.arrayOfSyllabus[indexPath.row])
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

//   let syllabus = try? newJSONDecoder().decode(Syllabus.self, from: jsonData)
class Syllabus:NSObject{
    var pk = ""
    var classID = ""
    var divisonID = ""
    var subjectID: String = ""
    var typeID = ""
    var refType: String = ""
    var attachment: String = ""
    var examName: String = ""
    var objDescription = ""
    var publishOnWeb = ""
    var publishOnApp = ""
    var status: String = ""
    var created = ""
    var modifie = ""
    var syllabusType: String = ""
    var subject: String = ""
    /*
     {
     "pk": "11",
     "class_id": "1",
     "divison_id": "1,2",
     "subject_id": "1",
     "type_id": "3",
     "ref_type": "syllabus",
     "attachment": "http://schoolerp.project-demo.info/assets/uploads/syllabus/1101.pdf",
     "exam_name": null,
     "description": "yearly syllabus ",
     "publish_on_web": "1",
     "publish_on_app": "1",
     "status": "1",
     "created": "2019-03-19 00:00:00",
     "modified": "2019-03-27 00:00:00",
     "syllabus_type": "Yearly",
     "subject": "Language - Hindi"
     }
     */
    init(syllabusDetail:[String:Any]) {
        super.init()
        if let _ = syllabusDetail["pk"],!(syllabusDetail["pk"] is NSNull){
            self.pk = "\(syllabusDetail["pk"]!)"
        }
        if let _ = syllabusDetail["class_id"],!(syllabusDetail["class_id"] is NSNull){
            self.classID = "\(syllabusDetail["class_id"]!)"
        }
        if let _ = syllabusDetail["divison_id"],!(syllabusDetail["divison_id"] is NSNull){
             self.divisonID = "\(syllabusDetail["divison_id"]!)"
        }
        if let _ = syllabusDetail["subject_id"],!(syllabusDetail["subject_id"] is NSNull){
            self.subjectID = "\(syllabusDetail["subject_id"]!)"
        }
        if let _ = syllabusDetail["type_id"],!(syllabusDetail["type_id"] is NSNull){
            self.typeID = "\(syllabusDetail["type_id"]!)"
        }
        if let _ = syllabusDetail["ref_type"],!(syllabusDetail["ref_type"] is NSNull){
            self.refType = "\(syllabusDetail["ref_type"]!)"
        }
        if let _ = syllabusDetail["attachment"],!(syllabusDetail["attachment"] is NSNull){
            self.attachment = "\(syllabusDetail["attachment"]!)"
        }
        if let _ = syllabusDetail["exam_name"],!(syllabusDetail["exam_name"] is NSNull){
            self.examName = "\(syllabusDetail["exam_name"]!)"
        }
        if let _ = syllabusDetail["description"],!(syllabusDetail["description"] is NSNull){
            self.objDescription = "\(syllabusDetail["description"]!)"
        }
        if let _ = syllabusDetail["publish_on_web"],!(syllabusDetail["publish_on_web"] is NSNull){
            self.publishOnWeb = "\(syllabusDetail["publish_on_web"]!)"
        }
        if let _ = syllabusDetail["publish_on_app"],!(syllabusDetail["publish_on_app"] is NSNull){
            self.publishOnApp = "\(syllabusDetail["publish_on_app"]!)"
        }
        if let _ = syllabusDetail["status"],!(syllabusDetail["status"] is NSNull){
            self.status = "\(syllabusDetail["status"]!)"
        }
        if let _ = syllabusDetail["created"],!(syllabusDetail["created"] is NSNull){
            self.created = "\(syllabusDetail["created"]!)"
        }
        if let _ = syllabusDetail["modified"],!(syllabusDetail["modified"] is NSNull){
            self.modifie = "\(syllabusDetail["modified"]!)"
        }
        if let _ = syllabusDetail["syllabus_type"],!(syllabusDetail["syllabus_type"] is NSNull){
            self.syllabusType = "\(syllabusDetail["syllabus_type"]!)"
        }
        if let _ = syllabusDetail["subject"],!(syllabusDetail["subject"] is NSNull){
            self.subject = "\(syllabusDetail["subject"]!)"
        }
    }
}
