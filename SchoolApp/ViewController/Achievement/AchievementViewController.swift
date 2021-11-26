//
//  AchievementViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class AchievementViewController: UIViewController {
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
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    @IBOutlet var tableViewAttachment:UITableView!
    
    var refreshControl = UIRefreshControl()
    var isPullToRefresh:Bool = false
    
    var arrayOfAchievement:[Achievement] = []
    var currentPage:Int = 0
    var isLoadMoreAchievement:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureAchievementTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getAchievementAPIRequest(userID: user.userId)
        }
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.achievment")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
    func configureAchievementTableView(){
        // self.tableViewAttachment.tableHeaderView = self.tableViewHeaderView
        self.tableViewAttachment.rowHeight = UITableView.automaticDimension
        self.tableViewAttachment.estimatedRowHeight = 100.0
        self.tableViewAttachment.delegate = self
        self.tableViewAttachment.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewAttachment.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewAttachment.separatorStyle = .none
        self.tableViewAttachment.isScrollEnabled = true
        self.tableViewAttachment.reloadData()
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewAttachment.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        DispatchQueue.main.async {
            self.isPullToRefresh = true
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                // Code to refresh table view
                DispatchQueue.global(qos: .background).async {
                    self.currentPage = 0
                    if let user = User.getUserFromUserDefault(){
                        self.getAchievementAPIRequest(userID: user.userId)
                    }
                }
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
    // MARK: - API Request Methods
    func getAchievementAPIRequest(userID:String){
        let achievementParameters:[String:Any] = ["user_id":"\(userID)","page":"\(currentPage)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentAchievement, parameter:achievementParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayAchievement = success["data"] as? [[String:Any]]{
                if self.currentPage == 0{
                    self.arrayOfAchievement.removeAll()
                }
                self.isLoadMoreAchievement = arrayAchievement.count > 0
                self.arrayOfAchievement.removeAll()
                for var objAchievement:[String:Any] in arrayAchievement{
                    objAchievement.updateJSONNullToString()
                    do {
                         let jsondata = try JSONSerialization.data(withJSONObject:objAchievement, options:.prettyPrinted)
                        if let achievementData = try? JSONDecoder().decode(Achievement.self, from: jsondata){
                            self.arrayOfAchievement.append(achievementData)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewAttachment.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                guard !"\(errorMessage)".contains("No achievements available.") else {
                    print(self.arrayOfAchievement.count)
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
    
    // MARK: - Navigation
    //push to achievement detial
    func pushToAchievementDetail(objAchievement:Achievement){
        if let achievementDetail:NoticeDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "NoticeDetailViewController") as? NoticeDetailViewController{
            achievementDetail.isForAcheivemnt = true
            achievementDetail.objAchievement = objAchievement
            self.navigationController?.pushViewController(achievementDetail, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension AchievementViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewAttachment{
            if self.arrayOfAchievement.count == 0{
                tableView.showMessageLabel(msg: "No achievements available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfAchievement.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewAttachment{
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let objAchievment:Achievement = self.arrayOfAchievement[indexPath.row]
            
            let achirvement = NSMutableAttributedString.init(string: "\n\(Vocabulary.getWordFromKey(key: "genral.achievment")) :  ", attributes: self.attributesBold)
            let achirvementValue = NSMutableAttributedString.init(string: " \(objAchievment.activityName)", attributes: self.attributesNormal)
            
            let desc = NSMutableAttributedString.init(string: "\n\nPositions : ", attributes: self.attributesBold)
            let descValue = NSMutableAttributedString.init(string: "\(objAchievment.positionName)\n", attributes: self.attributesNormal)
            
            achirvement.append(achirvementValue)
            achirvement.append(desc)
            achirvement.append(descValue)
            homeworkCell.lblHomeWorkDetail.attributedText = achirvement
            /*
            "\(Vocabulary.getWordFromKey(key: "genral.achievment")) : \(objAchievment.activityName)\n\(Vocabulary.getWordFromKey(key:"Positions")) : \(objAchievment.positionName)"*/
            
            homeworkCell.lblHomeWorkDate.text = objAchievment.achievementDate.changeDateFormateddMMYYYY
            homeworkCell.shadowView.isHidden = false
            homeworkCell.separatorInset = UIEdgeInsets.zero
            homeworkCell.layoutMargins = UIEdgeInsets.zero
            
            homeworkCell.attachMentImageView.isHidden = true//!(objAchievment.attachment.count > 0)

            if indexPath.row+1 == self.arrayOfAchievement.count, self.isLoadMoreAchievement{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getAchievementAPIRequest(userID: user.userId)
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
        if tableView == self.tableViewAttachment{
            let objAchievment:Achievement = self.arrayOfAchievement[indexPath.row]
            
            let achirvement = NSMutableAttributedString.init(string: "\n\(Vocabulary.getWordFromKey(key: "genral.achievment")) :  ", attributes: self.attributesBold)
            let achirvementValue = NSMutableAttributedString.init(string: " \(objAchievment.activityName)", attributes: self.attributesNormal)
            
            let desc = NSMutableAttributedString.init(string: "\n\nPositions : ", attributes: self.attributesBold)
            let descValue = NSMutableAttributedString.init(string: "\(objAchievment.positionName)\n", attributes: self.attributesNormal)
            
            achirvement.append(achirvementValue)
            achirvement.append(desc)
            achirvement.append(descValue)
            return  (achirvement.string.count > 250) ? 250.0:UITableView.automaticDimension//UITableView.automaticDimension//UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewAttachment{
            //pushToAchievement Detail
            if self.arrayOfAchievement.count > indexPath.row{
                self.pushToAchievementDetail(objAchievement: self.arrayOfAchievement[indexPath.row])
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
struct Achievement: Codable {
    let activityName, positionName, achievementDate: String
    
    enum CodingKeys: String, CodingKey {
        case activityName = "activity_name"
        case positionName = "position_name"
        case achievementDate = "achievement_date"
    }
    init(from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.activityName = try values.decodeIfPresent(String.self, forKey: .activityName) ?? ""
        self.positionName = try values.decodeIfPresent(String.self, forKey: .positionName) ?? ""
        self.achievementDate = try values.decodeIfPresent(String.self, forKey: .achievementDate) ?? ""
    }
}
