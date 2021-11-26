//
// HolidayHomeworkViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class HolidayHomeworkViewController: UIViewController {
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
    var arrayOfHoliday:[HolidayHomework] = []
    var currentPage:Int = 0
    //HomeWork
    @IBOutlet var tableViewHomeWork:UITableView!
    
    var refreshControl = UIRefreshControl()
    var isPullToRefresh = false
    var isLoadMoreHomework:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        //configure holiday homework
        self.configureHomeWorkTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getHolidayAPIRequest(userID: user.userId)
        }
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.holidayhomework")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        
    }
    func configureHomeWorkTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewHomeWork.rowHeight = UITableView.automaticDimension
        self.tableViewHomeWork.estimatedRowHeight = 100.0
        self.tableViewHomeWork.delegate = self
        self.tableViewHomeWork.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewHomeWork.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewHomeWork.separatorStyle = .none
        self.tableViewHomeWork.isScrollEnabled = true
        self.tableViewHomeWork.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewHomeWork.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.isPullToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getHolidayAPIRequest(userID:user.userId)
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
    func getHolidayAPIRequest(userID:String){
        let leaveParameters = ["user_id":"\(userID)","page":"\(currentPage)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGETHolidayHomework, parameter:leaveParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfLeave = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfHoliday.removeAll()
                }
                self.isLoadMoreHomework = arrayOfLeave.count > 0
                for var objLeave:[String:Any] in arrayOfLeave{
                    objLeave.updateJSONNullToString()
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objLeave, options:.prettyPrinted)
                        if let holidayHomework = try? JSONDecoder().decode(HolidayHomework.self, from: jsondata){
                            self.arrayOfHoliday.append(holidayHomework)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewHomeWork.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    guard !"\(errorMessage)".contains("No homework available.") else {
                        print(self.arrayOfHoliday.count)
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
    // MARK: - Navigation
    func pushToHomeWorkDetailView(objHomeWork:HolidayHomework){
        if let homeworkDetailView:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            homeworkDetailView.isForHomework = true
            homeworkDetailView.objHolidayHomework = objHomeWork
            self.navigationController?.pushViewController(homeworkDetailView, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension HolidayHomeworkViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewHomeWork{
            if self.arrayOfHoliday.count == 0{
                tableView.showMessageLabel(msg: "No homework available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfHoliday.count
        }else{
            return self.arrayOfUserDetail.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewHomeWork{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let objHoliday:HolidayHomework = self.arrayOfHoliday[indexPath.row]
            homeworkCell.lblHomeWorkDetail.text = objHoliday.description
            homeworkCell.lblHomeWorkDate.text = objHoliday.holidayName
            homeworkCell.shadowView.isHidden = false
            homeworkCell.separatorInset = UIEdgeInsets.zero
            homeworkCell.layoutMargins = UIEdgeInsets.zero
            
            homeworkCell.attachMentImageView.isHidden = !(objHoliday.attachment.count > 0)
            if objHoliday.attachment.fileExtension() == "pdf"{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
            }else{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
            }
            if indexPath.row+1 == self.arrayOfHoliday.count, self.isLoadMoreHomework{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getHolidayAPIRequest(userID:user.userId)
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
        if tableView == self.tableViewHomeWork{
            return ("\(self.arrayOfHoliday[indexPath.row].description)".count > 200) ? 200.0:UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewHomeWork{
            if self.arrayOfHoliday.count > indexPath.row{
               self.pushToHomeWorkDetailView(objHomeWork: self.arrayOfHoliday[indexPath.row])
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

struct HolidayHomework: Codable {
    let pk, classID, divisonID, subjectID: String
    let typeID, refType: String
    let attachment: String
    let description, publishOnWeb, publishOnApp, status: String
    let created, modified, subject, holidayName: String
    
    enum CodingKeys: String, CodingKey {
        case pk
        case classID = "class_id"
        case divisonID = "divison_id"
        case subjectID = "subject_id"
        case typeID = "type_id"
        case refType = "ref_type"
        case attachment, description
        case publishOnWeb = "publish_on_web"
        case publishOnApp = "publish_on_app"
        case status, created, modified, subject
        case holidayName = "holiday_name"
    }
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.pk = try values.decodeIfPresent(String.self, forKey: .pk) ?? ""
        self.classID = try values.decodeIfPresent(String.self, forKey: .classID) ?? ""
        self.divisonID = try values.decodeIfPresent(String.self, forKey: .divisonID) ?? ""
        self.subjectID = try values.decodeIfPresent(String.self, forKey: .subjectID) ?? ""
        self.typeID = try values.decodeIfPresent(String.self, forKey: .typeID) ?? ""
        self.refType = try values.decodeIfPresent(String.self, forKey: .refType) ?? ""
        self.attachment = try values.decodeIfPresent(String.self, forKey: .attachment) ?? ""
        self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.publishOnWeb = try values.decodeIfPresent(String.self, forKey: .publishOnWeb) ?? ""
        self.publishOnApp = try values.decodeIfPresent(String.self, forKey: .publishOnApp) ?? ""
        self.status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.created = try values.decodeIfPresent(String.self, forKey: .created) ?? ""
        self.modified = try values.decodeIfPresent(String.self, forKey: .modified) ?? ""
        self.subject = try values.decodeIfPresent(String.self, forKey: .subject) ?? ""
        self.holidayName = try values.decodeIfPresent(String.self, forKey: .holidayName) ?? ""
    }
    
}

