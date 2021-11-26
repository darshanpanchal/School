//
//  ChangePasswordViewController.swift
//  SchoolApp
//
//  Created by user on 14/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class ChangePasswordViewController: UIViewController {
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
    var heightOfChangePasswordTableViewCell:CGFloat{
        get{
            return 80.0
        }
    }
    var arrayOfUserDetail:[NSManagedObject] = []

    @IBOutlet var tableViewChangePassword:UITableView!
    @IBOutlet var butonSubmit:UIButton!
    
    var arrayOfChangePassword:[TextFieldDetail] = []
    var currentPasswordDetail:TextFieldDetail?
    var confirmPasswordDetail:TextFieldDetail?
    var newPasswordDetail:TextFieldDetail?
    let minPasswordLength:Int = 6
    let maxPasswordLength:Int = 15
    var currentPassword: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureTableView()
        
        self.configureChangePasswordView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonDrawerSelector(sender:UIButton){
        SideMenu.show()
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
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
    // MARK: - Custom Methods
    func configureChangePasswordView(){
        
        currentPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key: "genral.currentPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        newPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"genral.newPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        confirmPasswordDetail = TextFieldDetail.init(placeHolder:Vocabulary.getWordFromKey(key:"genral.confirmPassword"), text: "", keyboardType: .default, returnKey: .next, isSecure: true)
        self.arrayOfChangePassword = [currentPasswordDetail!,newPasswordDetail!,confirmPasswordDetail!]
        self.tableViewChangePassword.reloadData()
    }
    func configureTableView(){
        // self.tableViewChangePassword.tableHeaderView = self.tableViewHeaderView
        self.tableViewChangePassword.rowHeight = UITableView.automaticDimension
        self.tableViewChangePassword.estimatedRowHeight = 50.0
        self.tableViewChangePassword.delegate = self
        self.tableViewChangePassword.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewChangePassword.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewChangePassword.tableFooterView = self.tableViewFooterView
        self.tableViewChangePassword.separatorStyle = .none
        self.tableViewChangePassword.isScrollEnabled = false
        self.tableViewChangePassword.reloadData()
    }
    func setUpView(){
        self.butonSubmit.setTitleColor(UIColor.white, for: .normal)
        self.butonSubmit.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.butonSubmit.setTitle(Vocabulary.getWordFromKey(key: "genral.Submit"), for: .normal)
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.changepassword")
        self.lblTitle.font = CommonClass.shared.titleFont
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
            }
        }
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    // MARK: -Selector Methods
    @IBAction func buttonSubmitSelector(sender:UIButton){
        self.postChangePasswordAPI()
    }
    // MARK: - API Request Methods
    func postChangePasswordAPI(){
        if self.isValidChangePassword(){
            let currentUser: User = User.getUserFromUserDefault()!
            let userId: String = currentUser.userId
            let url = "users/updatePassword"
           
            let changeParameters =  ["user_id":"\(userId)","current_password":"\(currentPasswordDetail!.text)","new_password":"\(newPasswordDetail!.text)"]
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:url, parameter:changeParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any],let strMessage = success["message"]{
                    kUserDefault.set("\(self.newPasswordDetail!.text)", forKey: kUserPassword)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key: "ChangePassword"), message: "\(strMessage)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .default, handler: { (_) in
                            DispatchQueue.main.async {
                                if let nvc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                    if let dashBoardView = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController{
                                        nvc.pushViewController(dashBoardView, animated: false)
                                    }
                                }
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
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
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func isValidChangePassword()->Bool{
        if let value = kUserDefault.value(forKey: kUserPassword) {
            self.currentPassword = (value as? String)!
        }
        let currentPasswordCell:LogInTableViewCell = self.tableViewChangePassword.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let newPasswordCell:LogInTableViewCell = self.tableViewChangePassword.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
        let confirmPasswordCell:LogInTableViewCell = self.tableViewChangePassword.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! LogInTableViewCell
        
        guard currentPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                currentPasswordCell.textFieldLogIn.activeLineColor = .red
                currentPasswordCell.textFieldLogIn.lineColor = .red
                currentPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.enterCurrentPassword"))
            }
            return false
        }
