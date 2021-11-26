//
//  PTMViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class PTMViewController: UIViewController {
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
    var currentPage:Int = 0
    
    var isLoadMorePTM:Bool = false
    var arrayOfPTM:[PTMDetail] = []
    @IBOutlet var tableViewPTM:UITableView!
    
    var refreshControl = UIRefreshControl()
    var isPullToRefresh:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configurePTMTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getStudentPTMAPIRequest(userID: user.userId)
        }
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.ptm")
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
    func configurePTMTableView(){
        // self.tableViewPTM.tableHeaderView = self.tableViewHeaderView
        self.tableViewPTM.rowHeight = UITableView.automaticDimension
        self.tableViewPTM.estimatedRowHeight = 100.0
        self.tableViewPTM.delegate = self
        self.tableViewPTM.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "PTMTableViewCell", bundle: nil)
        self.tableViewPTM.register(objNib, forCellReuseIdentifier: "PTMTableViewCell")
        self.tableViewPTM.separatorStyle = .none
        self.tableViewPTM.isScrollEnabled = true
        self.tableViewPTM.tableFooterView = UIView()
        self.tableViewPTM.tableHeaderView = UIView()
        self.tableViewPTM.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewPTM.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        self.isPullToRefresh = true
        self.refreshControl.endRefreshing()
        // Code to refresh table view
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getStudentPTMAPIRequest(userID: user.userId)
            }
        }
    }
    // MARK: - API Request Methods
    func getStudentPTMAPIRequest(userID:String){
        let leaveParameters = ["user_id":"\(userID)","page":"\(currentPage)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentPTM, parameter:leaveParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayPTM = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfPTM.removeAll()
                }
                self.isLoadMorePTM = arrayPTM.count > 0
                for var objPTM:[String:Any] in arrayPTM{
                    objPTM.updateJSONNullToString()
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objPTM, options:.prettyPrinted)
                        if let objPTMDetail = try? JSONDecoder().decode(PTMDetail.self, from: jsondata){
                            self.arrayOfPTM.append(objPTMDetail)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewPTM.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    guard !"\(errorMessage)".contains("No ptm available.") else {
                        print(self.arrayOfPTM.count)
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension PTMViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewPTM{
            if self.arrayOfPTM.count == 0{
                tableView.showMessageLabel(msg: "No PTM available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfPTM.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewPTM{
            let ptmCell:PTMTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PTMTableViewCell", for: indexPath) as! PTMTableViewCell
            let objPTM = self.arrayOfPTM[indexPath.row]
            ptmCell.objStatusIndication.backgroundColor = objPTM.status == "1" ? UIColor.green : UIColor.red
            ptmCell.lblPTMDate.text =   "PTM Date \t: \(objPTM.ptmDate.changeDateFormateddMMYYYY)"
            ptmCell.lblAttender.text =  "Attender \t: \(objPTM.attendBy)"
            ptmCell.lblPTMDetail.text = "Detail   \t: \(objPTM.detail)"
            if indexPath.row+1 == self.arrayOfPTM.count, self.isLoadMorePTM{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getStudentPTMAPIRequest(userID: user.userId)
                    }
                }
            }
            ptmCell.selectionStyle = .none
            return ptmCell
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
        if tableView == self.tableViewPTM{
            return UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         if tableView == self.tableViewPTM{
            
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
struct PTMDetail:Codable{
    var id,ptmDate, attendBy, status,detail: String
    
    enum CodingKeys: String, CodingKey {
        case id = "ptm_id"
        case ptmDate = "ptm_date"
        case attendBy = "attend_by"
        case status
        case detail
    }
    init(from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.ptmDate = try values.decodeIfPresent(String.self, forKey: .ptmDate) ?? ""
        self.attendBy = try values.decodeIfPresent(String.self, forKey: .attendBy) ?? ""
        self.status = try values.decodeIfPresent(String.self, forKey: .status) ?? ""
        self.detail = try values.decodeIfPresent(String.self, forKey: .detail) ?? ""

    }
}
