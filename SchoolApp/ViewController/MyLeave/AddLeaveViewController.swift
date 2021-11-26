//
//  AddLeaveViewController.swift
//  SchoolApp
//
//  Created by user on 26/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddLeaveViewController: UIViewController {

    //navigation
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var navigationView:UIView!
    
    
    //new leave
    @IBOutlet var lblFromDate:UILabel!
    @IBOutlet var txtFromDate:UITextField!
    @IBOutlet var containerViewFormDate:UIView!
    
    @IBOutlet var lblToDate:UILabel!
    @IBOutlet var txtToDate:UITextField!
    @IBOutlet var containerViewToDate:UIView!
    
    @IBOutlet var lblTotalDays:UILabel!
    
    @IBOutlet var lblLeaveType:UILabel!
    @IBOutlet var txtLeaveType:UITextField!
    @IBOutlet var containerViewLeaveType:UIView!
    
    @IBOutlet var lbDescription:UILabel!
    @IBOutlet var txtDescription:UITextView!
    
    @IBOutlet var buttonSubmit:UIButton!
    
 
    
    
    var fromDatePicker:UIDatePicker = UIDatePicker()
    var fromDatePickerToolbar:UIToolbar = UIToolbar()
    
    var toDatePicker:UIDatePicker = UIDatePicker()
    var toDatePickerToolbar:UIToolbar = UIToolbar()
    
    var leaveTypePicker:UIPickerView = UIPickerView()
    var leaveTypePickerToolBar:UIToolbar = UIToolbar()
    
    var arrayOfLeaveType:[LeaveType] = []
    
    var currentLeaveType:LeaveType?
    
    var addLeaveAPIRequestParameter:[String:Any] = [:]
    
    var isToDateSelected:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()
        if let user = User.getUserFromUserDefault(){
            self.addLeaveAPIRequestParameter["user_id"] = user.userId
            self.getLeaveTypeAPIRequest(userID: user.userId)
        }
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.AddLeave")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        let formDateTap = UITapGestureRecognizer(target: self, action: #selector(AddLeaveViewController.formDateSelector))
        self.containerViewFormDate.addGestureRecognizer(formDateTap)
        
        let toDateTap = UITapGestureRecognizer(target: self, action: #selector(AddLeaveViewController.toDateSelector))
        self.containerViewToDate.addGestureRecognizer(toDateTap)
        
        let leaveTypeTap = UITapGestureRecognizer(target: self, action: #selector(AddLeaveViewController.leaveTypeSelector))
        self.containerViewLeaveType.addGestureRecognizer(leaveTypeTap)

        self.buttonSubmit.setTitleColor(UIColor.white, for: .normal)
        self.buttonSubmit.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
//        self.buttonSubmit.setTitle(Vocabulary.getWordFromKey(key: "Add Leave"), for: .normal)
        
        self.txtDescription.text = ""
        
        self.configureFormDatePicker()
        
        self.configureToDatePicker()
        
        self.configureLeaveTypePicker()
        
    }
    private func calculateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    func configureFormDatePicker(){
        
        self.fromDatePickerToolbar.sizeToFit()
        self.fromDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.fromDatePickerToolbar.layer.borderWidth = 1.0
        self.fromDatePickerToolbar.clipsToBounds = true
        self.fromDatePickerToolbar.backgroundColor = UIColor.white
        self.fromDatePicker.datePickerMode = .date
        self.fromDatePicker.minimumDate = Date()
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"From Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.cancelFormDatePicker))
        self.fromDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtFromDate.inputView = self.fromDatePicker
        self.txtFromDate.inputAccessoryView = self.fromDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        let date =  self.fromDatePicker.date
        guard self.isToDateSelected else {
           self.txtFromDate.text = date.ddMMyyyy
            self.addLeaveAPIRequestParameter["from_date"] = date.mmddyyyy
            DispatchQueue.main.async {
                self.txtFromDate.resignFirstResponder()
            }
            return
        }
        var updateDays = self.calculateDaysBetweenTwoDates(start: self.fromDatePicker.date, end: self.toDatePicker.date)
        
        let days = Calendar.current.dateComponents([.day], from: self.fromDatePicker.date
            , to:   self.toDatePicker.date)
        guard updateDays >= 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Please select proper from date")
            }
            return
        }
        updateDays += 1
        self.lblTotalDays.text = "Total Days: \(updateDays)"
        self.txtFromDate.text = date.ddMMyyyy
        self.addLeaveAPIRequestParameter["from_date"] = date.mmddyyyy
        
