//
//  FeesViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class RemarkViewController: UIViewController {
    //navigation view
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewProfile:UITableView!
    @IBOutlet var tableViewHeight:NSLayoutConstraint!
    @IBOutlet var buttonDropDown:UIButton!
    
    @IBOutlet var buttonFilter:UIButton!
    
    var filterParameters:[String:Any] = [:]

    var heightOfUserProfileTableViewCell:CGFloat{
        get{
            return 50.0
        }
    }
    
    var arrayOfUserDetail:[NSManagedObject] = []
    
    @IBOutlet var tableViewRemark:UITableView!
    
    @IBOutlet var buttonAddRemark:UIButton!
    
    var refreshControl = UIRefreshControl()
    
    var currentPage:Int = 0
    var isLoadMoreRemark = false
    var arrayOfRemark:[StudentRemark] = []
    var isPullToRefresh = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        
        self.configureRemarkTableView()
        
        self.configureSavedUserProfileData()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getRemarkAPIRequest(userID: user.userId)
        }
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.remark")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        self.buttonAddRemark.backgroundColor = kSchoolThemeColor
        
        self.configureCurrentUserRole()
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
    func configureRemarkTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewRemark.rowHeight = UITableView.automaticDimension
        self.tableViewRemark.estimatedRowHeight = 100.0
        self.tableViewRemark.delegate = self
        self.tableViewRemark.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewRemark.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewRemark.separatorStyle = .none
        self.tableViewRemark.isScrollEnabled = true
        self.tableViewRemark.tableHeaderView = UIView()
