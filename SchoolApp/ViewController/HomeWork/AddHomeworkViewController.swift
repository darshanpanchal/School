//
//  AddHomeworkViewController.swift
//  SchoolApp
//
//  Created by user on 08/07/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddHomeworkViewController: UIViewController {

    fileprivate let kHomeWorkClassID = "class_id"
    fileprivate let kHomeWorkSectionID = "divison_id"
    fileprivate let kHomeWorkDate = "homework_date"
    fileprivate let kHomeWorkDescription = "homework_text"
    
    @IBOutlet var navigationView:UIView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewAddHome:UITableView!
    
    @IBOutlet var txtFeildClass:TweeActiveTextField!
    @IBOutlet var txtViewClass:UITextView!
    
    @IBOutlet var txtFeildSection:TweeActiveTextField!
    @IBOutlet var txtViewSection:UITextView!
    
    @IBOutlet var txtFieldDate:TweeActiveTextField!
    
    @IBOutlet var txtFeildDescription:TweeActiveTextField!
    @IBOutlet var txtViewDescription:UITextView!
    
    @IBOutlet var buttonSubmit:RoundButton!
    
    var homeWorkDatePicker:UIDatePicker = UIDatePicker()
    var homeworkDatePickerToolbar:UIToolbar = UIToolbar()
    
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    
    var selectedClass:[SchoolClass]?
    
    var sectionOptions:[StudentSection] = []
    var selectedSection:[StudentSection]?
    
    
    var addHomeworkParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setupview
        self.setUpView()
        
        //get school API Request
        self.getSchoolAPIRequest()
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"Add HomeWork")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.txtFeildClass.tweePlaceholder = "Class"
        self.txtFeildSection.tweePlaceholder = "Section"
        self.txtFieldDate.tweePlaceholder = "Date"
        self.txtFeildDescription.tweePlaceholder = "HomeWork"
        
        self.txtViewClass.delegate = self
        self.txtViewSection.delegate = self
        self.txtViewDescription.delegate = self
        
        self.configureFloatTextField(txtfield: self.txtFeildClass)
        self.configureFloatTextField(txtfield: self.txtFeildSection)
        self.configureFloatTextField(txtfield: self.txtFieldDate)
        self.configureFloatTextField(txtfield: self.txtFeildDescription)
        
        //        self.txtViewClass.text = "Test,One,Three"
        //        self.txtFeildClass.minimizePlaceholder()
        
        self.homeWorkDatePicker.date = Date()
        
        self.buttonSubmit.setTitleColor(UIColor.white, for: .normal)
        self.buttonSubmit.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        
      
        self.configureHomeWorkDatePicker()
    }
    func configureFloatTextField(txtfield:TweeActiveTextField){
        txtfield.delegate = self
        txtfield.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        txtfield.textColor = .black
        txtfield.placeholderColor = kSchoolThemeColor
        txtfield.adjustsFontForContentSizeCategory = true
        
    }
    func configureHomeWorkDatePicker(){
        
        self.homeworkDatePickerToolbar.sizeToFit()
        self.homeworkDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.homeworkDatePickerToolbar.layer.borderWidth = 1.0
        self.homeworkDatePickerToolbar.clipsToBounds = true
        self.homeworkDatePickerToolbar.backgroundColor = UIColor.white
        self.homeWorkDatePicker.datePickerMode = .date
//        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        //        self.homeWorkDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddHomeworkViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddHomeworkViewController.cancelFormDatePicker))
        self.homeworkDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFieldDate.inputView = self.homeWorkDatePicker
        self.txtFieldDate.inputAccessoryView = self.homeworkDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        let date =  self.homeWorkDatePicker.date
        self.txtFieldDate.text = date.ddMMyyyy
        self.addHomeworkParameters[kHomeWorkDate] = date.ddMMyyyy
        self.validTextField(textField: self.txtFieldDate)
        
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.txtFieldDate.resignFirstResponder()
            self.view.endEditing(true)
        }
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = kSchoolThemeColor
    }
    func isValidNewHomeWork()->Bool{
        guard "\(self.addHomeworkParameters[kHomeWorkClassID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildClass)
                ShowToast.show(toatMessage: "Please select class.")
            }
            return false
        }
        guard "\(self.addHomeworkParameters[kHomeWorkSectionID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildSection)
                
                ShowToast.show(toatMessage: "Please select section.")
            }
            return false
        }
        guard "\(self.addHomeworkParameters[kHomeWorkDate] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldDate)
                
                ShowToast.show(toatMessage: "Please select homework date.")
            }
            return false
        }
        guard "\(self.addHomeworkParameters[kHomeWorkDescription] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildDescription)
                ShowToast.show(toatMessage: "Please add homework description.")
            }
            return false
        }
        return true
    }
    func sizeHeaderFit(){
        if let headerView =  self.tableViewAddHome.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableViewAddHome.tableHeaderView = headerView
            self.view.layoutIfNeeded()
        }
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewAddHome.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewAddHome.tableFooterView = footerView
            self.view.layoutIfNeeded()
        }
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
            sectionParameters["class_id"] = array.first?.strClassId
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
    func addHomeWorkAPIRequest(){
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kAddHomeWork, parameter:self.addHomeworkParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let addRemarkMessage = success["message"]{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage: "\(addRemarkMessage)")
                    if let isCreated = success["status"] as? Bool,isCreated{
                        self.navigationController?.popViewController(animated: true)
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
        //        SideMenu.show()
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        if self.isValidNewHomeWork(){
            self.addHomeWorkAPIRequest()
        }
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
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
                schoolClassPicker.isSingleSelection = false
                if let _ = self.selectedClass{
                    schoolClassPicker.selectedSchoolClass = NSMutableSet.init(array:self.selectedClass!.map{$0.strClassId})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
    

}
extension AddHomeworkViewController:UITextFieldDelegate{
    
}
extension AddHomeworkViewController:UITextViewDelegate{
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == self.txtViewClass{
            if textView.text.count == 0{
                self.txtFeildClass.resignFirstResponder()
                self.txtFeildClass.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFeildClass.minimizePlaceholder()
            }
        }else if textView == self.txtViewSection{
            if textView.text.count == 0{
                self.txtFeildSection.resignFirstResponder()
                self.txtFeildSection.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFeildSection.minimizePlaceholder()
            }

        }else if textView == self.txtViewDescription{
            if textView.text.count == 0{
                self.txtFeildDescription.resignFirstResponder()
                self.txtFeildDescription.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFeildDescription.minimizePlaceholder()
            }
        }
        defer {
            self.sizeHeaderFit()
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txtViewClass{
            self.txtFeildClass.resignFirstResponder()
            self.txtFeildClass.minimizePlaceholder()
            self.txtViewClass.resignFirstResponder()
            //PreesntClass Picker
            self.presentClassSearchViewController()
        }else if textView == self.txtViewSection{
            self.txtFeildClass.resignFirstResponder()
            self.txtFeildClass.minimizePlaceholder()
            self.txtViewClass.resignFirstResponder()
            //PreesntSection Picker
            self.presentSectionSearchViewController()
        }else if textView == self.txtViewDescription{
            self.txtFeildDescription.resignFirstResponder()
            self.txtFeildDescription.minimizePlaceholder()
            textView.becomeFirstResponder()
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.txtViewDescription{
            self.addHomeworkParameters[kHomeWorkDescription] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField:self.txtFeildDescription)
            }
        }
        defer {
            self.sizeHeaderFit()
        }
        return true
        
    }
}
extension AddHomeworkViewController:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
          if searchType == .SchoolClass{
            
        if let arrayOfClass = values as? [SchoolClass]{
            let objArray = arrayOfClass.map{$0.strName}
            let objArrayId = arrayOfClass.map{$0.strClassId}
            if objArrayId.count > 0{
                self.addHomeworkParameters[kHomeWorkClassID] = "\(objArrayId.reversed().joined(separator: ","))"
            }else{
                self.addHomeworkParameters[kHomeWorkClassID] = ""
            }
            self.validTextField(textField: self.txtFeildClass)
            if objArray.count > 0{
                self.selectedClass = arrayOfClass
                self.txtViewClass.text = "\(objArray.reversed().joined(separator: ", "))"
                self.txtFeildClass.minimizePlaceholder()
                self.getStudentSectionBasedOnClass(classID: objArrayId.first!)
            }else{
                self.selectedClass = []
                self.txtViewClass.text = ""
                self.txtFeildClass.maximizePlaceholder()
            }
        }
        }else{
            if let arrayOfSection = values as? [StudentSection]{
                let objArray = arrayOfSection.map{$0.sectionName}
                let objArrayId = arrayOfSection.map{$0.sectionID}
                if objArrayId.count > 0{
                    self.addHomeworkParameters[kHomeWorkSectionID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.addHomeworkParameters[kHomeWorkSectionID] = ""
                }
                self.validTextField(textField: self.txtFeildSection)
                if objArray.count > 0{
                    self.selectedSection = arrayOfSection
                    self.txtViewSection.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildSection.minimizePlaceholder()
                }else{
                    self.selectedSection = []
                    self.txtViewSection.text = ""
                    self.txtFeildSection.maximizePlaceholder()
                }
            }
        }
        defer {
            self.sizeHeaderFit()
        }
    }
}