//        if var totalDays = days.day{
//            totalDays += 1
//            if self.fromDatePicker.date.mmddyyyy == self.toDatePicker.date.mmddyyyy{
//                self.lblTotalDays.text = "Total Days: \(updateDays)"
//            }else{
//                totalDays += 1
//                self.lblTotalDays.text = "Total Days: \(updateDays)"
//            }
//        }
        
        
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            if let objText = self.txtFromDate.text,objText.count == 0{
                self.fromDatePicker.date = Date()
            }
            if let objText = self.txtToDate.text,objText.count == 0{
                self.toDatePicker.date = Date()
            }
            self.view.endEditing(true)
        }
    }
    func configureToDatePicker(){
        self.toDatePickerToolbar.sizeToFit()
        self.toDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.toDatePickerToolbar.layer.borderWidth = 1.0
        self.toDatePickerToolbar.clipsToBounds = true
        self.toDatePickerToolbar.backgroundColor = UIColor.white
        self.toDatePicker.datePickerMode = .date
        self.toDatePicker.minimumDate = Date()
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.doneToDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"To Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.cancelFormDatePicker))
        self.toDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtToDate.inputView = self.toDatePicker
        self.txtToDate.inputAccessoryView = self.toDatePickerToolbar
    }
    @objc func doneToDatePicker(){
        self.isToDateSelected = true
        let date =  self.toDatePicker.date
        var updateDays = self.calculateDaysBetweenTwoDates(start: self.fromDatePicker.date, end: self.toDatePicker.date)
        guard updateDays >= 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Please select proper to date")
            }
            return
        }
        updateDays += 1
        self.lblTotalDays.text = "Total Days: \(updateDays)"

//        let days = Calendar.current.dateComponents([.day], from: self.fromDatePicker.date
//            , to:   self.toDatePicker.date)
//        guard days.day! >= 0 else {
//            DispatchQueue.main.async {
//                ShowToast.show(toatMessage: "Please select proper to date")
//            }
//            return
//        }
        self.txtToDate.text = date.ddMMyyyy
        self.addLeaveAPIRequestParameter["to_date"] = date.mmddyyyy
