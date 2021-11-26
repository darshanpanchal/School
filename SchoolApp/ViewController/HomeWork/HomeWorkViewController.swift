//
//  HomeWorkViewController.swift
//  SchoolApp
//
//  Created by user on 18/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage


class HomeWorkViewController: UIViewController {
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
    var isLoadMoreHomework:Bool = false
    var currentPage:Int = 0
     var arrayOfHomeWork:[Homework] = []
    //HomeWork
    @IBOutlet var tableViewHomeWork:UITableView!
    
    @IBOutlet var buttonAddHomeWork:RoundButton!
    
    @IBOutlet var buttonFilter:UIButton!
    
    var refreshControl = UIRefreshControl()

    var filterParameters:[String:Any] = [:]
    
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

        //configure saved user detail
        self.configureSavedUserProfileData()
        
        //configure homework tableview
        self.configureHomeWorkTableView()
        
        //getHomeWork
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getHomeworkListAPIRequest(userID: user.userId)
        }
        
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
    @IBAction func addHomeWorkSelector(sender:UIButton){
        self.pushToAddHomeWorkViewController()
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
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.HomeWork")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        
        self.buttonAddHomeWork.tintColor = kSchoolThemeColor
        self.buttonAddHomeWork.backgroundColor = kSchoolThemeColor
        
        self.configureCurrentUserRole()
        
    }
    func configureCurrentUserRole(){
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userType == .student{
                self.buttonAddHomeWork.isHidden = true
            }else{
                self.buttonAddHomeWork.isHidden = false
            }
        }else{
            self.buttonAddHomeWork.isHidden = false
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
        if let user = User.getUserFromUserDefault(),user.userType == .student { //hide footer for students
            self.tableViewHomeWork.tableFooterView = UIView()
        }
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewHomeWork.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.filterParameters = [:]
        self.isPullToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getHomeworkListAPIRequest(userID: user.userId)
            }
        }
    }
    func configureCurrentUserDetail(userID:String){
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: userID) { (response) in
            if let objUserCoreData:Users =  response as? Users{
                if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
//                    self.buttonUserProfile.sd_setImage(with: objURl, for: .normal, placeholderImage:UIImage.init(named: "ic_profile_circle"), options: .refreshCached, completed: nil)
                    self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)

                }else{
                    self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal)
                }
