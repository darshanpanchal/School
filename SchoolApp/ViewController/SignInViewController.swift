//
//  SignInViewController.swift
//  SchoolApp
//
//  Created by user on 12/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class TextFieldDetail{
    var placeHolder:String
    var minimumPlaceHolder:String
    var text:String
    var keyboardType:UIKeyboardType
    var returnKey:UIReturnKeyType
    var isSecure:Bool
    init(placeHolder: String,minimumPlaceHolder:String = "", text:String,keyboardType:UIKeyboardType,returnKey:UIReturnKeyType,isSecure:Bool){
        self.placeHolder = placeHolder
        self.minimumPlaceHolder = minimumPlaceHolder.count > 0 ? minimumPlaceHolder:placeHolder
        self.text = text
        self.keyboardType = .asciiCapable//keyboardType
        self.returnKey = returnKey
        self.isSecure = isSecure
    }
}

class SignInViewController: UIViewController {

    @IBOutlet var tableViewLogIn:UITableView!
    @IBOutlet var buttonSignIn:UIButton!
    @IBOutlet var buttonForgotPassWord:UIButton!
    var arrayOfLogInDetail:[TextFieldDetail] = []
    let heightOfTableViewCell:CGFloat = 80.0
    let kUserName:String = ""//"erp2"
    let kPassword:String = ""//"vidhya123"
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.white

        // Do any additional setup after loading the view.
        //setupview
        self.setUpView()
        //Configure LoginDetails
        self.configureLogInDetails(userEmail:kUserName, userPassword:kPassword)
        //Configure TableView
        self.configureTableView()
        
