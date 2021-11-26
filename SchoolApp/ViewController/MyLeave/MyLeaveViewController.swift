//
//  MyLeaveViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import QuickLook

class MyLeaveViewController: UIViewController {
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
    var heightOfLeaveTableViewCell:CGFloat{
        get{
            if let currentUser = User.getUserFromUserDefault(){
                if currentUser.userType == .student{
                    return 220.0
                }else{
                    return 220.0 + 55.0
                }
            }
            return 220.0
        }
    }
    var arrayOfUserDetail:[NSManagedObject] = []
    
    @IBOutlet var tableViewLeave:UITableView!
    
    var refreshControl = UIRefreshControl()
    
    var isLoadMoreLeave:Bool = false
    var currentPage:Int = 0
    var arrayOfLeave:[MyLeave] = []
    var previewItem:NSURL?

    @IBOutlet var buttonAddLeave:UIButton!
    
    @IBOutlet var buttonFilter:UIButton!
    
    var filterParameters:[String:Any] = [:]
    var isPUllToRefresh = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        //configure saved user profile data
        self.configureSavedUserProfileData()
        //confi
        self.configureLeaveTableView()
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            //get leaves
            //self.getMyLeaveAPIRequest(userID: user.userId)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
        if let user = User.getUserFromUserDefault(){
            //get leaves
            self.getMyLeaveAPIRequest(userID: user.userId)
        }
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.myleave")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonAddLeave.tintColor = kSchoolThemeColor
        self.buttonAddLeave.backgroundColor = kSchoolThemeColor
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
    func configureLeaveTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewLeave.rowHeight = UITableView.automaticDimension
        self.tableViewLeave.estimatedRowHeight = 100.0
        self.tableViewLeave.delegate = self
        self.tableViewLeave.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "MyLeaveTableViewCell", bundle: nil)
        self.tableViewLeave.register(objNib, forCellReuseIdentifier: "MyLeaveTableViewCell")
        self.tableViewLeave.separatorStyle = .none
        self.tableViewLeave.isScrollEnabled = true
