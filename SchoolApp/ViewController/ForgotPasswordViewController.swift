//
//  ForgotPasswordViewController.swift
//  SchoolApp
//
//  Created by user on 12/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet var tableViewForgotPassword:UITableView!
    @IBOutlet var buttonForgotPassword:UIButton!
    @IBOutlet var buttonBackToLogIn:UIButton!
    
    var arrayOfLogInDetail:[TextFieldDetail] = []
    let heightOfTableViewCell:CGFloat = 80.0
    
    var schoolPicker:UIPickerView = UIPickerView.init()
    var schoolPickerToolBar:UIToolbar = UIToolbar()
    var classPicker :UIPickerView = UIPickerView.init()
    var classPickerToolBar:UIToolbar = UIToolbar()
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    var currentSchool:SchoolClass?
    var currentClas:SchoolClass?
    var isKeyboardOpen:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.white

        //setUp View
        self.setUpView()
        //Configure tableview
        self.configureTableView()
        //Confg=igurelogin detail
        self.configureLogInDetails(userEmail:"", userPassword:"")
        self.configureSchoolPicker()
        self.configureSchoolPickerToolBar()
        self.configureClassPicker()
        self.configureClassPickerToolBar()
        // Do any additional setup after loading the view.
//        get school API Request
        self.getSchoolAPIRequest()
        //get Class API Request
