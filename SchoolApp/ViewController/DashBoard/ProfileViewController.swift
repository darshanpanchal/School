//
//  ProfileViewController.swift
//  SchoolApp
//
//  Created by user on 14/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices

class ProfileViewController: UIViewController {
    //Navigation
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewProfile:UITableView!
    @IBOutlet var tableViewHeight:NSLayoutConstraint!
    @IBOutlet var buttonDropDown:UIButton!

    //user images
    @IBOutlet var userBlurImage:UIImageView!
    @IBOutlet var userImage:RoundButton!
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var tableViewUserProfileDetail:UITableView!

    
    var heightOfTableViewCell:CGFloat{
        get{
            return 50.0
        }
    }
    var arrayOfUserDetail:[NSManagedObject] = []
    var arrayOfUserProfile:[String] = ["GR NO :","Class :","Gender :","Class Teacher :","Birthday :","Mobile :","Email Id :","Address :"]
    var arrayOfUserProfilDetail:[String] = []//["GR NO :","Class :","Gender :","Class Teacher :","Birthday :","Mobile :","Email Id :","Address :"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
        //user profile tableview
        self.configureProfileTableView()
        
        
        
        self.configureUserProfileDetailTableView()
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
        }
        APIRequestClient.shared.fetchAllUserDetailFromDataBase{ (response) in
            self.arrayOfUserDetail = response
            self.tableViewProfile.reloadData()
            self.buttonUserProfile.isEnabled = self.arrayOfUserDetail.count > 0
            self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.mypofile")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.userBlurImage.blurImage()
        self.userImage.layoutIfNeeded()
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
    //configure user profile
    func configureProfileTableView(){
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    
    func configureUserProfileDetailTableView(){
        self.tableViewUserProfileDetail.rowHeight = UITableView.automaticDimension
        self.tableViewUserProfileDetail.estimatedRowHeight = 100.0
        self.tableViewUserProfileDetail.delegate = self
        self.tableViewUserProfileDetail.dataSource = self
        self.tableViewUserProfileDetail.isScrollEnabled = true
        self.tableViewUserProfileDetail.reloadData()
    }
    func configureCurrentUserDetail(userID:String){
        
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: userID) { (response) in
            if let objUserCoreData:Users =  response as? Users{
                self.lblUserName.text = objUserCoreData.username
                self.arrayOfUserProfilDetail.append(objUserCoreData.gr_no ?? "")
                if let classname = objUserCoreData.class_name,let divisionname = objUserCoreData.divison_name{
                    let bothStr = classname + " " + "-" + " " + divisionname
                    self.arrayOfUserProfilDetail.append(bothStr)
                }
                self.arrayOfUserProfilDetail.append(objUserCoreData.gender ?? "")
                self.arrayOfUserProfilDetail.append(objUserCoreData.teacher ?? "")
                self.arrayOfUserProfilDetail.append(objUserCoreData.birth_date ?? "")
                self.arrayOfUserProfilDetail.append(objUserCoreData.phone_number1 ?? "")
                self.arrayOfUserProfilDetail.append(objUserCoreData.email1 ?? "")
                self.arrayOfUserProfilDetail.append(objUserCoreData.current_address ?? "")
                
                if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
                    self.userBlurImage.sd_setImage(with: objURl, placeholderImage:UIImage.init(named:"ic_user_profile"))
                    self.userImage.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                    self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                }else{
                    self.userBlurImage.image = UIImage.init(named:"ic_user_profile")
                    self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal)
                    self.userImage.setBackgroundImage(UIImage.init(named:"ic_user_profile"), for: .normal)
                }
                DispatchQueue.main.async {
                    self.tableViewProfile.reloadData()
                }
            }
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonDrawerSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
//        SideMenu.show()
    }
    @IBAction func buttonProfileNavigationSelector(sender:UIButton){
//        self.documentPicker()
        if self.arrayOfUserDetail.count > 0{
            UIView.animate(withDuration: 0.3) {
                if self.tableViewHeight.constant == 0{
                    self.tableViewHeight.constant = CGFloat(self.arrayOfUserDetail.count) * self.heightOfTableViewCell
                }else{
                    self.tableViewHeight.constant = 0
                }
            }
        }
    }
    func documentPicker(){
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
extension ProfileViewController:UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
    }
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("documentPickerWasCancelled")
    }
}
extension ProfileViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewUserProfileDetail{
            return self.arrayOfUserProfile.count
        }else{
            return self.arrayOfUserDetail.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewUserProfileDetail{
            let profileDetailCell:UserProfileDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserProfileDetailTableViewCell", for: indexPath) as! UserProfileDetailTableViewCell
             profileDetailCell.lblUserProfile.text = self.arrayOfUserProfile[indexPath.row]
//            if self.arrayOfUserProfilDetail.count == indexPath.row+1{
//                profileDetailCell.lblUserProfileDetail.text = "905, Pinnacle Business Park, Corporate Rd, Prahlad Nagar, Ahmedabad, Gujarat 380015"//self.arrayOfUserProfile[indexPath.row]
//            }else{
//
//            }
            if self.arrayOfUserProfilDetail.count > indexPath.row{
                profileDetailCell.lblUserProfileDetail.text = self.arrayOfUserProfilDetail[indexPath.row]
            }
            profileDetailCell.backgroundColor = UIColor.white
            return profileDetailCell
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
        if tableView == self.tableViewUserProfileDetail{
            return UITableView.automaticDimension
        }else{
            return self.heightOfTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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

