//
//  AddAccountViewController.swift
//  SchoolApp
//
//  Created by user on 15/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
protocol FilterDelegate {
    func didConfirmfilterParameters(filterParameters:[String:Any])
}
class AddAccountViewController: UIViewController {

    
    fileprivate let kFilterClassID = "class_id"
    fileprivate let kFilterSectionID = "divison_id"
    
    @IBOutlet var containerView:UIView!
    @IBOutlet var tableViewLogIn:UITableView!
    @IBOutlet var buttonSignIn:UIButton!
    @IBOutlet var buttonCancel:UIButton!
    @IBOutlet var buttonClear:UIButton!
    
    var arrayOfLogInDetail:[TextFieldDetail] = []
    let heightOfTableViewCell:CGFloat = 100.0
    var isForClassSectionFilter:Bool = false
    
    
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    
    var selectedClass:[SchoolClass]?
    
    var sectionOptions:[StudentSection] = []
    var selectedSection:[StudentSection]?
    
    var filterParameters:[String:Any] = [:]
    
    var delegate:FilterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Configure LoginDetails
        self.configureLogInDetails(userEmail:"", userPassword:"")
        //setup views
        self.setUpView()
        
        //configure tableview
        self.configureTableView()
        if self.isForClassSectionFilter{
            //get school API Request
            self.getSchoolAPIRequest()
        }
    }
    func setUpView(){
        if self.isForClassSectionFilter{
            self.buttonSignIn.setTitle(Vocabulary.getWordFromKey(key: "Apply Filter"), for: .normal)
            self.configureLogInDetails(userEmail: "\(self.filterParameters["className"] ?? "")", userPassword: "\(self.filterParameters["sectionName"] ?? "")")
        }else{
            self.buttonSignIn.setTitle(Vocabulary.getWordFromKey(key: "genral.AddAccount"), for: .normal)
        }
        self.buttonCancel.setTitle(Vocabulary.getWordFromKey(key: "genral.Cancel"), for: .normal)
        self.buttonClear.setTitle(Vocabulary.getWordFromKey(key: "Clear"), for: .normal)
        self.buttonClear.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonSignIn.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonCancel.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonSignIn.setTitleColor(UIColor.white, for: .normal)
        self.buttonCancel.setTitleColor(UIColor.white, for: .normal)
        self.buttonClear.setTitleColor(UIColor.white, for: .normal)
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 12.0
        self.buttonClear.isHidden = !self.isForClassSectionFilter
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
//        self.tableViewLogIn.tableFooterView = UIView()
//        self.tableViewLogIn.tableHeaderView = UIView()
        self.tableViewLogIn.reloadData()
    }
    func configureLogInDetails(userEmail:String,userPassword:String){
        if self.isForClassSectionFilter{
            let classDetail = TextFieldDetail.init(placeHolder: Vocabulary.getWordFromKey(key: "Class"), text: "\(userEmail)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
            let sectionDetail = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "Section"), text: "\(userPassword)", keyboardType: .default, returnKey: .done, isSecure: false)
            self.arrayOfLogInDetail = [classDetail,sectionDetail]
        }else{
            let emailDetail = TextFieldDetail.init(placeHolder: Vocabulary.getWordFromKey(key: "genral.username"), text: "\(userEmail)", keyboardType: .emailAddress, returnKey: .next, isSecure: false)
            let passDetail = TextFieldDetail.init(placeHolder:  Vocabulary.getWordFromKey(key: "genral.password"), text: "\(userPassword)", keyboardType: .default, returnKey: .done, isSecure: true)
            self.arrayOfLogInDetail = [emailDetail,passDetail]

        }
       
        
        DispatchQueue.main.async {
            self.tableViewLogIn.reloadData()
        }
        
    }
    //MARK:- API request
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
                if let objClassID = self.filterParameters[self.kFilterClassID]{
                    self.selectedClass = self.classOptions.filter({$0.strClassId == "\(objClassID)"})
                    
                    self.getStudentSectionBasedOnClass(classID:"\(objClassID)")
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
    func getStudentSectionBasedOnClass(classID:String){
        var sectionParameters:[String:Any] = [:]
        if  let array = self.selectedClass,array.count > 0{
            sectionParameters["class_id"] = array.first!.strClassId
        }
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGETSection, parameter:sectionParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfSection = success["data"] as? [[String:Any]]{
                self.sectionOptions.removeAll()
                for objSectionData:[String:Any] in arrayOfSection{
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objSectionData, options:.prettyPrinted)
                        if let sections = try? JSONDecoder().decode(StudentSection.self, from: jsondata){
                            self.sectionOptions.append(sections)
                        }
                    }catch{
                        
                    }
                }
                if let objSectionID = self.filterParameters[self.kFilterSectionID]{
                    self.selectedSection = self.sectionOptions.filter({$0.sectionID == "\(objSectionID)"})
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

    func postLogInAPIRequest(){
        self.view.endEditing(true)
        if(self.isValidLogIn()){
          
            var logInParameters = ["username":"\(self.arrayOfLogInDetail[0].text)","password":"\(self.arrayOfLogInDetail[1].text)"]
            let deviceToken = UserDefaults.standard.object(forKey: "currentDeviceToken") as? String
            logInParameters["device_token"] = deviceToken
            logInParameters["device_type"] = "iOS"
            APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kLogInString, parameter:logInParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
                
                if let success = responseSuccess as? [String:Any],let userInfo = success["data"] as? [String:Any]{
                    DispatchQueue.main.async {
                        APIRequestClient.shared.addUserToDB(userData: userInfo)
                        if let userID = userInfo["user_id"]{
                            APIRequestClient.shared.fetchUserDetailFromDataBase(userId: "\(userID)", userData: { (result) in
                                DispatchQueue.main.async {
                                    if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
                                    {
                                        if let rootViewController = rootVC as? UINavigationController,let lastView = rootViewController.viewControllers.last{
                                            DispatchQueue.main.async {
                                                    lastView.viewDidLoad()
                                            }
                                        }
                                    }
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
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
    // MARK: - Selector Methods
    @IBAction func buttonSignInSelector(sender:UIButton){
        if self.isForClassSectionFilter{
            if let _ = self.delegate{
                if let listOfClass = self.selectedClass,let objclass = listOfClass.first{
                    self.filterParameters["className"] = objclass.strName
                }
                if let listOfSection = self.selectedSection{
                    let nameArray = listOfSection.map({$0.sectionName}).reversed()
                    self.filterParameters["sectionName"] = nameArray.joined(separator:",")
                }
                self.delegate!.didConfirmfilterParameters(filterParameters: self.filterParameters)
            }
            self.dismiss(animated: true, completion: nil)
        }else{
            self.postLogInAPIRequest()
        }
        
    }
    @IBAction func buttonClearSelector(sender:UIButton){
        self.filterParameters = [:]
        if let _ = self.selectedClass{
            self.selectedClass!.removeAll()
        }
        if let _ = self.selectedSection{
            self.selectedSection!.removeAll()
        }
        //Configure LoginDetails
        self.configureLogInDetails(userEmail:"", userPassword:"")
    }
    @IBAction func buttonCancelSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonBlurSelector(sender:UIButton){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension AddAccountViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
        if self.isForClassSectionFilter{
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
    func presentClassSearchViewController(){
        DispatchQueue.main.async {
            
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = .SchoolClass
                schoolClassPicker.arrayclassOptions = self.classOptions
                self.view.endEditing(true)
                schoolClassPicker.delegate = self
                schoolClassPicker.isSingleSelection = true
                if let _ = self.selectedClass{
                    schoolClassPicker.selectedSchoolClass = NSMutableSet.init(array:self.selectedClass!.map{$0.strClassId})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
            defer{
                let classCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
                let sectionCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
                classCell.textFieldLogIn.maximizePlaceholder()
                
            }
        }
    }
    func presentSectionSearchViewController(){
        DispatchQueue.main.async {
            
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = .StudentSection
                schoolClassPicker.arraySectionOptions = self.sectionOptions
                self.view.endEditing(true)
                schoolClassPicker.delegate = self
                schoolClassPicker.isSingleSelection = true
                if let _ = self.selectedSection{
                    schoolClassPicker.selectedSchoolSection = NSMutableSet.init(array:self.selectedSection!.map{$0.sectionID})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
            defer{
                let classCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
                let sectionCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell
                sectionCell.textFieldLogIn.maximizePlaceholder()
            }
        }
    }
}
extension AddAccountViewController:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        let classCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
        let sectionCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 1, section: 0)) as! LogInTableViewCell

        if searchType == .SchoolClass{
            if let arrayOfClass = values as? [SchoolClass]{
                let objArray = arrayOfClass.map{$0.strName}
                let objArrayId = arrayOfClass.map{$0.strClassId}
                if objArrayId.count > 0{
                    self.filterParameters[kFilterClassID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.filterParameters[kFilterClassID] = ""
                }
                
                self.validTextField(textField: classCell.textFieldLogIn)
                let detail = arrayOfLogInDetail[0]
                let detailSection = arrayOfLogInDetail[1]
                
                if objArray.count > 0{
                    self.selectedClass = arrayOfClass
                    detail.text = "\(objArray.reversed().joined(separator: ", "))"
                    DispatchQueue.main.async {
                        classCell.textFieldLogIn.minimizePlaceholder()
                    }
                    //clear section on class selection
                    self.selectedSection = []
                    detailSection.text = ""
                    DispatchQueue.main.async {
                        sectionCell.textFieldLogIn.maximizePlaceholder()
                    }
                    self.getStudentSectionBasedOnClass(classID: objArrayId.first!)
                }else{
                    self.selectedClass = []
                    detail.text = ""
                    DispatchQueue.main.async {
                            classCell.textFieldLogIn.maximizePlaceholder()
                    }
                }
            }
        }else if searchType == .StudentSection{
            if let arrayOfSection = values as? [StudentSection]{
                let objArray = arrayOfSection.map{$0.sectionName}
                let objArrayId = arrayOfSection.map{$0.sectionID}
                if objArrayId.count > 0{
                    self.filterParameters[kFilterSectionID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.filterParameters[kFilterSectionID] = ""
                }
                self.validTextField(textField: sectionCell.textFieldLogIn)
                let detail = arrayOfLogInDetail[1]
                if objArray.count > 0{
                    self.selectedSection = arrayOfSection
                    detail.text = "\(objArray.reversed().joined(separator: ", "))"
                    DispatchQueue.main.async {
                        sectionCell.textFieldLogIn.minimizePlaceholder()
                    }
                }else{
                    self.selectedSection = []
                    detail.text = ""
                    DispatchQueue.main.async {
                        sectionCell.textFieldLogIn.maximizePlaceholder()
                    }
                }
            }
        }
        defer {
            DispatchQueue.main.async {
                self.tableViewLogIn.reloadData()
            }
        }
       
    }
}
extension AddAccountViewController:UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.isForClassSectionFilter{
            textField.resignFirstResponder()
            if textField.tag == 10{
                self.presentClassSearchViewController()
            }else{
                self.presentSectionSearchViewController()
            }
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if self.isForClassSectionFilter{
            if textField.tag == 11{
                if let array = self.selectedClass,array.count > 0{
                    return true
                }else{
                    DispatchQueue.main.async {
                        let classCell:LogInTableViewCell = self.tableViewLogIn.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! LogInTableViewCell
                        self.invalidTextField(textField: classCell.textFieldLogIn)
                        ShowToast.show(toatMessage: "Please select class first.")
                    }
                    return false
                }
            }
            return true
        }
       return true
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = kSchoolThemeColor
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.isForClassSectionFilter{
            return false
        }
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
        guard !typpedString.isContainWhiteSpace() else{
            return false
        }
        let tag = textField.tag - 10
        let detail = arrayOfLogInDetail[tag]
        detail.text = "\(typpedString)"
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