//         guard currentPasswordDetail!.text == currentPassword else{
//         DispatchQueue.main.async {
//            currentPasswordCell.textFieldLogIn.activeLineColor = .red
//            currentPasswordCell.textFieldLogIn.lineColor = .red
//            currentPasswordCell.textFieldLogIn.invalideField()
//            ShowToast.show(toatMessage: "Current Password does not match")
//         }
//         return false
//         }
        guard newPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                newPasswordCell.textFieldLogIn.activeLineColor = .red
                newPasswordCell.textFieldLogIn.lineColor = .red
                newPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.enterNewPassword"))
            }
            return false
        }
        guard newPasswordDetail!.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                newPasswordCell.textFieldLogIn.activeLineColor = .red
                newPasswordCell.textFieldLogIn.lineColor = .red
                newPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.minimumpassword"))
                
            }
            return false
        }
        guard newPasswordDetail!.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                newPasswordCell.textFieldLogIn.activeLineColor = .red
                newPasswordCell.textFieldLogIn.lineColor = .red
                newPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.maximumpassword"))
                
                
            }
            return false
        }
        guard confirmPasswordDetail!.text.count > 0 else{
            DispatchQueue.main.async {
                confirmPasswordCell.textFieldLogIn.activeLineColor = .red
                confirmPasswordCell.textFieldLogIn.lineColor = .red
                confirmPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.enterConfirmPassword"))
            }
            return false
        }
        guard confirmPasswordDetail!.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                confirmPasswordCell.textFieldLogIn.activeLineColor = .red
                confirmPasswordCell.textFieldLogIn.lineColor = .red
                confirmPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.minimumpassword"))
            }
            return false
        }
        guard confirmPasswordDetail!.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                confirmPasswordCell.textFieldLogIn.activeLineColor = .red
                confirmPasswordCell.textFieldLogIn.lineColor = .red
                confirmPasswordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.maximumpassword"))
            }
            return false
        }
        guard confirmPasswordDetail!.text == newPasswordDetail!.text else{
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "confirmPasswordAsPassword"))
            }
            return false
        }
        guard currentPasswordDetail!.text != newPasswordDetail!.text else{
            DispatchQueue.main.async {
                //self.invalidTextField(textField: currentPasswordCell.textFieldLogIn)
                ShowToast.show(toatMessage: "Please enter new valid password.")
                
            }
            return false
        }
        currentPasswordCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")//.white
        currentPasswordCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        newPasswordCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
        newPasswordCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        confirmPasswordCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
        confirmPasswordCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        
        return true
    }
}
extension ChangePasswordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewProfile{
            return self.arrayOfUserDetail.count
        }else{
            return self.arrayOfChangePassword.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewChangePassword{
            let logInCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
            
            guard self.arrayOfChangePassword.count > indexPath.row else {
                return logInCell
            }
            
            
            logInCell.textFieldLogIn.tag = indexPath.row
            logInCell.textFieldLogIn.delegate = self
            logInCell.textFieldLogIn.tag = indexPath.row //+ 10
            let detail = arrayOfChangePassword[indexPath.row]
            logInCell.btnDropDown.tag = 101
            logInCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
            logInCell.textFieldLogIn.text = "\(detail.text)"
            logInCell.textFieldLogIn.keyboardType = detail.keyboardType
            logInCell.textFieldLogIn.returnKeyType = detail.returnKey
            logInCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
            logInCell.btnDropDown.isHidden = false
            //        logInCell.btnDropDown.isHidden = true
            logInCell.selectionStyle = .none
            DispatchQueue.main.async {
                if detail.text.count > 0{
                    logInCell.textFieldLogIn.minimizePlaceholder()
                }else{
                    logInCell.textFieldLogIn.maximizePlaceholder()
                }
            }
            logInCell.setTextFieldColor(textColor: UIColor.darkGray, placeHolderColor: kSchoolThemeColor)
            logInCell.textFieldLogIn.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
            
            return logInCell
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
        if tableView == self.tableViewProfile{
            return self.heightOfUserProfileTableViewCell
        }else{
            return self.heightOfChangePasswordTableViewCell
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
extension ChangePasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        let tag = textField.tag
        let detail = self.arrayOfChangePassword[tag]
        detail.text = "\(typpedString)"
       
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        let detail = self.arrayOfChangePassword[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
      
        
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      
            guard (self.arrayOfChangePassword.count) != textField.tag+1 else{
                textField.resignFirstResponder()
                  if self.isValidChangePassword(){
                    
                    //PostResetPasswordAPI
                    self.postChangePasswordAPI()
                    return true
                  }else{
                    return false
                }
            }
            self.view.viewWithTag(textField.tag+1)?.becomeFirstResponder()
//            textField.resignFirstResponder()
            return true
        
    }
    func updateActiveLine(textfield:TweeActiveTextField,color:UIColor){
        textfield.activeLineColor = color
        textfield.lineColor = color
    }
}