//        self.tableViewLeave.tableFooterView = UIView()
        self.tableViewLeave.tableHeaderView = UIView()
        
        self.tableViewLeave.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewLeave.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.filterParameters = [:]
        self.isPUllToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getMyLeaveAPIRequest(userID: user.userId)
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
            if let user = User.getUserFromUserDefault(){
                self.buttonUserProfile.isHidden = !(self.arrayOfUserDetail.count > 0 && user.userType == .student) // 2 for student and 1 for admin
                if user.userType == .student{
                    self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
                }else{
                    self.buttonDropDown.isHidden = true //hide for admin
                }
                self.buttonFilter.isHidden = !(self.buttonUserProfile.isHidden)
                self.buttonAddLeave.isHidden = !(user.userrole_id == "2")
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
    func getMyLeaveAPIRequest(userID:String){
        var leaveParameters = ["user_id":"\(userID)","page":"\(self.currentPage)"]
        let _ = self.filterParameters.map{
            leaveParameters[$0.0] = "\($0.1)"
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentLeaves, parameter:leaveParameters as [String : AnyObject],isHudeShow: !self.isPUllToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfLeave = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfLeave.removeAll()
                }
                self.isLoadMoreLeave = arrayOfLeave.count > 0
                for objLeave:[String:Any] in arrayOfLeave{
                    let leave =  MyLeave.init(leaveDetail: objLeave)
                    self.arrayOfLeave.append(leave)
                }
                DispatchQueue.main.async {
                    self.tableViewLeave.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            DispatchQueue.main.async {
                if self.arrayOfLeave.count == 0{
                    self.tableViewLeave.reloadData()
                }
            }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                guard !"\(errorMessage)".contains("No leaves available.") else {
                    print(self.arrayOfLeave.count)
                    DispatchQueue.main.async {
                        if self.arrayOfLeave.count == 0{
                            self.tableViewLeave.reloadData()
                        }
                    }
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
    func approveAndCancelLeave(objLeave:MyLeave,isCancel:Bool){
        let leaveParameters = ["leave_id":"\(objLeave.leaveID)","leave_status":isCancel ? "\(2)":"\(1)"]
        
        //0 for unapprove 1 for approve  and 2 for decline
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kUpdateStudentLeaveStatus, parameter:leaveParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            
            
            if let success = responseSuccess as? [String:Any],let message = success["message"] as? String{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:message)
                }
                if let user = User.getUserFromUserDefault(){
                    self.currentPage = 0
                    self.arrayOfLeave.removeAll()
                    //get leaves
                    self.getMyLeaveAPIRequest(userID: user.userId)
                }
               
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                
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
    @IBAction func buttonAddLeaveSelector(sender:UIButton){
        self.pushToAddLeaveController()
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
    func pushToAddLeaveController(){
        if let addLeave = self.storyboard?.instantiateViewController(withIdentifier: "AddLeaveViewController") as? AddLeaveViewController{
            self.navigationController?.pushViewController(addLeave, animated: true)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension MyLeaveViewController:FilterDelegate{
    func didConfirmfilterParameters(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.currentPage = 0
        self.arrayOfLeave.removeAll()
//        self.refreshTableView()
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getMyLeaveAPIRequest(userID: user.userId)
            }
        }
    }
}
extension MyLeaveViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewLeave{
            if self.arrayOfLeave.count == 0{
                tableView.showMessageLabel(msg: "No leaves available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfLeave.count
        }else{
            return self.arrayOfUserDetail.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewLeave{
             let leaveCell:MyLeaveTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MyLeaveTableViewCell", for: indexPath) as! MyLeaveTableViewCell
            leaveCell.selectionStyle = .none
            if self.arrayOfLeave.count > indexPath.row{
                let objLeave = self.arrayOfLeave[indexPath.row]
                leaveCell.lblfromDate.text = objLeave.fromDate
                leaveCell.lbltodate.text = objLeave.toDate
                leaveCell.lblLeaveDays.text = objLeave.leaveDays
                leaveCell.lbldescription.numberOfLines = 2
                leaveCell.lblLeaveType.text = objLeave.leaveType
                leaveCell.lblLeaveStatus.text = objLeave.leaveStatus
                leaveCell.lbldescription.text = objLeave.leaveDescription
                leaveCell.lblClassValue.text = "\(objLeave.className)"//"\(objLeave.className) - \(objLeave.sectionName)"
                leaveCell.lblStudentValue.text = objLeave.studentName
                print(objLeave.documents)
                if let currentUser = User.getUserFromUserDefault(){
                    if currentUser.userType == .student {
                        leaveCell.lblClassName.isHidden = true
                        leaveCell.lblClassValue.isHidden = true
                        leaveCell.lblStudentName.isHidden = true
                        leaveCell.lblClassValue.isHidden = true
                    }else{
                        leaveCell.lblClassName.isHidden = false
                        leaveCell.lblClassValue.isHidden = false
                        leaveCell.lblStudentName.isHidden = false
                        leaveCell.lblClassValue.isHidden = false
                    }
                }
                if objLeave.documents.count > 0{
                    leaveCell.buttonDocument.isHidden = false
                }else{
                    leaveCell.buttonDocument.isHidden = true
                }
                if objLeave.leaveStatusIndex == "1"{ //approved then hide approve button
                    leaveCell.buttonApproveLeave.isHidden = true
                }else{
                    leaveCell.buttonApproveLeave.isHidden = false
                }
                if objLeave.leaveStatusIndex == "2"{ //approved then hide approve button
                    leaveCell.buttonCancelLeave.isHidden = true
                }else{
                    leaveCell.buttonCancelLeave.isHidden = false
                }
                if objLeave.leaveStatusIndex == "0"{
                     leaveCell.lblLeaveStatus.textColor = UIColor.black
                     leaveCell.buttonCancelLeave.isHidden = false
                     leaveCell.buttonApproveLeave.isHidden = false
                }else if objLeave.leaveStatusIndex == "1"{
                    leaveCell.buttonCancelLeave.isHidden = true
                    leaveCell.buttonApproveLeave.isHidden = true
                    leaveCell.lblLeaveStatus.textColor = UIColor.green
                }else{
                    leaveCell.buttonCancelLeave.isHidden = true
                    leaveCell.buttonApproveLeave.isHidden = true
                    leaveCell.lblLeaveStatus.textColor = UIColor.red
                }
                leaveCell.tag = indexPath.row
                leaveCell.delegate = self
                leaveCell.documentImage.isHidden = true
                leaveCell.selectionStyle = .none
                leaveCell.buttonDocument.tag = indexPath.row
                leaveCell.buttonDocument.addTarget(self, action: #selector(MyLeaveViewController.tapDetected), for: .touchUpInside)
                //let singleTap = UITapGestureRecognizer(target: self, action: #selector(MyLeaveViewController.tapDetected))
                //singleTap.numberOfTapsRequired = 1
                //leaveCell.documentImage.addGestureRecognizer(singleTap)
                if indexPath.row+1 == self.arrayOfLeave.count, self.isLoadMoreLeave{ //last index
                    DispatchQueue.global(qos: .background).async {
                        self.currentPage += 1
                        if let user = User.getUserFromUserDefault(){
                            self.getMyLeaveAPIRequest(userID: user.userId)
                        }
                    }
                }
            }
            return leaveCell
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
    @objc func tapDetected(sender:UIButton){
        DispatchQueue.main.async {
            if self.arrayOfLeave.count > sender.tag{
                let objLeave = self.arrayOfLeave[sender.tag]
                self.presentPDFInQuickLook(strURL: objLeave.documents)
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewLeave{
            return self.heightOfLeaveTableViewCell
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView == self.tableViewProfile else {
            return
        }
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
extension MyLeaveViewController:MyLeaveDelegate{
    func buttonAcceptLeave(index: Int) {
        let alertController = UIAlertController.init(title:"Approve", message: "Are you sure you want to approve this leave?", preferredStyle: .alert)
        let noAction = UIAlertAction(title:"No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(UIAlertAction.init(title:"Yes", style: .default, handler: { (_) in
            if self.arrayOfLeave.count > index{
                self.approveAndCancelLeave(objLeave: self.arrayOfLeave[index], isCancel: false)
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    func buttonCancelLeave(index: Int) {
        let alertController = UIAlertController.init(title:"Reject Leave", message: "Are you sure you want to reject this leave?", preferredStyle: .alert)
        let noAction = UIAlertAction(title:"No", style: .cancel, handler: nil)
        alertController.addAction(noAction)
        alertController.addAction(UIAlertAction.init(title:"Yes", style: .default, handler: { (_) in
            if self.arrayOfLeave.count > index{
                self.approveAndCancelLeave(objLeave: self.arrayOfLeave[index], isCancel: true)
            }
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
extension MyLeaveViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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

class MyLeave:NSObject {
    var leaveID: String = ""
    var leaveTypeID: String = ""
    var studentID: String = ""
    var fromDate: String = ""
    var toDate: String = ""
    var postedBy: String = ""
    var leaveDescription: String = ""
    var documents: String = ""
    var leaveStatus:String = ""
    var leaveStatusModifiedBy : String = ""
    var leaveDays: String = ""
    var leaveType:String = ""
    var leaveStatusIndex:String  = "" //0 for not arrproved 1 for approve and 2 for decline
    var classID:String = ""
    var className:String = ""
    var sectionID:String = ""
    var sectionName:String = ""
    var studentName:String = ""

    
    init(leaveDetail:[String:Any]){
        super.init()
        if let id = leaveDetail["leave_id"]{
            self.leaveID = "\(id)"
        }
        if let leavetypeid = leaveDetail["leave_type_id"]{
            self.leaveTypeID = "\(leavetypeid)"
        }
        if let studentid = leaveDetail["student_id"]{
            self.studentID = "\(studentid)"
        }
        if let fromDate = leaveDetail["from_date"]{
            self.fromDate = "\(fromDate)".changeDateFormateddMMYYYY
        }
        if let to_date = leaveDetail["to_date"]{
            self.toDate = "\(to_date)".changeDateFormateddMMYYYY
        }
        if let posted_by = leaveDetail["posted_by"]{
            self.postedBy = "\(posted_by)"
        }
        if let description = leaveDetail["description"]{
            self.leaveDescription = "\(description)"
        }
        if let documents = leaveDetail["documents"]{
            self.documents = "\(documents)"
        }
        if let leave_status = leaveDetail["leave_status"]{
            self.leaveStatusIndex = "\(leave_status)"
        }
        if let leave_status = leaveDetail["leave_status_text"]{
            self.leaveStatus = "\(leave_status)"
        }
        if let leave_status_modified_by = leaveDetail["leave_status_modified_by"]{
            self.leaveStatusModifiedBy = "\(leave_status_modified_by)"
        }
        if let leave_days = leaveDetail["leave_days"]{
            self.leaveDays = "\(leave_days)"
        }
        if let leave_type = leaveDetail["leave_type"]{
            self.leaveType = "\(leave_type)"
        }
        if let objClassID = leaveDetail["class_id"]{
            self.classID = "\(objClassID)"
        }
        if let objclass_name = leaveDetail["class_name"]{
            self.className = "\(objclass_name)"
        }
        if let objdivison_id = leaveDetail["divison_id"]{
            self.sectionID = "\(objdivison_id)"
        }
        if let objdivison_name = leaveDetail["divison_name"]{
            self.sectionName = "\(objdivison_name)"
        }
        if let student_name = leaveDetail["student_name"]{
            self.studentName = "\(student_name)"
        }
    }
}
