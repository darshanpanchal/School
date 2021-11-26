//
//  AddRemarkViewController.swift
//  SchoolApp
//
//  Created by user on 08/07/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddRemarkViewController: UIViewController {
    
/*{"student_id":[1,2,3],"Remark_category_id":1,"Remark_name":1,"Remark_type":"positive","Remark_date":"2019-07-10","note":"Test it once."}*/
    fileprivate var kClassID = "class_id"
    fileprivate var kStudentID = "student_id"
    fileprivate var kRemarkCatID = "remark_category_id"
    fileprivate var kRemarkName = "remark_name"
    fileprivate var kRemarkType = "remark_type"
    fileprivate var kRemarkDate = "remark_date"
    fileprivate var kDescription = "note"
    
    
    @IBOutlet var navigationView:UIView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewAddRemark:UITableView!
    
    @IBOutlet var txtFeildClass:TweeActiveTextField!
    @IBOutlet var txtViewClass:UITextView!
    
    
    @IBOutlet var txtFieldStudent:TweeActiveTextField!
    @IBOutlet var txtViewStudent:UITextView!
    
    
    @IBOutlet var txtFieldRemarkCategory:TweeActiveTextField!
    @IBOutlet var txtViewRemarkCategory:UITextView!
    
    @IBOutlet var txtFieldRemarkName:TweeActiveTextField!
    @IBOutlet var txtViewRemarkName:UITextView!
    
    @IBOutlet var txtFieldRemarkType:TweeActiveTextField!
    
    @IBOutlet var txtFieldDate:TweeActiveTextField!
    
    @IBOutlet var txtFeildDescription:TweeActiveTextField!
    @IBOutlet var txtViewDescription:UITextView!
    
    @IBOutlet var buttonSubmit:RoundButton!

    
    var selectedClass:SchoolClass?
    var selectedRemarkCategory:RemarkCategory?
    
    
    var RemarkDatePicker:UIDatePicker = UIDatePicker()
    var RemarkDatePickerToolbar:UIToolbar = UIToolbar()
    
   
    var RemarkTypePicker: UIPickerView = UIPickerView.init()
    var RemarkTypePickerToolbar:UIToolbar = UIToolbar()
    
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    var addRemarkParameters:[String:Any] = [:]
    
    var arrayOfSelectedClass:[SchoolClass]?

    var arrayOfStudent:[SchoolStudent] = []
    
    var arrayOfSelectedStudent:[SchoolStudent] = []
    
    var arrayOfRemarkCategory:[RemarkCategory] = []
    var arrayOfSelectedCategory:[RemarkCategory] = []
    
    var arrayOfRemark:[StudentRemarkUpdate] = []
    var arrayOfSelectedRemark:[StudentRemarkUpdate] = []
    
    
    var arrayOfRemarkType:[String] = ["Positive","Nagative"]
    var remarkType = "Positive"
    var currentRemarkType:String{
        get{
            return remarkType
        }
        set{
            remarkType = newValue
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //setupview
        self.setUpView()
        
        //get school API Request
        self.getSchoolAPIRequest()
        
        //getRemark Category
        self.getCategoryRequest()
    }
    // MARK: - CustomMethods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"Create Student Remark")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.txtFeildClass.tweePlaceholder = "Class"
        self.txtFieldDate.tweePlaceholder = "Date"
        self.txtFeildDescription.tweePlaceholder = "Discription"
        
        self.txtViewClass.delegate = self
        self.txtViewStudent.delegate = self
        self.txtViewRemarkCategory.delegate = self
        self.txtViewRemarkName.delegate = self
        
        
        self.txtViewDescription.delegate = self
        
        self.configureFloatTextField(txtfield: self.txtFeildClass)
        
        self.configureFloatTextField(txtfield: self.txtFieldStudent)
        self.configureFloatTextField(txtfield: self.txtFieldRemarkCategory)
        self.configureFloatTextField(txtfield: self.txtFieldRemarkName)
        self.configureFloatTextField(txtfield: self.txtFieldRemarkType)
        
        self.configureFloatTextField(txtfield: self.txtFieldDate)
        self.configureFloatTextField(txtfield: self.txtFeildDescription)
        
        //        self.txtViewClass.text = "Test,One,Three"
        //        self.txtFeildClass.minimizePlaceholder()
        
        self.RemarkDatePicker.date = Date()
        
        self.buttonSubmit.setTitleColor(UIColor.white, for: .normal)
        self.buttonSubmit.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        
     
        self.sizeHeaderFit()
        
        self.configureRemarkDatePicker()
        
        self.configureRemarkTypePicker()
    }
    func configureRemarkDatePicker(){
        
        self.RemarkDatePickerToolbar.sizeToFit()
        self.RemarkDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.RemarkDatePickerToolbar.layer.borderWidth = 1.0
        self.RemarkDatePickerToolbar.clipsToBounds = true
        self.RemarkDatePickerToolbar.backgroundColor = UIColor.white
        self.RemarkDatePicker.datePickerMode = .date
//        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
//        self.RemarkDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddRemarkViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddRemarkViewController.cancelFormDatePicker))
        self.RemarkDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFieldDate.inputView = self.RemarkDatePicker
        self.txtFieldDate.inputAccessoryView = self.RemarkDatePickerToolbar
    }
    
    @objc func doneFormDatePicker(){
        let date =  self.RemarkDatePicker.date
        self.txtFieldDate.text = date.ddMMyyyy
        self.addRemarkParameters[kRemarkDate] = date.ddMMyyyy
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
    func configureRemarkTypePicker(){
        self.RemarkTypePickerToolbar.sizeToFit()
        self.RemarkTypePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.RemarkTypePickerToolbar.layer.borderWidth = 1.0
        self.RemarkTypePickerToolbar.clipsToBounds = true
        self.RemarkTypePickerToolbar.backgroundColor = UIColor.white
        
        
        self.RemarkTypePicker.delegate = self
        self.RemarkTypePicker.dataSource = self
        
        //        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        //        self.RemarkDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddRemarkViewController.doneRemarkTypePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Remark Type"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddRemarkViewController.cancelFormDatePicker))
        self.RemarkTypePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFieldRemarkType.inputView = self.RemarkTypePicker
        self.txtFieldRemarkType.inputAccessoryView = self.RemarkTypePickerToolbar
    }
    @objc func doneRemarkTypePicker(){
        self.txtFieldRemarkType.text = self.currentRemarkType
        self.validTextField(textField: self.txtFieldRemarkType)
        self.addRemarkParameters[kRemarkType] = self.currentRemarkType
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.txtFieldRemarkType.resignFirstResponder()
            self.view.endEditing(true)
        }
    }
    func configureFloatTextField(txtfield:TweeActiveTextField){
        txtfield.delegate = self
        txtfield.placeHolderFont = UIFont.init(name: "Avenir-Roman", size: 14.0)
        txtfield.textColor = .black
        txtfield.placeholderColor = kSchoolThemeColor
        txtfield.adjustsFontForContentSizeCategory = true
        
    }
    func invalidTextField(textField:TweeActiveTextField){
        textField.placeholderColor = .red
        textField.invalideField()
    }
    func validTextField(textField:TweeActiveTextField){
        textField.placeholderColor = kSchoolThemeColor
    }
    func isValidRemark()->Bool{
       
        guard "\(self.addRemarkParameters[kStudentID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldStudent)
                ShowToast.show(toatMessage: "Please select students.")
            }
            return false
        }
        /*
         fileprivate var kRemarkCatID = "remark_category_id"
         fileprivate var kRemarkName = "remark_name"
         fileprivate var kRemarkType = "remark_type"
         fileprivate var kRemarkDate = "remark_date"
         fileprivate var kDescription = "note"
         */
        guard "\(self.addRemarkParameters[kRemarkCatID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldDate)
                
                ShowToast.show(toatMessage: "Please select notice date.")
            }
            return false
        }
        guard "\(self.addRemarkParameters[kRemarkCatID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldRemarkCategory)
                
                ShowToast.show(toatMessage: "Please select remark category.")
            }
            return false
        }
        guard "\(self.addRemarkParameters[kRemarkName] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldRemarkName)
                
                ShowToast.show(toatMessage: "Please select remark name.")
            }
            return false
        }
        /*
        guard "\(self.addRemarkParameters[kRemarkType] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldRemarkType)
                
                ShowToast.show(toatMessage: "Please select remark type.")
            }
            return false
        }*/
        guard "\(self.addRemarkParameters[kRemarkDate] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldDate)
                
                ShowToast.show(toatMessage: "Please select remark date.")
            }
            return false
        }
        return true
    }
    
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
        //        SideMenu.show()
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        print(self.addRemarkParameters)
        self.createRemarkAPIRequest()
    }
    // MARK: - API Request

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
    func getCategoryRequest(){
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kGetRemarkCategory, parameter:nil,isHudeShow: false,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfCategory = success["data"] as? [[String:Any]]{
                self.arrayOfRemarkCategory.removeAll()
                for objCategoryDict in arrayOfCategory{
                    if let name = objCategoryDict["name"],let status = objCategoryDict["status"],let catID = objCategoryDict["remarks_category_id"]{
                        let objCate = RemarkCategory.init(id: "\(catID)", name: "\(name)", status: "\(status)")
                        self.arrayOfRemarkCategory.append(objCate)
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
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetStudentByClass, parameter:studentParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
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
    func getCategoryNameBasedOnCategory(categoryID:String){
        var studentParameters:[String:Any] = [:]
        
        studentParameters["remarks_category_id"] = categoryID
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kGetRemarkNameByCategory, parameter:studentParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayRemark = success["data"] as? [[String:Any]]{
                self.arrayOfRemark.removeAll()
                for var objRemark:[String:Any] in arrayRemark{
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objRemark, options:.prettyPrinted)
                        
                        if let remark = try? JSONDecoder().decode(StudentRemarkUpdate.self, from: jsondata){
                            self.arrayOfRemark.append(remark)
                        }
                    }catch{
                        print(error.localizedDescription)
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
    //kCreateRemark
    func createRemarkAPIRequest(){
        if self.isValidRemark(){
            APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kCreateRemark, parameter:self.addRemarkParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
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
        
    }
    func sizeHeaderFit(){
        if let headerView =  self.tableViewAddRemark.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableViewAddRemark.tableHeaderView = headerView
            self.view.layoutIfNeeded()
        }
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewAddRemark.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewAddRemark.tableFooterView = footerView
            self.view.layoutIfNeeded()
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func presentSearchViewController(){
        DispatchQueue.main.async {
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = .SchoolClass
                schoolClassPicker.arrayclassOptions = self.classOptions
                self.view.endEditing(true)
                schoolClassPicker.delegate = self
                schoolClassPicker.isSingleSelection = true
                if let _ = self.arrayOfSelectedClass{
                    schoolClassPicker.selectedSchoolClass = NSMutableSet.init(array:self.arrayOfSelectedClass!.map{$0.strClassId})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
    func presentStudentPickerViewController(objSearchType:SearchType){
        DispatchQueue.main.async {
            if let schoolClassPicker = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController{
                schoolClassPicker.modalPresentationStyle = .overFullScreen
                schoolClassPicker.objSearchType = objSearchType
                if objSearchType == .SchoolClass{
                    schoolClassPicker.arrayclassOptions = self.classOptions
                    schoolClassPicker.isSingleSelection = true
                    if let _ = self.arrayOfSelectedClass{
                        schoolClassPicker.selectedSchoolClass = NSMutableSet.init(array:self.arrayOfSelectedClass!.map{$0.strClassId})
                    }
                }else if objSearchType == .ClassStudent{
                    schoolClassPicker.arrayOfStudentOptions = self.arrayOfStudent
                    schoolClassPicker.isSingleSelection = false
                    if  self.arrayOfSelectedStudent.count > 0{
                        schoolClassPicker.selectedStudent = NSMutableSet.init(array:self.arrayOfSelectedStudent.map{$0.studentID})
                    }
                }else if objSearchType == .CategoryType{
                    schoolClassPicker.isSingleSelection = true
                    schoolClassPicker.arrayOfRemarkCategory = self.arrayOfRemarkCategory
                    if  self.arrayOfSelectedCategory.count > 0{
                        schoolClassPicker.selectedRemarkCategory = NSMutableSet.init(array:self.arrayOfSelectedCategory.map{$0.id})
                    }
                }else if objSearchType == .CategotyName{
                    schoolClassPicker.isSingleSelection = true
                    schoolClassPicker.arrayOfRemark = self.arrayOfRemark
                    if  self.arrayOfSelectedRemark.count > 0{
                        schoolClassPicker.selectedRemark = NSMutableSet.init(array:self.arrayOfSelectedRemark.map{$0.remarkID})
                    }
                }
                
                self.view.endEditing(true)
                schoolClassPicker.delegate = self
                
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
   

}
extension AddRemarkViewController:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        if searchType == .SchoolClass{
            if let arrayOfClass = values as? [SchoolClass]{
                
                let objArray = arrayOfClass.map{$0.strName}
                let objArrayId = arrayOfClass.map{$0.strClassId}
               
                self.validTextField(textField: self.txtFeildClass)
                if objArray.count > 0{
                    self.arrayOfSelectedClass = arrayOfClass
                    self.txtViewClass.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildClass.minimizePlaceholder()
                    self.getStudentListBasedOnClass(classId: objArrayId[0])
                    self.addRemarkParameters[kStudentID] = ""
                    self.arrayOfSelectedStudent = []
                    self.txtViewStudent.text = ""
                    self.txtFieldStudent.maximizePlaceholder()
                }else{
                    self.arrayOfSelectedClass = []
                    self.txtViewClass.text = ""
                    self.txtFeildClass.maximizePlaceholder()
                }
            }

        }else if searchType == .ClassStudent{
            if let objarrayOfStudent = values as? [SchoolStudent]{
                
                let objArray = objarrayOfStudent.map{$0.fullName}
                let objArrayId = objarrayOfStudent.map{$0.studentID}
               
                self.validTextField(textField: self.txtFieldStudent)
                if objArray.count > 0{
                    self.arrayOfSelectedStudent = objarrayOfStudent
                    self.txtViewStudent.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFieldStudent.minimizePlaceholder()
                    self.addRemarkParameters[kStudentID] = "\(objArrayId.joined(separator: ", "))"
                }else{
                    self.addRemarkParameters[kStudentID] = ""
                    self.arrayOfSelectedStudent = []
                    self.txtViewStudent.text = ""
                    self.txtFieldStudent.maximizePlaceholder()
                }
            }
        }else if searchType == .CategoryType{
            if let objArrayCate = values as? [RemarkCategory]{
                
                let objArray = objArrayCate.map{$0.name}
                let objArrayId = objArrayCate.map{$0.id}
                
                self.validTextField(textField: self.txtFieldRemarkCategory)
                if objArray.count > 0{
                    self.arrayOfSelectedCategory = objArrayCate
                    self.txtViewRemarkCategory.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFieldRemarkCategory.minimizePlaceholder()
                    self.addRemarkParameters[kRemarkCatID] = "\(objArrayId.first!)"
                    self.getCategoryNameBasedOnCategory(categoryID: "\(objArrayId.first!)")
                    self.addRemarkParameters[kRemarkName] = ""
                    self.arrayOfSelectedRemark = []
                    self.txtViewRemarkName.text = ""
                    self.txtFieldRemarkName.maximizePlaceholder()
                }else{
                    self.addRemarkParameters[kRemarkCatID] = ""
                    self.arrayOfSelectedCategory = []
                    self.txtViewRemarkCategory.text = ""
                    self.txtFieldRemarkCategory.maximizePlaceholder()
                }
            }
        }else if searchType == .CategotyName{
            if let objArrayCate = values as? [StudentRemarkUpdate]{
                
                let objArray = objArrayCate.map{$0.remarkName}
                let objArrayId = objArrayCate.map{$0.remarkID}
                
                self.validTextField(textField: self.txtFieldRemarkName)
                if objArray.count > 0{
                    self.arrayOfSelectedRemark = objArrayCate
                    self.txtViewRemarkName.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFieldRemarkName.minimizePlaceholder()
                    self.addRemarkParameters[kRemarkName] = "\(objArrayId.first!)"
//                    self.getCategoryNameBasedOnCategory(categoryID: "\(objArrayId.first!)")
                }else{
                    self.addRemarkParameters[kRemarkName] = ""
                    self.arrayOfSelectedRemark = []
                    self.txtViewRemarkName.text = ""
                    self.txtFieldRemarkName.maximizePlaceholder()
                }
            }
        }
        defer {
            self.sizeHeaderFit()
        }
    }
}
extension AddRemarkViewController:UITextFieldDelegate{
    
}
extension AddRemarkViewController:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == self.txtViewStudent{
            if let array = self.arrayOfSelectedClass,array.count > 0{
                return true
            }else{
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFeildClass)
                    ShowToast.show(toatMessage: "Please select class to add remark.")
                }
                return false
            }
        }else if textView == self.txtViewRemarkName{
            if self.arrayOfSelectedCategory.count > 0{
                return true
            }else{
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFieldRemarkCategory)
                    ShowToast.show(toatMessage: "Please select remark category to add remark.")
                }
                return false
            }
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == self.txtViewClass{
            self.txtFeildClass.resignFirstResponder()
            self.txtFeildClass.minimizePlaceholder()
            self.txtViewClass.resignFirstResponder()
            //PreesntClass Picker
            self.presentStudentPickerViewController(objSearchType: .SchoolClass)
        }else if textView == self.txtViewStudent{
            self.txtFieldStudent.resignFirstResponder()
            self.txtFieldStudent.minimizePlaceholder()
            self.txtViewStudent.resignFirstResponder()
            //PreesntClass Picker
            self.presentStudentPickerViewController(objSearchType: .ClassStudent)
        }else if textView == self.txtViewRemarkCategory{
            self.txtFieldRemarkCategory.resignFirstResponder()
            self.txtFieldRemarkCategory.minimizePlaceholder()
            self.txtViewRemarkCategory.resignFirstResponder()
            //PreesntClass Picker
            self.presentStudentPickerViewController(objSearchType: .CategoryType)
            
        }else if textView == self.txtViewRemarkName{
            self.txtFieldRemarkName.resignFirstResponder()
            self.txtFieldRemarkName.minimizePlaceholder()
            self.txtViewRemarkName.resignFirstResponder()
            //PreesntClass Picker
            self.presentStudentPickerViewController(objSearchType: .CategotyName)
        }else if textView == self.txtViewDescription{
            self.txtFeildDescription.resignFirstResponder()
            self.txtFeildDescription.minimizePlaceholder()
            textView.becomeFirstResponder()
        }
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
        }else if textView == self.txtViewStudent{
            if textView.text.count == 0{
                self.txtFieldStudent.resignFirstResponder()
                self.txtFieldStudent.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFieldStudent.minimizePlaceholder()
            }
        }else if textView == self.txtViewRemarkCategory{
            if textView.text.count == 0{
                self.txtFieldRemarkCategory.resignFirstResponder()
                self.txtFieldRemarkCategory.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFieldRemarkCategory.minimizePlaceholder()
            }
        }else if textView == self.txtViewRemarkName{
            if textView.text.count == 0{
                self.txtFieldRemarkName.resignFirstResponder()
                self.txtFieldRemarkName.maximizePlaceholder()
                textView.resignFirstResponder()
            }else{
                self.txtFieldRemarkName.minimizePlaceholder()
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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.txtViewDescription{
            self.addRemarkParameters[kDescription] = "\(typpedString)"
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
extension AddRemarkViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.RemarkTypePicker{
            return self.arrayOfRemarkType[row]
        }else{
            return nil
        }
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.RemarkTypePicker{
            return self.arrayOfRemarkType.count
        }else{
            return 0
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.RemarkTypePicker{
            self.currentRemarkType = self.arrayOfRemarkType[row]
        }
    }
}
struct RemarkCategory {
    var id,name,status:String
}
