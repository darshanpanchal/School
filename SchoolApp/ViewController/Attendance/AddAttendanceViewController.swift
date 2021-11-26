//
//  AddAttendanceViewController.swift
//  SchoolApp
//
//  Created by user on 15/07/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddAttendanceViewController: UIViewController {

    fileprivate let kAttendanceClassID = "class_id"
    fileprivate let kAttendanceSectionID = "divison_id"
    fileprivate let kAttendanceDate = "absent_date"
    fileprivate let kAttendaceStudentID = "student_ids"
    
    @IBOutlet var navigationView:UIView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewAddAttendance:UITableView!
    
    @IBOutlet var txtFeildClass:TweeActiveTextField!
    @IBOutlet var txtViewClass:UITextView!
    
    @IBOutlet var txtFeildSection:TweeActiveTextField!
    @IBOutlet var txtViewSection:UITextView!
    
    @IBOutlet var txtFieldDate:TweeActiveTextField!
    
    @IBOutlet var txtFeildStudent:TweeActiveTextField!
    @IBOutlet var txtViewStudent:UITextView!
    
    @IBOutlet var buttonSubmit:RoundButton!
    
    @IBOutlet var testImageView:UIImageView!
    
    var attendanceDatePicker:UIDatePicker = UIDatePicker()
    var attendanceDatePickerToolbar:UIToolbar = UIToolbar()
    
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    
    var selectedClass:[SchoolClass]?
    
    var sectionOptions:[StudentSection] = []
    var selectedSection:[StudentSection]?
    
    var arrayOfStudent:[SchoolStudent] = []
    var arrayOfSelectedStudent:[SchoolStudent] = []
    
    var addAttendanceParameters:[String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "SALON AKKAD_THANK-YOU_GIF", withExtension: "gif")!)