        //check for login
        self.checkForLogin()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        
    }
    // MARK: - Custom Methods
    func checkForLogin(){
        if User.isUserLoggedIn{
            DispatchQueue.main.async {
                self.pushToHomeViewController()
            }
        }
    }
    func setUpView(){
        self.buttonSignIn.backgroundColor = kSchoolThemeColor
        
        self.buttonForgotPassWord.setTitleColor(UIColor.white, for: .normal)
        self.buttonSignIn.setTitle(Vocabulary.getWordFromKey(key: "genral.go"), for: .normal)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.foregroundColor:kSchoolThemeColor] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: Vocabulary.getWordFromKey(key: "genral.forgotPassword"), attributes: underlineAttribute)
        self.buttonForgotPassWord.setAttributedTitle(underlineAttributedString, for: .normal)
        //self.buttonForgotPassWord.setTitle(Vocabulary.getWordFromKey(key: "genral.forgotPassword"), for: .normal)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(SignInViewController.tapDetected))
        self.view.addGestureRecognizer(singleTap)
        self.buttonForgotPassWord.imageView?.contentMode = .scaleAspectFit
    }
    @objc func tapDetected(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureTableView(){
        // self.tableViewLogIn.tableHeaderView = self.tableViewHeaderView
        self.tableViewLogIn.rowHeight = UITableView.automaticDimension
        self.tableViewLogIn.estimatedRowHeight = 50.0
        self.tableViewLogIn.delegate = self
        self.tableViewLogIn.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewLogIn.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewLogIn.tableFooterView = self.tableViewFooterView
        self.tableViewLogIn.separatorStyle = .none
        self.tableViewLogIn.isScrollEnabled = false
        self.tableViewLogIn.reloadData()
    }
    func configureLogInDetails(userEmail:String,userPassword:String){
        let emailDetail = TextFieldDetail.init(placeHolder: Vocabulary.getWordFromKey(key: "genral.username"), text: "\(userEmail)", keyboardType: .asciiCapable, returnKey: .next, isSecure: false)
        let passDetail = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "genral.password"), text: "\(userPassword)", keyboardType: .asciiCapable, returnKey: .done, isSecure: true)
        self.arrayOfLogInDetail = [emailDetail,passDetail]
        DispatchQueue.main.async {
            self.tableViewLogIn.reloadData()
        }
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonSignInSelector(sender:UIButton){

        self.postLogInAPIRequest()
    }
    @IBAction func buttonForgotPasswordSelector(sender:UIButton){
        self.pushToForGotPasswordView()
    }
    // MARK: - API Request Methods
    func removeUserIfAlreadyExist(userID:String,completionHandlar:()->()){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "userId = %@", "\(userID)")
        request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for data in result as! [NSManagedObject] {
                    context.delete(data)
                }
                completionHandlar()
            } catch {
                completionHandlar()
            }
        }
    }
    func addUserToDB(userData:[String:Any]){
        if let userID = userData["user_id"]{
            self.removeUserIfAlreadyExist(userID: "\(userID)") {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                    let context = appDelegate.persistentContainer.viewContext
                    if let objEntityDescription:NSEntityDescription = NSEntityDescription.entity(forEntityName: "Users", in: context){
                        let userCoreData:Users = Users.init(entity: objEntityDescription, insertInto: context)
                        if let userID = userData["user_id"]{
                            userCoreData.userId = "\(userID)"
                        }
                        if let studentID = userData["student_id"]{
                            userCoreData.student_id = "\(studentID)"
                        }
                        if let gr_no = userData["gr_no"]{
                            userCoreData.gr_no = "\(gr_no)"
                        }
                        if let roll_no = userData["roll_no"]{
                            userCoreData.roll_no = "\(roll_no)"
                        }
                        if let surname = userData["surname"]{
                            userCoreData.surname = "\(surname)"
                        }
                        if let student_name = userData["student_name"]{
                            userCoreData.student_name = "\(student_name)"
                        }
                        if let father_name = userData["father_name"]{
                            userCoreData.father_name = "\(father_name)"
                        }
                        if let gender = userData["gender"]{
                            userCoreData.gender = "\(gender)"
                        }
                        if let birth_date = userData["birth_date"]{
                            userCoreData.birth_date = "\(birth_date)"
                        }
                        if let phone_number1 = userData["phone_number1"]{
                            userCoreData.phone_number1 = "\(phone_number1)"
                        }
                        if let phone_number2 = userData["phone_number2"]{
                            userCoreData.phone_number2 = "\(phone_number2)"
                        }
                        if let email1 = userData["email1"]{
                            userCoreData.email1 = "\(email1)"
                        }
                        if let email2 = userData["email2"]{
                            userCoreData.email2 = "\(email2)"
                        }
                        if let student_photo = userData["student_photo"]{
                            userCoreData.student_photo = "\(student_photo)"
                        }
                        if let student_photo = userData["student_photo"]{
                            userCoreData.student_photo = "\(student_photo)"
                        }
                        if let current_address = userData["current_address"]{
                            userCoreData.current_address = "\(current_address)"
                        }
                        if let class_id = userData["class_id"]{
                            userCoreData.class_id = "\(class_id)"
                        }
                        if let class_name = userData["class_name"]{
                            userCoreData.class_name = "\(class_name)"
                        }
                        if let divison_name = userData["divison_name"]{
                            userCoreData.divison_name = "\(divison_name)"
                        }
                        if let teacher = userData["teacher"]{
                            userCoreData.teacher = "\(teacher)"
                        }
                        if let surname = userData["surname"],let student_name = userData["student_name"]{
                            userCoreData.username = "\(student_name) \(surname)"
                        }                     
                        
                        appDelegate.saveContext()
                    }
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
                    request.predicate = NSPredicate(format: "userId = %@", "\(userID)")
                    request.returnsObjectsAsFaults = false
                    do {
                        let result = try context.fetch(request)
                        
                        for data in result as! [NSManagedObject] {
                            let userName = data.value(forKey: "userId") as! String
                            print("\(userName)")
                        }
                    } catch {
                        print("Failed")
                    }
                }
            }
        }
    }
    func postLogInAPIRequest(){
        self.view.endEditing(true)
        if(self.isValidLogIn()){
            
            var logInParameters = ["username":"\(self.arrayOfLogInDetail[0].text)","password":"\(self.arrayOfLogInDetail[1].text)"]
            let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String
            print("**************\(deviceToken)**************")
            logInParameters["device_token"] = deviceToken
            logInParameters["device_type"] = "iOS"
            
            APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kLogInString, parameter:logInParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any]{
                    DispatchQueue.main.async {
                        APIRequestClient.shared.addUserToDB(userData: userInfo)
                        if let userID = userInfo["user_id"]{
                            APIRequestClient.shared.fetchUserDetailFromDataBase(userId: "\(userID)", userData: { (result) in
                                self.pushToHomeViewController()
                            })
                        }
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
    func pushToHomeViewController(){
        if let homeView = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController{
            self.navigationController?.pushViewController(homeView, animated: false)
        }
        
    }
    func pushToForGotPasswordView(){
        if let forgotPasswordView = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as? ForgotPasswordViewController{
            self.navigationController?.pushViewController(forgotPasswordView, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
  

}
extension SignInViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UIScreen.main.bounds.height*0.4
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayOfLogInDetail.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let logInCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        
        guard self.arrayOfLogInDetail.count > indexPath.row else {
            return logInCell
        }
        
        if indexPath.row == 1 {
            logInCell.trailingContainer.constant = 0
            logInCell.btnDropDown.isHidden = false
        } else {
            logInCell.trailingContainer.constant = -20
            logInCell.btnDropDown.isHidden = true
        }

        logInCell.tag = indexPath.row
        logInCell.textFieldLogIn.delegate = self
        logInCell.textFieldLogIn.tag = indexPath.row + 10
        let detail = arrayOfLogInDetail[indexPath.row]
        logInCell.btnDropDown.tag = 101
        logInCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
        logInCell.textFieldLogIn.text = "\(detail.text)"
        logInCell.textFieldLogIn.keyboardType = detail.keyboardType
        logInCell.textFieldLogIn.returnKeyType = detail.returnKey
        logInCell.textFieldLogIn.isSecureTextEntry = detail.isSecure
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
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightOfTableViewCell
    }
    
}
extension SignInViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        let tag = textField.tag - 10
        let detail = arrayOfLogInDetail[tag]
        detail.text = "\(typpedString)"
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 11{
            DispatchQueue.main.async {
                //self.tableViewLogIn.setContentOffset(CGPoint(x: 0,y :140), animated: true)
            }
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 11{
            DispatchQueue.main.async {
               // self.tableViewLogIn.setContentOffset(CGPoint(x: 0,y :0), animated: false)
            }
        }
        return true
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let tag = textField.tag - 10
        let detail = arrayOfLogInDetail[tag]
        detail.text = ""
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 10 { //Email
            let email:TextFieldDetail = arrayOfLogInDetail[0]
            /*
            if(!email.text.isValidEmail()){
                DispatchQueue.main.async {
                    (textField as! TweeActiveTextField).activeLineColor = .red
                    (textField as! TweeActiveTextField).lineColor = .red
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
                    textField.invalideField()
                }
            }else{
                (textField as! TweeActiveTextField).activeLineColor = UIColor.init(hexString:"C8C7CC")///.white
                (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
                textField.setBorder(color: .clear)
                self.view.viewWithTag(11)?.becomeFirstResponder()
            }*/
            (textField as! TweeActiveTextField).activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
            (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
            textField.setBorder(color: .clear)
            self.view.viewWithTag(11)?.becomeFirstResponder()
        }else if textField.tag == 11{ //Password
            //PostLogInRequest
            self.postLogInAPIRequest()
        }else{
            (textField as! TweeActiveTextField).activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
            (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
            textField.setBorder(color: .clear)
        }
        return true
    }
    func isValidLogIn()->Bool{
        let minPasswordLength:Int = 6
        let maxPasswordLength:Int = 15
        let email:TextFieldDetail = arrayOfLogInDetail[0]
        let password:TextFieldDetail = arrayOfLogInDetail[1]
        
        let emailCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let passwordCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
        guard email.text.count > 0 else{
            DispatchQueue.main.async {
                emailCell.textFieldLogIn.activeLineColor = .red
                emailCell.textFieldLogIn.lineColor = .red
                emailCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.enterUserName"))
            }
            return false
        }
        /*
        guard email.text.isValidEmail() else{
            DispatchQueue.main.async {
                emailCell.textFieldLogIn.activeLineColor = .red
                emailCell.textFieldLogIn.lineColor = .red
                emailCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "pleaseEnterValidEmail.title"))
            }
            return false
        }*/
        guard password.text.count > 0 else{
            DispatchQueue.main.async {
                passwordCell.textFieldLogIn.activeLineColor = .red
                passwordCell.textFieldLogIn.lineColor = .red
                passwordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.enterPassword"))
            }
            return false
        }
        guard password.text.count >= minPasswordLength else{
            DispatchQueue.main.async {
                passwordCell.textFieldLogIn.activeLineColor = .red
                passwordCell.textFieldLogIn.lineColor = .red
                passwordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.minimumpassword"))
            }
            return false
        }
        guard password.text.count <= maxPasswordLength else{
            DispatchQueue.main.async {
                passwordCell.textFieldLogIn.activeLineColor = .red
                passwordCell.textFieldLogIn.lineColor = .red
                passwordCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.maximumpassword"))
            }
            return false
        }
        emailCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")//.white
        emailCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        passwordCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
        passwordCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        return true
    }
}