//                self.buttonUserProfile.tintColor = UIColor.clear
            }
        }
    }
    // MARK: - API Request Methods
    func getHomeworkListAPIRequest(userID:String){
        var notificationParameters = ["user_id":"\(userID)","page":"\(self.currentPage)"]
        let _ = self.filterParameters.map{
            notificationParameters[$0.0] = "\($0.1)"
        }
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kStudentHomework, parameter:notificationParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayHomework = success["data"] as? [[String:Any]]{//,let arrayNotice = jsonData["notice"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    if self.currentPage == 0{
                        self.arrayOfHomeWork.removeAll()
                    }
                    self.isLoadMoreHomework = arrayHomework.count > 0
                    for objHomework:[String:Any] in arrayHomework{
                        let homework =  Homework.init(homeworkId:"\(objHomework["homework_id"] ?? "")" , homeworkContent: "\(objHomework["homework_text"] ?? "")", homeworkDate: "\(objHomework["homework_date"] ?? "")".changeDateFormateddMMYYYY,classID: "\(objHomework["class_id"] ?? "")", className: "\(objHomework["class_name"] ?? "")", sectionID: "\(objHomework["divison_id"] ?? "")", sectionName: "\(objHomework["divison_name"] ?? "")",attachmentType:"\(objHomework["attachment_type"] ?? "")",attachment:"\(objHomework["attachment"] ?? "")")
                        /*
                        let homework = Homework.init(homeworkId:"\(objHomework["homework_id"] ?? "")" , homeworkContent: "\(objHomework["homework_text"] ?? "")", homeworkDate: "\(objHomework["homework_date"] ?? "")".changeDateFormateddMMYYYY)
                        */
                        self.arrayOfHomeWork.append(homework)
                    }
                    self.tableViewHomeWork.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            DispatchQueue.main.async {
                self.isLoadMoreHomework = false
                //self.currentPage = 0
                //self.arrayOfHomeWork.removeAll()
                self.tableViewHomeWork.reloadData()
            }
            
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                
                if "\(errorMessage)".range(of:"homework",options: .caseInsensitive) != nil && self.currentPage != 0{
                    return
                }
                guard !"\(errorMessage)".contains("No more homework available.") && self.currentPage != 0 else {
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
    // MARK: - Navigation
    func pushToHomeWorkDetailView(objHomeWork:Homework){
        if let homeworkDetailView = self.storyboard?.instantiateViewController(withIdentifier: "HomeWorkDetailViewController") as? HomeWorkDetailViewController{
            homeworkDetailView.objHomeWork = objHomeWork
            self.navigationController?.pushViewController(homeworkDetailView, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddHomeWorkViewController(){
        if let addNoticeViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddNoticeViewController") as? AddNoticeViewController{
            addNoticeViewController.isForHomeWork = true
            self.navigationController?.pushViewController(addNoticeViewController, animated: true)
        }
        /*
        if let addHomeWorkVC = self.storyboard?.instantiateViewController(withIdentifier: "AddHomeworkViewController") as? AddHomeworkViewController{
            self.navigationController?.pushViewController(addHomeWorkVC, animated: true)
        }*/
    }
}
extension HomeWorkViewController:FilterDelegate{
    func didConfirmfilterParameters(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.currentPage = 0
        self.arrayOfHomeWork.removeAll()
        //self.refreshTableView()
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getHomeworkListAPIRequest(userID: user.userId)
            }
        }
    }
}
extension HomeWorkViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewHomeWork{
            if self.arrayOfHomeWork.count == 0{
                tableView.showMessageLabel(msg: "No homework available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfHomeWork.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewHomeWork{
             let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            if let currentUser = User.getUserFromUserDefault(){
                if currentUser.userType == .student{
                    homeworkCell.lblHomeWorkDetail.text = "\(self.arrayOfHomeWork[indexPath.row].homeworkContent)\n"
                }else{
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    let classValue = NSMutableAttributedString.init(string: "\(self.arrayOfHomeWork[indexPath.row].className)", attributes: self.attributesNormal)
                    //let classValue = NSMutableAttributedString.init(string: "\(self.arrayOfHomeWork[indexPath.row].className) - \(self.arrayOfHomeWork[indexPath.row].sectionName)", attributes: self.attributesNormal)
                      classString.append(classValue)
                    let homeworkAttributedString = NSAttributedString.init(string:"\n\n\(self.arrayOfHomeWork[indexPath.row].homeworkContent)\n" , attributes: self.attributesNormal)
                      classString.append(homeworkAttributedString)
                    homeworkCell.lblHomeWorkDetail.attributedText = classString//"\(self.arrayOfHomeWork[indexPath.row].homeworkContent)\n"
                }
            }
            homeworkCell.lblHomeWorkDate.text = "\(self.arrayOfHomeWork[indexPath.row].homeworkDate.changeDateFormateddMMYYYY)"
            homeworkCell.attachMentImageView.isHidden = !(self.arrayOfHomeWork[indexPath.row].attachmentType.count > 0)
            if self.arrayOfHomeWork[indexPath.row].attachmentType == "pdf"{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
            }else if self.arrayOfHomeWork[indexPath.row].attachmentType == "doc" || self.arrayOfHomeWork[indexPath.row].attachmentType == "docx"{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_doc")
            }else{
                homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
            }
            if indexPath.row+1 == self.arrayOfHomeWork.count, self.isLoadMoreHomework{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getHomeworkListAPIRequest(userID: user.userId)
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
        if tableView == self.tableViewHomeWork{
            return ("\(self.arrayOfHomeWork[indexPath.row].homeworkContent)".count > 200) ? 200.0:UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewHomeWork{
            if self.arrayOfHomeWork.count > indexPath.row{
                self.pushToHomeWorkDetailView(objHomeWork: self.arrayOfHomeWork[indexPath.row])
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
struct Homework {
    let homeworkId,homeworkContent,homeworkDate,classID,className,sectionID,sectionName,attachmentType,attachment:String
}
