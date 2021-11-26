//
//  ExamTimeTableViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import QuickLook

class ExamTimeTableViewController: UIViewController {
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
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var arrayOfUserDetail:[NSManagedObject] = []
     var previewItem:NSURL?
    
    @IBOutlet var tableViewExamTimeTable:UITableView!
    var currentPage:Int = 0
    var isLoadMoreTimeTable = false
    var arrayOfTimeTable:[ExamTimeTable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        //configure exam time table
        self.configureExamTimeTableView()
        
        self.configureSavedUserProfileData()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getExamTimeTableAPIRequest(userID: user.userId)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.ExamTimeTable")
        self.lblTitle.font = CommonClass.shared.titleFont
        
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
    func configureExamTimeTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewExamTimeTable.rowHeight = UITableView.automaticDimension
        self.tableViewExamTimeTable.estimatedRowHeight = 100.0
        self.tableViewExamTimeTable.delegate = self
        self.tableViewExamTimeTable.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewExamTimeTable.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewExamTimeTable.separatorStyle = .none
        self.tableViewExamTimeTable.isScrollEnabled = true
        self.tableViewExamTimeTable.tableHeaderView = UIView()
        self.tableViewExamTimeTable.tableFooterView = UIView()
        self.tableViewExamTimeTable.reloadData()
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
    func getExamTimeTableAPIRequest(userID:String){
        let leaveParameters = ["user_id":"\(userID)","page":"\(currentPage)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentExamTimeTable, parameter:leaveParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfTimeTable = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfTimeTable.removeAll()
                }
                self.isLoadMoreTimeTable = arrayOfTimeTable.count > 0
                for var objTimeTable:[String:Any] in arrayOfTimeTable{
                    objTimeTable.updateJSONNullToString()
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objTimeTable, options:.prettyPrinted)
                        if let holidayHomework = try? JSONDecoder().decode(ExamTimeTable.self, from: jsondata){
                            self.arrayOfTimeTable.append(holidayHomework)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewExamTimeTable.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    guard !"\(errorMessage)".contains("No exam schedule available.") else {
                        print(self.arrayOfTimeTable.count)
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
    func pushToExamTimeTableDetail(objTimetable:ExamTimeTable){
        if let examTimeTableDetail:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            examTimeTableDetail.isExamTimeTable = true
            examTimeTableDetail.objExamTimeTable = objTimetable
            self.navigationController?.pushViewController(examTimeTableDetail, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension ExamTimeTableViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewExamTimeTable{
            if self.arrayOfTimeTable.count == 0{
                tableView.showMessageLabel(msg: "No exam schedule available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfTimeTable.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewExamTimeTable{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let objTimetable:ExamTimeTable = self.arrayOfTimeTable[indexPath.row]
            let achirvement = NSMutableAttributedString.init(string: "\nUpdated On :  \(objTimetable.modified.changeDateFormat)", attributes: self.attributesNormal)
            let desc = NSMutableAttributedString.init(string: "\n\n\(objTimetable.description)\n", attributes: self.attributesNormal)

            achirvement.append(desc)
            homeworkCell.lblHomeWorkDetail.attributedText = achirvement
            
            homeworkCell.lblHomeWorkDate.text = objTimetable.examName
            homeworkCell.shadowView.isHidden = false
            
            homeworkCell.attachMentImageView.isHidden = !(objTimetable.attachment.count > 0)
            if objTimetable.attachment.fileExtension() == "pdf"{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
            }else{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
            }
            if indexPath.row+1 == self.arrayOfTimeTable.count, self.isLoadMoreTimeTable{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getExamTimeTableAPIRequest(userID: user.userId)
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
        if tableView == self.tableViewExamTimeTable{
            return UITableView.automaticDimension//("\(self.arrayOfTimeTable[indexPath.row].description)".count > 200) ? 200.0:UITableView.automaticDimension//UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewExamTimeTable{
            if self.arrayOfTimeTable.count > indexPath.row{
                self.presentPDFInQuickLook(strURL: self.arrayOfTimeTable[indexPath.row].attachment)
                //self.pushToExamTimeTableDetail(objTimetable:self.arrayOfTimeTable[indexPath.row])
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
    func presentPDFInQuickLook(strURL:String){

        guard strURL.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "No attachment available.")
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
}
extension ExamTimeTableViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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

struct ExamTimeTable: Codable {
    let pk, classID, divisonID, subjectID: String
    let typeID, refType: String
    let attachment: String
    let examName, description, publishOnWeb, publishOnApp: String
    let status, created, modified: String
    
    enum CodingKeys: String, CodingKey {
        case pk
        case classID = "class_id"
        case divisonID = "divison_id"
        case subjectID = "subject_id"
        case typeID = "type_id"
        case refType = "ref_type"
        case attachment
        case examName = "exam_name"
        case description
        case publishOnWeb = "publish_on_web"
        case publishOnApp = "publish_on_app"
        case status, created, modified
    }
    init(from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.pk = try values.decodeIfPresent(String.self, forKey: .pk) ?? ""
        self.classID = try values.decodeIfPresent(String.self, forKey: .classID) ?? ""
        self.divisonID = try values.decodeIfPresent(String.self, forKey: .divisonID) ?? ""
        self.subjectID = try values.decodeIfPresent(String.self, forKey: .subjectID) ?? ""
        self.typeID = try values.decodeIfPresent(String.self, forKey: .typeID) ?? ""
        self.refType = try values.decodeIfPresent(String.self, forKey: .refType) ?? ""
        self.attachment = try values.decodeIfPresent(String.self, forKey: .attachment) ?? ""
        self.examName = try values.decodeIfPresent(String.self, forKey: .examName) ?? ""
        self.description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.publishOnWeb = try values.decodeIfPresent(String.self, forKey: .publishOnWeb) ?? ""
        self.publishOnApp = try values.decodeIfPresent(String.self, forKey: .publishOnApp) ?? ""
        self.status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.created = try values.decodeIfPresent(String.self, forKey: .created) ?? ""
        self.modified = try values.decodeIfPresent(String.self, forKey: .modified) ?? ""
    }
}