//        self.tableViewRemark.tableFooterView = UIView()
        self.tableViewRemark.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewRemark.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.filterParameters = [:]
        self.isPullToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getRemarkAPIRequest(userID: user.userId)
            }
        }
    }
    func configureCurrentUserRole(){
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userType == .student{
                self.buttonAddRemark.isHidden = true
            }else{
                self.buttonAddRemark.isHidden = false
            }
        }else{
            self.buttonAddRemark.isHidden = false
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
            //self.buttonUserProfile.isEnabled = self.arrayOfUserDetail.count > 0
            //self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
            
        }
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    // MARK: - API Request Methods
    func getRemarkAPIRequest(userID:String){
        var leaveParameters = ["user_id":"\(userID)","page":"\(currentPage)"]
        let _ = self.filterParameters.map{
            leaveParameters[$0.0] = "\($0.1)"
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentRemark, parameter:leaveParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayRemark = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfRemark.removeAll()
                }
                self.isLoadMoreRemark = arrayRemark.count > 0
                for var objRemark:[String:Any] in arrayRemark{
                    objRemark.updateJSONNullToString()
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objRemark, options:.prettyPrinted)
                        if let remark = try? JSONDecoder().decode(StudentRemark.self, from: jsondata){
                            self.arrayOfRemark.append(remark)
                          }
                    }catch{
                       
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewRemark.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            self.isLoadMoreRemark = false
            DispatchQueue.main.async {
//                self.currentPage = 0
//                self.arrayOfRemark.removeAll()
                self.tableViewRemark.reloadData()
            }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    if "\(errorMessage)".range(of:"remarks",options: .caseInsensitive) != nil{
                        return
                    }

                    guard !"\(errorMessage)".contains("No remarks available.") else {
                        print(self.arrayOfRemark.count)
                        return
                    }
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
    @IBAction func buttonAddRemarkSelector(sender:UIButton){
        self.pushToAddRemarkViewController()
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
    func pushToRemarkTableDetail(objStudentRemark:StudentRemark){
        if let examRemarkDetail:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            examRemarkDetail.isStudentRemark = true
            examRemarkDetail.objStudentRemark = objStudentRemark
            
            self.navigationController?.pushViewController(examRemarkDetail, animated: true)
        }
    }
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    func pushToAddRemarkViewController(){
        if let addRemarkVC = self.storyboard?.instantiateViewController(withIdentifier: "AddRemarkViewController") as? AddRemarkViewController{
            self.navigationController?.pushViewController(addRemarkVC, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension RemarkViewController:FilterDelegate{
    func didConfirmfilterParameters(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.currentPage = 0
        self.arrayOfRemark.removeAll()
        //self.refreshTableView()
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getRemarkAPIRequest(userID: user.userId)
            }
        }
    }
}
extension RemarkViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewRemark{
            if self.arrayOfRemark.count == 0{
                tableView.showMessageLabel(msg: "No remarks available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfRemark.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
  
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewRemark{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            var objRemark:StudentRemark = self.arrayOfRemark[indexPath.row]
            let type = NSMutableAttributedString.init(string: "Type : ", attributes: self.attributesBold)
            let typeValue = NSMutableAttributedString.init(string: "\(objRemark.remarkType)", attributes: self.attributesNormal)
            let category = NSMutableAttributedString.init(string: "\n\nCategory : ", attributes: self.attributesBold)
            let categoryValue = NSMutableAttributedString.init(string: "\(objRemark.category) ", attributes: self.attributesNormal)
            //            objRemark.remarkSMSText += objRemark.remarkSMSText
            let otherString = NSMutableAttributedString.init(string: "\n\n\(objRemark.remarkName)\n\n\(objRemark.remarkSMSText)\n", attributes: self.attributesNormal)
            type.append(typeValue)
            type.append(category)
            type.append(categoryValue)
            type.append(otherString)
            if let currentUser = User.getUserFromUserDefault(){
                if currentUser.userType == .student{
                        homeworkCell.lblHomeWorkDetail.attributedText = type
                }else{ //add class name and section name and student name for admin role
                    
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    let classValue = NSMutableAttributedString.init(string: "\(objRemark.className)\n", attributes: self.attributesNormal)
                    //let classValue = NSMutableAttributedString.init(string: "\(objRemark.className) - \(objRemark.sectionName)\n", attributes: self.attributesNormal)
                    classString.append(classValue)
                    let studentString = NSMutableAttributedString.init(string: "\nStudent : ", attributes: self.attributesBold)
                    let studentValue = NSAttributedString.init(string:"\n\n\(objRemark.studentName)\n\n", attributes: self.attributesNormal)
                    classString.append(studentString)
                    classString.append(studentValue)
                    classString.append(type)
                    homeworkCell.lblHomeWorkDetail.attributedText = classString
                }
            }
            
            //"Type : \(objRemark.remarkType) \nCategory :  \(objRemark.category) \n\(objRemark.remarkName)\n\(objRemark.remarkSMSText)\n"
            homeworkCell.lblHomeWorkDate.text = objRemark.remarkDate.changeDateFormateddMMYYYY
            homeworkCell.shadowView.isHidden = false
            homeworkCell.separatorInset = UIEdgeInsets.zero
            homeworkCell.layoutMargins = UIEdgeInsets.zero
            homeworkCell.attachMentImageView.isHidden = true
            
            if indexPath.row+1 == self.arrayOfRemark.count, self.isLoadMoreRemark{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getRemarkAPIRequest(userID: user.userId)
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
        if tableView == self.tableViewRemark{
            
            let objRemark:StudentRemark = self.arrayOfRemark[indexPath.row]
            let type = NSMutableAttributedString.init(string: "Type : ", attributes: self.attributesBold)
            let typeValue = NSMutableAttributedString.init(string: "\(objRemark.remarkType)", attributes: self.attributesNormal)
            let category = NSMutableAttributedString.init(string: "\n\nCategory : ", attributes: self.attributesBold)
            let categoryValue = NSMutableAttributedString.init(string: "\(objRemark.category) ", attributes: self.attributesNormal)
//            objRemark.remarkSMSText += objRemark.remarkSMSText
            let otherString = NSMutableAttributedString.init(string: "\n\n\(objRemark.remarkName)\n\n\(objRemark.remarkSMSText)\n", attributes: self.attributesNormal)
            type.append(typeValue)
            type.append(category)
            type.append(categoryValue)
            type.append(otherString)
            return (type.string.count > 300) ? 300.0:UITableView.automaticDimension

//            return UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewRemark{
            if self.arrayOfRemark.count > indexPath.row{
                self.pushToRemarkTableDetail(objStudentRemark: self.arrayOfRemark[indexPath.row])
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
struct StudentRemark:Codable {
    let pk, studentID, remarksCategoryID, remarkID: String
    let remarkType, remarkDate, note, remarksBy: String
    let category, remarkName, points: String
    var remarkSMSText:String = ""
    let classID,className,sectionID,sectionName,studentName:String
    enum CodingKeys: String, CodingKey {
        case pk
        case studentID = "student_id"
        case remarksCategoryID = "remarks_category_id"
        case remarkID = "remark_id"
        case remarkType = "remark_type"
        case remarkDate = "remark_date"
        case note
        case remarksBy = "remarks_by"
        case category
        case remarkName = "remark_name"
        case remarkSMSText = "remark_sms_text"
        case points
        case classID = "class_id"
        case className = "class_name"
        case sectionID = "divison_id"
        case sectionName = "divison_name"
        case studentName = "student_name"
    }
 
  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.pk =  try values.decodeIfPresent(String.self, forKey: .pk) ?? ""
        self.studentID = try values.decodeIfPresent(String.self, forKey: .studentID) ?? ""
        self.remarksCategoryID =  try values.decodeIfPresent(String.self, forKey: .remarksCategoryID) ?? ""
        self.remarkID = try values.decodeIfPresent(String.self, forKey: .remarkID) ?? ""
        self.remarkType =  try values.decodeIfPresent(String.self, forKey: .remarkType) ?? ""
        self.remarkDate =  try values.decodeIfPresent(String.self, forKey: .remarkDate) ?? ""
        self.note =  try values.decodeIfPresent(String.self, forKey: .note) ?? ""
        self.remarksBy =  try values.decodeIfPresent(String.self, forKey: .remarksBy) ?? ""
        self.category = try values.decodeIfPresent(String.self, forKey: .category) ?? ""
        self.remarkName =  try values.decodeIfPresent(String.self, forKey: .remarkName) ?? ""
        self.remarkSMSText =  try values.decodeIfPresent(String.self, forKey: .remarkSMSText) ?? ""
        self.points = try values.decodeIfPresent(String.self, forKey: .points) ?? ""
        self.classID = try values.decodeIfPresent(String.self, forKey: .classID) ?? ""
        self.className = try values.decodeIfPresent(String.self, forKey: .className) ?? ""
        self.sectionID = try values.decodeIfPresent(String.self, forKey: .sectionID) ?? ""
        self.sectionName = try values.decodeIfPresent(String.self, forKey: .sectionName) ?? ""
        self.studentName = try values.decodeIfPresent(String.self, forKey: .studentName) ?? ""
    }
}
class StudentRemarkOld: Codable {
    
    let pk, studentID, remarksCategoryID, remarkID: String
    let remarkType, remarkDate, note, remarksBy: String
    let category, remarkName, points: String
    var remarkSMSText:String = ""
    let classID,className,sectionID,sectionName,studentName:String
    enum CodingKeys: String, CodingKey {
        case pk
        case studentID = "student_id"
        case remarksCategoryID = "remarks_category_id"
        case remarkID = "remark_id"
        case remarkType = "remark_type"
        case remarkDate = "remark_date"
        case note
        case remarksBy = "remarks_by"
        case category
        case remarkName = "remark_name"
        case remarkSMSText = "remark_sms_text"
        case points
        case classID = "class_id"
        case className = "class_name"
        case sectionID = "divison_id"
        case sectionName = "divison_name"
        case studentName = "student_name"
    }
    
    init(pk: String, studentID: String, remarksCategoryID: String, remarkID: String, remarkType: String, remarkDate: String, note: String, remarksBy: String, category: String, remarkName: String, remarkSMSText: String, points: String,classID:String,className:String,sectionID:String,sectionName:String,studentName:String) {
        self.pk = pk
        self.studentID = studentID
        self.remarksCategoryID = remarksCategoryID
        self.remarkID = remarkID
        self.remarkType = remarkType
        self.remarkDate = remarkDate
        self.note = note
        self.remarksBy = remarksBy
        self.category = category
        self.remarkName = remarkName
        self.remarkSMSText = remarkSMSText
        self.points = points
        self.classID = classID
        self.className = className
        self.sectionID = sectionID
        self.sectionName = sectionName
        self.studentName = studentName
    }
}
class StudentRemarkUpdate: Codable {
    let remarkID, remarksCategoryID, remarkName, remarkSMSText: String
    let remarkType, points, status, created: String
    let modified: String
    
    enum CodingKeys: String, CodingKey {
        case remarkID = "remark_id"
        case remarksCategoryID = "remarks_category_id"
        case remarkName = "remark_name"
        case remarkSMSText = "remark_sms_text"
        case remarkType = "remark_type"
        case points, status, created, modified
    }
    
    init(remarkID: String, remarksCategoryID: String, remarkName: String, remarkSMSText: String, remarkType: String, points: String, status: String, created: String, modified: String) {
        self.remarkID = remarkID
        self.remarksCategoryID = remarksCategoryID
        self.remarkName = remarkName
        self.remarkSMSText = remarkSMSText
        self.remarkType = remarkType
        self.points = points
        self.status = status
        self.created = created
        self.modified = modified
    }
}