//        let advTimeGif = UIImage.sd_animatedGIF(with: imageData!)
//        self.testImageView.image = advTimeGif

        // Do any additional setup after loading the view.
        //setupview
        self.setUpView()
        
        //get school API Request
        self.getSchoolAPIRequest()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"Student Attendance Entry")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.txtFeildClass.tweePlaceholder = "Class"
        self.txtFeildSection.tweePlaceholder = "Section"
        self.txtFieldDate.tweePlaceholder = "Date"
        self.txtFeildStudent.tweePlaceholder = "Absent Students"
        
        self.txtViewClass.delegate = self
        self.txtViewSection.delegate = self
        self.txtViewStudent.delegate = self
        
        self.configureFloatTextField(txtfield: self.txtFeildClass)
        self.configureFloatTextField(txtfield: self.txtFeildSection)
        self.configureFloatTextField(txtfield: self.txtFieldDate)
        self.configureFloatTextField(txtfield: self.txtFeildStudent)
        
        //        self.txtViewClass.text = "Test,One,Three"
        //        self.txtFeildClass.minimizePlaceholder()
        
        self.attendanceDatePicker.date = Date()
        
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
        
        self.attendanceDatePickerToolbar.sizeToFit()
        self.attendanceDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.attendanceDatePickerToolbar.layer.borderWidth = 1.0
        self.attendanceDatePickerToolbar.clipsToBounds = true
        self.attendanceDatePickerToolbar.backgroundColor = UIColor.white
        self.attendanceDatePicker.datePickerMode = .date
        //        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        //        self.homeWorkDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddHomeworkViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddHomeworkViewController.cancelFormDatePicker))
        self.attendanceDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFieldDate.inputView = self.attendanceDatePicker
        self.txtFieldDate.inputAccessoryView = self.attendanceDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        let date =  self.attendanceDatePicker.date
        self.txtFieldDate.text = date.ddMMyyyy
        self.addAttendanceParameters[kAttendanceDate] = date.ddMMyyyy
        self.validTextField(textField: self.txtFieldDate)
        if let selectedClass = self.selectedClass,selectedClass.count > 0{
            self.getStudentListBasedOnClass(classId: selectedClass.first!.strClassId)
        }
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
    func isValidNewAttendance()->Bool{
        guard "\(self.addAttendanceParameters[kAttendanceClassID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildClass)
                ShowToast.show(toatMessage: "Please select class to add attendance.")
            }
            return false
        }
        guard "\(self.addAttendanceParameters[kAttendanceDate] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldDate)
                
                ShowToast.show(toatMessage: "Please select date to add attendance.")
            }
            return false
        }
        guard "\(self.addAttendanceParameters[kAttendaceStudentID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildStudent)
                ShowToast.show(toatMessage: "Please select absent students to add attendance.")
            }
            return false
        }
        return true
    }
    func sizeHeaderFit(){
        if let headerView =  self.tableViewAddAttendance.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableViewAddAttendance.tableHeaderView = headerView
            self.view.layoutIfNeeded()
        }
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewAddAttendance.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewAddAttendance.tableFooterView = footerView
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
    func getSectionAPIRequest(){
//        StudentSection.init(sectionID: 1, sectionName: "A")
//        StudentSection.init(sectionID: 1, sectionName: "A")
//        StudentSection.init(sectionID: 1, sectionName: "A")
        /*
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:"user/addattendace", parameter:self.addAttendanceParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
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
        })*/
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
    func getStudentListBasedOnClass(classId:String){
        var studentParameters:[String:Any] = [:]
        
        studentParameters["class_id"] = classId
        if let objSection = self.selectedSection,objSection.count > 0{
            studentParameters[kAttendanceSectionID] = objSection.first!.sectionID
        }
        if "\(self.addAttendanceParameters[kAttendanceDate] ?? "")".count > 0{
                studentParameters[kAttendanceDate] = "\(self.addAttendanceParameters[kAttendanceDate] ?? "")"
        }
        print("======== \(studentParameters)")
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString: kGetStudentByClass, parameter:studentParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            print(responseSuccess)
            if let success = responseSuccess as? [String:Any],let arrayOfStudent = success["data"] as? [[String:Any]]{
                self.arrayOfStudent.removeAll()
                for objStudentDict in arrayOfStudent{
                    let objStudent = SchoolStudent.init(studentDetail: objStudentDict)
                    self.arrayOfStudent.append(objStudent)
                    print("\(objStudent.studentName) \(objStudent.fatherName) \(objStudent.surName)")
                }
                
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            self.arrayOfStudent.removeAll()
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

    func addAttendaceAPIRequest(){
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:"users/addAttendance", parameter:self.addAttendanceParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
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
        if self.isValidNewAttendance(){
            self.addAttendaceAPIRequest()
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
                schoolClassPicker.isSingleSelection = true
                if let _ = self.selectedSection{
                    schoolClassPicker.selectedSchoolSection = NSMutableSet.init(array:self.selectedSection!.map{$0.sectionID})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
    func presentStudentsSearchViewController(){
        DispatchQueue.main.async {
            
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = .ClassStudent
                self.view.endEditing(true)
                schoolClassPicker.delegate = self
                schoolClassPicker.arrayOfStudentOptions = self.arrayOfStudent
                schoolClassPicker.isSingleSelection = false
                if  self.arrayOfSelectedStudent.count == 0{
                    let objArrayOfFilterStudent = self.arrayOfStudent.filter{$0.isAbsent == true}
                    schoolClassPicker.selectedStudent = NSMutableSet.init(array:objArrayOfFilterStudent.map{$0.studentID})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
    
    
}
extension AddAttendanceViewController:UITextFieldDelegate{
    
}
extension AddAttendanceViewController:SearchViewDelegate{
    
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        if searchType == .SchoolClass{
            if let arrayOfClass = values as? [SchoolClass]{
                let objArray = arrayOfClass.map{$0.strName}
                let objArrayId = arrayOfClass.map{$0.strClassId}
                if objArrayId.count > 0{
                    self.addAttendanceParameters[kAttendanceClassID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.addAttendanceParameters[kAttendanceClassID] = ""
                }
                self.validTextField(textField: self.txtFeildClass)
                if objArray.count > 0{
                    self.selectedClass = arrayOfClass
                    self.txtViewClass.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildClass.minimizePlaceholder()
                    self.getStudentSectionBasedOnClass(classID: objArrayId.first!)
                    self.getStudentListBasedOnClass(classId: objArrayId.first!)
                }else{
                    self.selectedClass = []
                    self.txtViewClass.text = ""
                    self.txtFeildClass.maximizePlaceholder()
                }
            }
        }else if searchType == .StudentSection{
            if let arrayOfSection = values as? [StudentSection]{
                let objArray = arrayOfSection.map{$0.sectionName}
                let objArrayId = arrayOfSection.map{$0.sectionID}
                if objArrayId.count > 0{
                    self.addAttendanceParameters[kAttendanceSectionID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.addAttendanceParameters[kAttendanceSectionID] = ""
                }
                self.validTextField(textField: self.txtFeildSection)
                if objArray.count > 0{
                    self.selectedSection = arrayOfSection
                    self.txtViewSection.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildSection.minimizePlaceholder()
                    if let selectedClass = self.selectedClass,selectedClass.count > 0{
                        self.getStudentListBasedOnClass(classId: selectedClass.first!.strClassId)
                    }
                }else{
                    self.selectedSection = []
                    self.txtViewSection.text = ""
                    self.txtFeildSection.maximizePlaceholder()
                }
            }
        }else if searchType == .ClassStudent{
            if let objarrayOfStudent = values as? [SchoolStudent]{
                
                let objArray = objarrayOfStudent.map{$0.fullName}
                let objArrayId = objarrayOfStudent.map{$0.studentID}
                
                self.validTextField(textField: self.txtFeildStudent)
                if objArray.count > 0{
                    self.arrayOfSelectedStudent = objarrayOfStudent
                    self.txtViewStudent.text = "\(objArray.reversed().joined(separator: ", \n"))"
                    self.txtFeildStudent.minimizePlaceholder()
                    self.addAttendanceParameters[kAttendaceStudentID] = "\(objArrayId.joined(separator: ", "))"
                }else{
                    self.addAttendanceParameters[kAttendaceStudentID] = ""
                    self.arrayOfSelectedStudent = []
                    self.txtViewStudent.text = ""
                    self.txtFeildStudent.maximizePlaceholder()
                }
            }
        }
        
        defer {
            self.view.endEditing(true)
            self.sizeHeaderFit()
        }
    }
}
extension AddAttendanceViewController:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == self.txtViewSection{
            guard "\(self.addAttendanceParameters[kAttendanceClassID] ?? "")".count > 0 else {
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFeildClass)
                    ShowToast.show(toatMessage: "Please select class to add attendance.")
                }
                return false
            }
        }
        if textView == self.txtViewStudent{
            guard "\(self.addAttendanceParameters[kAttendanceClassID] ?? "")".count > 0 else {
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFeildClass)
                    ShowToast.show(toatMessage: "Please select class to add attendance.")
                }
                return false
            }
            guard "\(self.addAttendanceParameters[kAttendanceDate] ?? "")".count > 0 else {
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFieldDate)
                    
                    ShowToast.show(toatMessage: "Please select date to add attendance.")
                }
                return false
            }
        }
        return true
    }
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
            
        }else if textView == self.txtViewStudent{
            if textView.text.count == 0{
                self.txtFeildStudent.resignFirstResponder()
                self.txtFeildStudent.maximizePlaceholder()
                self.txtViewStudent.resignFirstResponder()
            }else{
                self.txtFeildStudent.minimizePlaceholder()
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
            self.txtFeildSection.resignFirstResponder()
            self.txtFeildSection.minimizePlaceholder()
            self.txtViewSection.resignFirstResponder()
            //PreesntSection Picker
            self.presentSectionSearchViewController()
        }else if textView == self.txtViewStudent{
            self.txtFeildStudent.resignFirstResponder()
            self.txtFeildStudent.minimizePlaceholder()
            self.txtViewStudent.resignFirstResponder()
            //present student picker
            self.presentStudentsSearchViewController()
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.txtViewStudent{
            self.addAttendanceParameters[kAttendaceStudentID] = "\(typpedString)"
            if typpedString.count > 0{
                self.validTextField(textField:self.txtFeildStudent)
            }
        }
        defer {
            self.sizeHeaderFit()
        }
        return true
        
    }
}
struct StudentSection:Codable{
    let sectionName,sectionID:String

    enum CodingKeys: String, CodingKey {
        case sectionName = "name"
        case sectionID = "divison_id"
    }
}