//        self.getClassAPIRequest()
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.buttonForgotPassword.backgroundColor = kSchoolThemeColor
        
        self.buttonForgotPassword.setTitle(Vocabulary.getWordFromKey(key: "genral.go"), for: .normal)
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,NSAttributedString.Key.foregroundColor:kSchoolThemeColor] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: Vocabulary.getWordFromKey(key: "genral.backToLogin"), attributes: underlineAttribute)
        self.buttonBackToLogIn.setAttributedTitle(underlineAttributedString, for: .normal)
        //self.buttonForgotPassWord.setTitle(Vocabulary.getWordFromKey(key: "genral.forgotPassword"), for: .normal)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.tapDetected))
        self.view.addGestureRecognizer(singleTap)
     
        
    }
    
    @objc func tapDetected(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func isValidForgotPassword()->Bool{
        let schoolTextField:TextFieldDetail = arrayOfLogInDetail[0]
        let classTextField:TextFieldDetail = arrayOfLogInDetail[1]
        let mobileTextField:TextFieldDetail = arrayOfLogInDetail[2]
        
//        let schoolCell:LogInTableViewCell = self.tableViewForgotPassword.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let classCell:LogInTableViewCell = self.tableViewForgotPassword.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
        let mobileCell:LogInTableViewCell = self.tableViewForgotPassword.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! LogInTableViewCell
        
//        guard schoolTextField.text.count > 0 else{
//            DispatchQueue.main.async {
//                schoolCell.textFieldLogIn.activeLineColor = .red
//                schoolCell.textFieldLogIn.lineColor = .red
//                schoolCell.textFieldLogIn.invalideField()
//                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.SelectSchool"))
//            }
//            return false
//        }
        guard classTextField.text.count > 0 else{
            DispatchQueue.main.async {
                classCell.textFieldLogIn.activeLineColor = .red
                classCell.textFieldLogIn.lineColor = .red
                classCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.SelectClass"))
            }
            return false
        }
        guard mobileTextField.text.count > 0,self.isValidPhone(phone: mobileTextField.text) else{
            DispatchQueue.main.async {
                mobileCell.textFieldLogIn.activeLineColor = .red
                mobileCell.textFieldLogIn.lineColor = .red
                mobileCell.textFieldLogIn.invalideField()
                ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.mobilenumeber"))
            }
            return false
        }
//        schoolCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")//.white
//        schoolCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        classCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
        classCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        mobileCell.textFieldLogIn.activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
        mobileCell.textFieldLogIn.lineColor = UIColor.init(hexString:"C8C7CC")///.white
        return true
    }
    func isValidPhone(phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: phone)
    }
    func configureLogInDetails(userEmail:String,userPassword:String){
        let schoolDetail = TextFieldDetail.init(placeHolder: Vocabulary.getWordFromKey(key: "genral.School"), text: "\(userEmail)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
        let classDetail = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "genral.Class"), text: "\(userPassword)", keyboardType: .default, returnKey: .done, isSecure: false)
        let mobileNumber = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "genral.MobileNumber"), text: "\(userPassword)", keyboardType: .phonePad, returnKey: .done, isSecure: false)
        self.arrayOfLogInDetail = [schoolDetail,classDetail,mobileNumber]
        DispatchQueue.main.async {
            self.tableViewForgotPassword.reloadData()
        }
        
    }
    func configureTableView(){
        self.tableViewForgotPassword.rowHeight = UITableView.automaticDimension
        self.tableViewForgotPassword.estimatedRowHeight = 50.0
        self.tableViewForgotPassword.delegate = self
        self.tableViewForgotPassword.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "LogInTableViewCell", bundle: nil)
        self.tableViewForgotPassword.register(objNib, forCellReuseIdentifier: "LogInTableViewCell")
        // self.tableViewForgotPassword.tableFooterView = self.tableViewFooterView
        self.tableViewForgotPassword.separatorStyle = .none
        self.tableViewForgotPassword.isScrollEnabled = false
        self.tableViewForgotPassword.reloadData()
    }
    func configureSchoolPicker(){
        self.schoolPicker.delegate = self
        self.schoolPicker.dataSource = self
    }
    func configureSchoolPickerToolBar(){
        self.schoolPickerToolBar.sizeToFit()
        self.schoolPickerToolBar.layer.borderColor = UIColor.lightGray.cgColor
        self.schoolPickerToolBar.layer.borderWidth = 0.5
        self.schoolPickerToolBar.clipsToBounds = true
        self.schoolPickerToolBar.backgroundColor = kSchoolThemeColor
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"genral.Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ForgotPasswordViewController.doneSchoolPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.font = UIFont(name: "Avenir-Heavy", size: 15.0)
        title.text = "\(Vocabulary.getWordFromKey(key:"genral.School"))"
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"genral.Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ForgotPasswordViewController.cancelSchoolPicker))
        self.schoolPickerToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func doneSchoolPicker(){
        if let first = self.arrayOfLogInDetail.first{
            if let _ = self.currentSchool{
                first.text = self.currentSchool!.strName
            }
            self.tableViewForgotPassword.reloadData()
        }
    }
    @objc func cancelSchoolPicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureClassPicker(){
        self.classPicker.delegate = self
        self.classPicker.dataSource = self
    }
    func configureClassPickerToolBar(){
        self.classPickerToolBar.sizeToFit()
        self.classPickerToolBar.layer.borderColor = UIColor.lightGray.cgColor
        self.classPickerToolBar.layer.borderWidth = 0.5
        self.classPickerToolBar.clipsToBounds = true
        self.classPickerToolBar.backgroundColor = kSchoolThemeColor
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"genral.Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ForgotPasswordViewController.doneClassPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let title = UILabel.init()
        title.font = UIFont(name: "Avenir-Heavy", size: 15.0)
        title.text = "\(Vocabulary.getWordFromKey(key:"Class"))"
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"genral.Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ForgotPasswordViewController.cancelClassPicker))
        self.classPickerToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
    }
    @objc func doneClassPicker(){
            let classObj = self.arrayOfLogInDetail[1]
            if let _ = self.currentClas{
                classObj.text = self.currentClas!.strName
            }
            self.tableViewForgotPassword.reloadData()
    }
    @objc func cancelClassPicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackToLogInSelector(sender:UIButton){
//        self.pushToSearchViewController()
        self.navigationController?.popViewController(animated: true)
    }
    func pushToSearchViewController(){
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = .SchoolClass
                schoolClassPicker.arrayclassOptions = self.classOptions
                self.view.endEditing(true)
                
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        
    }
    @IBAction func buttonForgotPasswordSelector(sender:UIButton){
        self.postForgotPasswordAPIRequest()
//        self.pushToDashBoard()
    }
    
    // MARK: - API Request Methods
    func getClassAPIRequest(){
        var classParameters:[String:Any] = [:]
        if  self.schoolOptions.count > 0{
            classParameters["school_id"] = self.schoolOptions.first!.strClassId
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetClass, parameter:classParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfClasses = success["data"] as? [[String:Any]]{
                self.classOptions.removeAll()
                for objClass in arrayOfClasses{
                    if let name = objClass["name"],let classID = objClass["class_id"],let teacherID = objClass["teacher_id"]{
                        self.classOptions.append(SchoolClass.init(strClassId: "\(classID)", strTeacherId: "\(teacherID)", strName: "\(name)"))
                    }
                }
                DispatchQueue.main.async {
                    if self.classOptions.count > 0{
                        self.currentClas = self.classOptions.first!
                    }
                    self.classPicker.reloadAllComponents()
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
    func getSchoolAPIRequest(){
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kGetSchool, parameter:nil,isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfSchools = success["data"] as? [[String:Any]]{
                self.schoolOptions.removeAll()
                for objSchool in arrayOfSchools{
                    if let name = objSchool["school_name"],let classID = objSchool["school_id"]{
                        
                        self.schoolOptions.append(SchoolClass.init(strClassId: "\(classID)", strTeacherId: "", strName: "\(name)"))
                    }
                }
                DispatchQueue.main.async {
                    self.getClassAPIRequest()
                    self.schoolPicker.reloadAllComponents()
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
    func validate(value: String) -> Bool {
        
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: value)
        /*
        let PHONE_REGEX = "^\\d{3}-\\d{3}-\\d{4}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
 */
    }
    func postForgotPasswordAPIRequest(){
        if self.isValidForgotPassword(){
            var classID:String = ""
            var schoolID:String = ""
            if let _ = self.currentClas{
                 classID = self.currentClas!.strClassId
            }
            if let _ = self.currentSchool{
                schoolID = self.currentSchool!.strClassId
            }
          
            guard self.validate(value:"\(self.arrayOfLogInDetail[2].text)") && Int("\(self.arrayOfLogInDetail[2].text)") != 0  else{
                DispatchQueue.main.async {
                    let mobileCell:LogInTableViewCell = self.tableViewForgotPassword.cellForRow(at: IndexPath.init(row: 2, section: 0)) as! LogInTableViewCell
                    mobileCell.textFieldLogIn.activeLineColor = .red
                    mobileCell.textFieldLogIn.lineColor = .red
                    mobileCell.textFieldLogIn.invalideField()
                    ShowToast.show(toatMessage: Vocabulary.getWordFromKey(key: "genral.mobilenumeber"))                }
                return
            }
            let logInParameters = ["class_id":"\(classID)","mobile_no":"\(self.arrayOfLogInDetail[2].text)"]
            
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kForgotpassword, parameter:logInParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
                if let userInfo = responseSuccess as? [String:Any]{
                    if let successMessage = userInfo["message"]{
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                            ShowToast.show(toatMessage: "\(successMessage)")
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
    func pushToDashBoard(){
        if let dashboardView = self.storyboard?.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController{
            self.navigationController?.pushViewController(dashboardView, animated: true)
        }
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
extension ForgotPasswordViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerHeight = UIScreen.main.bounds.height == 568.0 ? UIScreen.main.bounds.height*0.3 : UIScreen.main.bounds.height*0.4
        return headerHeight
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
        guard indexPath.row != 0 else {
            
            return UITableViewCell()
        }
        let logInCell:LogInTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogInTableViewCell", for: indexPath) as! LogInTableViewCell
        
        guard self.arrayOfLogInDetail.count > indexPath.row else {
            return logInCell
        }
        
        logInCell.imageTick.isHidden = self.arrayOfLogInDetail.count == indexPath.row+1
        logInCell.trailingContainer.constant = -20
        logInCell.btnDropDown.isHidden = true
        
        /*if indexPath.row == 0{
            logInCell.textFieldLogIn.inputView = self.schoolPicker
            logInCell.textFieldLogIn.inputAccessoryView = self.schoolPickerToolBar
        }else*/
        if indexPath.row == 1{
            logInCell.textFieldLogIn.inputAccessoryView = self.classPickerToolBar
            logInCell.textFieldLogIn.inputView = self.classPicker
//            if let first = self.arrayOfLogInDetail.first{
//                logInCell.textFieldLogIn.isEnabled = first.text.count > 0
//            }
        }else if indexPath.row == 2{
            logInCell.textFieldLogIn.inputAccessoryView = nil
            logInCell.textFieldLogIn.inputView = nil
            if self.arrayOfLogInDetail.count > 1{
                let first = self.arrayOfLogInDetail[1]
                logInCell.textFieldLogIn.isEnabled = first.text.count > 0
            }
        }
        /*
        if indexPath.row == 1 {
            logInCell.trailingContainer.constant = 0
            logInCell.btnDropDown.isHidden = false
        } else {
            logInCell.trailingContainer.constant = -20
            logInCell.btnDropDown.isHidden = true
        }*/
        
        logInCell.tag = indexPath.row
        logInCell.textFieldLogIn.delegate = self
        logInCell.textFieldLogIn.tag = indexPath.row + 10
        let detail = arrayOfLogInDetail[indexPath.row]
        logInCell.btnDropDown.tag = 101
        logInCell.textFieldLogIn.tweePlaceholder = "\(detail.placeHolder)"
        logInCell.textFieldLogIn.text = "\(detail.text)"
        logInCell.textFieldLogIn.keyboardType = (indexPath.row == 1) ? detail.keyboardType : .asciiCapableNumberPad
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
        if indexPath.row == 0{
            return 0
        }else{
            return self.heightOfTableViewCell
        }
        
    }
    
}
extension ForgotPasswordViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.schoolPicker{
            return self.schoolOptions[row].strName
        }else{
           return self.classOptions[row].strName
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.schoolPicker{
            return self.schoolOptions.count
        }else{
            return self.classOptions.count
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.schoolPicker{
            self.currentSchool = self.schoolOptions[row]
        }else{
            self.currentClas = self.classOptions[row]
        }
    }
}
extension ForgotPasswordViewController:UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        
        let tag = textField.tag - 10
        if tag+1 == self.arrayOfLogInDetail.count{
            if typpedString.count > 15{
                return false
            }
        }
        let detail = arrayOfLogInDetail[tag]
        detail.text = "\(typpedString)"
        return true
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 12{
            self.isKeyboardOpen = true
            DispatchQueue.main.async {
                self.tableViewForgotPassword.setContentOffset(CGPoint(x: 0,y :140), animated: true)
            }
        }
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 12{
            self.isKeyboardOpen = false
            DispatchQueue.main.async {
                self.tableViewForgotPassword.setContentOffset(CGPoint(x: 0,y :0), animated: false)
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
        if textField.tag == 10 { //school
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
        }else if textField.tag == 11{ //class
            
        }else{
            (textField as! TweeActiveTextField).activeLineColor = kSchoolThemeColor//UIColor.init(hexString:"C8C7CC")///.white
            (textField as! TweeActiveTextField).lineColor = UIColor.init(hexString:"C8C7CC")///.white
            textField.setBorder(color: .clear)
            self.postForgotPasswordAPIRequest()
        }
        return true
    }
}