//        if var totalDays = days.day{
//            totalDays += 1
//            if self.fromDatePicker.date.mmddyyyy == self.toDatePicker.date.mmddyyyy{
//                self.lblTotalDays.text = "Total Days: \(updateDays)"
//            }else{
//                totalDays += 1
//                self.lblTotalDays.text = "Total Days: \(updateDays)"
//            }
//            
//        }
        
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func configureLeaveTypePicker(){
        self.leaveTypePickerToolBar.sizeToFit()
        self.leaveTypePickerToolBar.layer.borderColor = UIColor.clear.cgColor
        self.leaveTypePickerToolBar.layer.borderWidth = 1.0
        self.leaveTypePickerToolBar.clipsToBounds = true
        self.leaveTypePickerToolBar.backgroundColor = UIColor.white
        self.leaveTypePicker.delegate = self
        self.leaveTypePicker.dataSource = self
        
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.doneLeaveTypePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Leave Type"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddLeaveViewController.cancelFormDatePicker))
        self.leaveTypePickerToolBar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtLeaveType.inputView = self.leaveTypePicker
        self.txtLeaveType.inputAccessoryView = self.leaveTypePickerToolBar
    }
    @objc func doneLeaveTypePicker(){
        if let _ = self.currentLeaveType{
            self.txtLeaveType.text = self.currentLeaveType!.displayName
            self.addLeaveAPIRequestParameter["leave_type_id"] = self.currentLeaveType!.leaveTypeID
        }
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    func isValidAddLeave()->Bool{
        
        guard "\(self.addLeaveAPIRequestParameter["from_date"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtFromDate.invalideField()
                ShowToast.show(toatMessage: "Please select from date.")
            }
            return false
        }
        guard "\(self.addLeaveAPIRequestParameter["to_date"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtToDate.invalideField()
                ShowToast.show(toatMessage: "Please select to date.")
            }
            return false
        }
        guard "\(self.addLeaveAPIRequestParameter["leave_type_id"] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.txtLeaveType.invalideField()
                ShowToast.show(toatMessage: "Please select leave type.")
            }
            return false
        }
        self.addLeaveAPIRequestParameter["description"] = self.txtDescription.text
        self.txtFromDate.validField()
        self.txtToDate.validField()
        self.txtLeaveType.validField()
        return true
        
    }
    // MARK: - Selector Methods
    @IBAction func formDateSelector(){
        self.txtFromDate.becomeFirstResponder()
    }
     @IBAction  func toDateSelector(){
        self.txtToDate.becomeFirstResponder()
    }
     @IBAction  func leaveTypeSelector(){
        self.txtLeaveType.becomeFirstResponder()
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        self.addLeaveAPIRequest()
    }
    // MARK: - API Request Methods
    func addLeaveAPIRequest(){
        if self.isValidAddLeave(){
            APIRequestClient.shared.uploadImage(requestType: .POST, queryString:kAddStudentLeave , parameter: self.addLeaveAPIRequestParameter as [String:AnyObject], imageData: nil, isHudeShow: true, success: { (responseSuccess) in
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                if let success = responseSuccess as? [String:Any],let strMSG = success["message"]{
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                        ShowToast.show(toatMessage: "\(strMSG)")
                    }
                }
            }) { (responseFail) in
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage: "\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }
        }
    }
    func getLeaveTypeAPIRequest(userID:String){
        
        APIRequestClient.shared.sendRequest(requestType: .GET, queryString:kStudentLeaveType, parameter:nil,isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfLeave = success["data"] as? [[String:Any]]{
                self.arrayOfLeaveType.removeAll()
                for var objLeave:[String:Any] in arrayOfLeave{
                    objLeave.updateJSONNullToString()
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:objLeave, options:.prettyPrinted)
                        if let leveType = try? JSONDecoder().decode(LeaveType.self, from: jsondata){
                            self.arrayOfLeaveType.append(leveType)
                        }
                    }catch{
                        
                    }
                }
                DispatchQueue.main.async {
                    if self.arrayOfLeaveType.count > 0{
                        self.currentLeaveType = self.arrayOfLeaveType.first!
                    }
                    self.leaveTypePicker.reloadAllComponents()
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
   

}
extension AddLeaveViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arrayOfLeaveType[row].displayName
       
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return UIScreen.main.bounds.width
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30.0
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arrayOfLeaveType.count
       
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currentLeaveType = self.arrayOfLeaveType[row]
    }
}
class LeaveType: Codable {
    let leaveTypeID, name, displayName, isDocumentRequired: String
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case leaveTypeID = "leave_type_id"
        case name
        case displayName = "display_name"
        case isDocumentRequired = "is_document_required"
        case status
    }
    
    init(leaveTypeID: String, name: String, displayName: String, isDocumentRequired: String, status: String) {
        self.leaveTypeID = leaveTypeID
        self.name = name
        self.displayName = displayName
        self.isDocumentRequired = isDocumentRequired
        self.status = status
    }
}
