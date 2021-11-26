//
//  FeesViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class FeesViewController: UIViewController {
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
    var strGraphURL:String = ""
    @IBOutlet var tableViewFees:UITableView!
    @IBOutlet var buttonViewFeesGraph:UIButton!
    @IBOutlet var lblFeesDetail:UILabel!
    
    
    var arrayOfFees:[String] = ["\(Date().mmddyyyy)","\(Date().mmddyyyy)"]
    var arrayOfFeesDetail:[String] = ["Total Fees : ","Paid Fees : ","Remain Fees : "]
    var arrayOfStudentFees:[StudentFees] = []
    var selectedSet:NSMutableSet = NSMutableSet()
    override func viewDidLoad() {
        super.viewDidLoad()

        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()

        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            //get fees API request
            self.getFeesDetailAPIRequest(userID: user.userId)
        }
        //configure feesTableView
        self.configureFeesTableView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.fees")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonViewFeesGraph.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonViewFeesGraph.setTitleColor(UIColor.white, for: .normal)
        self.buttonViewFeesGraph.clipsToBounds = true
        self.buttonViewFeesGraph.layer.cornerRadius = 10.0
        self.lblFeesDetail.textColor = kSchoolThemeColor
        self.lblFeesDetail.text = "Fees status on \(Date().ddMMyyyy)"
        self.buttonViewFeesGraph.setTitle(Vocabulary.getWordFromKey(key: "genral.ViewFeesGraph"), for: .normal)
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
    func configureFeesTableView(){
        self.tableViewFees.separatorStyle = .none
        self.tableViewFees.delegate = self
        self.tableViewFees.dataSource = self
        self.tableViewFees.reloadData()
    }
    // MARK: - API  Methods
    func getFeesDetailAPIRequest(userID:String){
        let leaveParameters = ["user_id":"\(userID)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentFees, parameter:leaveParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayFees = success["data"] as? [[String:Any]],let strURL = success["chart_url"]{
                self.strGraphURL = "\(strURL)"
                self.arrayOfStudentFees.removeAll()
                for var objFees:[String:Any] in arrayFees{
                    objFees.updateJSONNullToString()
                    
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objFees, options:.prettyPrinted)
                        if let fees = try? JSONDecoder().decode(StudentFees.self, from: jsondata){
                            self.arrayOfStudentFees.append(fees)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewFees.reloadData()
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
    @IBAction func buttonViewFeesGraphSelector(sender:UIButton){
        self.pushToFeesDetailView()
    }
    func pushToFeesDetailView(){
        if let feesDetail = self.storyboard?.instantiateViewController(withIdentifier: "FeesDetailViewController") as? FeesDetailViewController{
            feesDetail.strGraphURL = self.strGraphURL
            self.navigationController?.pushViewController(feesDetail, animated: true)
        }
        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension FeesViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == tableViewFees{
            return self.arrayOfStudentFees.count
        }else{
            return 1
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewFees{
            if self.selectedSet.contains(section){
                return 0
            }else{
                return self.arrayOfFeesDetail.count
            }
        }else{
            return self.arrayOfUserDetail.count
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableViewFees{
            
            let headerView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: tableView.bounds.width, height: 36.0)))
            headerView.clipsToBounds = true
            headerView.layer.cornerRadius = 10.0
            headerView.backgroundColor = kSchoolThemeColor
            let objImageView = UIImageView.init(frame: CGRect.init(x: 10, y: 5, width: 25, height: 25))
            headerView.addSubview(objImageView)
            let lblHeder = UILabel.init(frame: CGRect.init(x: 50, y: 3, width: tableView.bounds.width-50.0, height: 30.0))
            lblHeder.textColor = UIColor.white
            lblHeder.text = self.arrayOfStudentFees[section].feesType
            headerView.addSubview(lblHeder)
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(FeesViewController.tapDetected))
            headerView.tag = section
            headerView.addGestureRecognizer(singleTap)
            let containerView = UIView.init(frame: CGRect.init(x: 0, y: 2, width: tableView.bounds.width, height: 36.0))
            containerView.addSubview(headerView)
            if !self.selectedSet.contains(section){
               objImageView.image = UIImage.init(named: "ic_arrow_up")
            }else{
               objImageView.image = UIImage.init(named: "ic_arrow_down")
            }
            objImageView.backgroundColor = UIColor.clear
            objImageView.contentMode = .scaleAspectFit
            return containerView
        }else{
            return nil
        }
    }
    @objc func tapDetected(sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        if self.selectedSet.contains(tag){
            self.selectedSet.remove(tag)
        }else{
            self.selectedSet.add(tag)
        }
        DispatchQueue.main.async {
            self.tableViewFees.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewFees{
            let cell:UITableViewCell = UITableViewCell()
            let objStudentFees = self.arrayOfStudentFees[indexPath.section]
                var strFees = ""
                if indexPath.row == 0{
                     strFees = "\(objStudentFees.totalFees)"
                }else if indexPath.row == 1{
                    strFees = "\(objStudentFees.paidFees)"
                }else{
                    strFees = "\(objStudentFees.remainingFees)"
                }
            cell.textLabel?.text = self.arrayOfFeesDetail[indexPath.row] + "\(strFees)"
            cell.selectionStyle = .none
            return cell
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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableViewFees{
            return 40.0
        }else{
            return 0.0
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewFees{
            return 30.0
        }else{
            return self.heightOfUserProfileTableViewCell

        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableView != self.tableViewFees else {
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

struct StudentFees: Codable {
    let studentID, feesType, reason : String
    let totalFees, paidFees, remainingFees: Int
    
    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case feesType = "fees_type"
        case reason
        case totalFees = "total_fees"
        case paidFees = "paid_fees"
        case remainingFees = "remaining_fees"
    }
    init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.studentID = try values.decodeIfPresent(String.self, forKey: .studentID) ?? ""
        self.feesType = try values.decodeIfPresent(String.self, forKey: .feesType) ?? ""
        self.reason = try values.decodeIfPresent(String.self, forKey: .reason) ?? ""
        self.totalFees = try values.decodeIfPresent(Int.self, forKey: .totalFees) ?? 0
        self.paidFees = try values.decodeIfPresent(Int.self, forKey: .paidFees) ?? 0
        self.remainingFees = try values.decodeIfPresent(Int.self, forKey: .remainingFees) ?? 0
    }
}
