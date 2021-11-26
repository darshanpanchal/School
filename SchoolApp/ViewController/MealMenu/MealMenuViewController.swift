//
//  FeesViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import QuickLook

class MealMenuViewController: UIViewController {
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
    
    @IBOutlet var tableViewMealMenu:UITableView!
    var arrayOfMealMenu:[MealDetailUpdate] = []
    
    @IBOutlet var buttonSelectDate:UIButton!
    @IBOutlet var txtMealDate:UITextField!
    
    var mealDatePicker:UIDatePicker = UIDatePicker()
    var mealDatePickerToolbar:UIToolbar = UIToolbar()
    
    var mealMonthYearPicker:MonthYearPickerView = MonthYearPickerView()
    
     var previewItem:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mealDatePicker.date = Date()
        let objMonth = DateFormatter().monthSymbols[self.mealMonthYearPicker.month-1].capitalized
        self.txtMealDate.text = "\(objMonth)" + "-" + "\(self.mealMonthYearPicker.year)"//self.mealDatePicker.date.ddMMyyyy
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureMealMenuTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getMealAPIRequest(userID: user.userId, date: self.mealMonthYearPicker.getMMYYYY())
        }
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.mealmenu")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.txtMealDate.backgroundColor = kSchoolThemeColor
        self.txtMealDate.textColor = UIColor.white
        self.txtMealDate.font = UIFont.boldSystemFont(ofSize: 17.0)
        self.txtMealDate.placeholder = "Select Month/Year"
        self.configureMealDatePicker()
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
    func configureMealDatePicker(){
        
        self.mealDatePickerToolbar.sizeToFit()
        self.mealDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.mealDatePickerToolbar.layer.borderWidth = 1.0
        self.mealDatePickerToolbar.clipsToBounds = true
        self.mealDatePickerToolbar.backgroundColor = UIColor.white
        self.mealDatePicker.datePickerMode = .date
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        self.mealDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MealMenuViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Month-Year"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(MealMenuViewController.cancelFormDatePicker))
        self.mealDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        self.txtMealDate.inputView = self.mealMonthYearPicker//self.mealDatePicker
        self.txtMealDate.inputAccessoryView = self.mealDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        let date = self.mealDatePicker.date
        if let user = User.getUserFromUserDefault(){
            let objMonth = DateFormatter().monthSymbols[self.mealMonthYearPicker.month-1].capitalized
            self.txtMealDate.text = "\(objMonth)" + "-" + "\(self.mealMonthYearPicker.year)"//date.ddMMyyyy
            self.getMealAPIRequest(userID: user.userId, date: self.mealMonthYearPicker.getMMYYYY())
        }
        //dismiss date picker dialog
        DispatchQueue.main.async {
            self.txtMealDate.resignFirstResponder()
            self.view.endEditing(true)
        }
    }
    @objc func cancelFormDatePicker(){
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
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
    func configureMealMenuTableView(){
        // self.tableViewMealMenu.tableHeaderView = self.tableViewHeaderView
        self.tableViewMealMenu.rowHeight = UITableView.automaticDimension
        self.tableViewMealMenu.estimatedRowHeight = 100.0
        self.tableViewMealMenu.delegate = self
        self.tableViewMealMenu.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewMealMenu.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewMealMenu.separatorStyle = .none
        self.tableViewMealMenu.isScrollEnabled = true
        self.tableViewMealMenu.reloadData()
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
    @IBAction func buttonSelectDateSelector(sender:UIButton){
        self.txtMealDate.becomeFirstResponder()
    }
    // MARK: - API Request Methods
    func getMealAPIRequest(userID:String,date:String){
        let mealParameters:[String:Any] = ["user_id":"\(userID)","month":"\(date)"]
        
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kStudentMealDetail, parameter:mealParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            
            if let success = responseSuccess as? [String:Any],let arrayMeal = success["data"] as? [[String:Any]]{
                    
                    self.arrayOfMealMenu.removeAll()
                    for var objMeal:[String:Any] in arrayMeal{
                        var mealData = MealDetailUpdate.init(file_path: "\(objMeal["file_path"] ?? "")", meal_date: "\(objMeal["meal_date"] ?? "")", meal_file: "\(objMeal["meal_file"] ?? "")", meal_id: "\(objMeal["meal_id"] ?? "")", attachmenttype: "\(objMeal["attachmenttype"] ?? "")")
                        print(mealData.meal_file.fileExtension())
                        mealData.attachmenttype = "\(mealData.meal_file.fileExtension())"
                        self.arrayOfMealMenu.append(mealData)
                        /*
                        objMeal.updateJSONNullToString()
                        do {
                            let jsondata = try JSONSerialization.data(withJSONObject:objMeal, options:.prettyPrinted)
                            if let mealData = try? JSONDecoder().decode(MealDetail.self, from: jsondata){
                                self.arrayOfMealMenu.append(mealData)
                            }
                        }catch{
                            
                        }*/
                    }
                    DispatchQueue.main.async {
                        self.tableViewMealMenu.reloadData()
                    }
                }
            }) { (responseFail) in
                
                
                DispatchQueue.main.async {
                    self.arrayOfMealMenu.removeAll()
                    self.tableViewMealMenu.reloadData()
                    ProgressHud.hide()
                }
                if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:"\(errorMessage)")
                    }
                }else{
                    DispatchQueue.main.async {
                        ShowToast.show(toatMessage:kCommonError)
                    }
                }
            }
        
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension MealMenuViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewMealMenu{
           
            if self.arrayOfMealMenu.count == 0{
                tableView.showMessageLabel(msg: "No meal details available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfMealMenu.count
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewMealMenu{
                let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
                if self.arrayOfMealMenu.count > indexPath.row{
                    let objMeal:MealDetailUpdate = self.arrayOfMealMenu[indexPath.row]
                    homeworkCell.lblHomeWorkDetail.text = objMeal.meal_file
                    homeworkCell.lblHomeWorkDate.text = objMeal.meal_date
                    homeworkCell.attachMentImageView.isHidden = !(objMeal.attachmenttype.count > 0)
                    if objMeal.attachmenttype == "pdf"{
                        homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_pdf_icon")
                    }else if objMeal.attachmenttype == "doc" || objMeal.attachmenttype == "docx"{
                        homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_doc")
                    }else{
                        homeworkCell.attachMentImageView.image = UIImage.init(named: "ic_image_icon")
                    }
                }
                homeworkCell.shadowView.isHidden = false
                homeworkCell.separatorInset = UIEdgeInsets.zero
                homeworkCell.layoutMargins = UIEdgeInsets.zero
            
                return homeworkCell
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
        if tableView == self.tableViewMealMenu{
            return UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewMealMenu{
            if self.arrayOfMealMenu.count > indexPath.row{
                let objMealUpdate = self.arrayOfMealMenu[indexPath.row]
                self.presentPDFInQuickLook(strURL: objMealUpdate.file_path)
            }
            
        }else{
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
    func presentPDFInQuickLook(strURL:String){
       
        guard strURL.count > 0 else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "No attachment available.")
            }
            return
        }
        APIRequestClient.shared.saveFileFromURL(urlString: "\(strURL)") { (path) in
            DispatchQueue.main.async {
                self.previewItem = NSURL.init(string: "\(path)")
                let previewController = QLPreviewController()
                previewController.dataSource = self
                previewController.delegate = self
                previewController.currentPreviewItemIndex = 0
                self.present(previewController, animated: true, completion: {
                    UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
                })
                
            }
        }
    }
}
struct MealDetailUpdate {
    var file_path,meal_date,meal_file,meal_id,attachmenttype:String
}
struct MealDetail: Codable {
    let mealType, mealDetails, mealDate: String
    
    enum CodingKeys: String, CodingKey {
        case mealType = "meal_type"
        case mealDetails = "meal_details"
        case mealDate = "meal_date"
    }
    init (from decoder:Decoder) throws{
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.mealType = try values.decodeIfPresent(String.self, forKey: .mealType) ?? ""
        self.mealDetails = try values.decodeIfPresent(String.self, forKey: .mealDetails) ?? ""
        self.mealDate = try values.decodeIfPresent(String.self, forKey: .mealDate) ?? ""
    }
}
//Create Custom Month and year Picker for meal menu update
class MonthYearPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var months: [String]!
    var years: [Int]!
    
    var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            selectRow(month-1, inComponent: 0, animated: false)
        }
    }
    
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            selectRow(years.index(of: year)!, inComponent: 1, animated: true)
        }
    }
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    
        
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        // population years
        var years: [Int] = []
        if years.count == 0 {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            
            for currentIndex in year-2...year+2{
                years.append(currentIndex)
            }
        }
        self.years = years.sorted()
        
        // population months with localized names
        var months: [String] = []
        var month = 0
        for _ in 1...12 {
            months.append(DateFormatter().monthSymbols[month].capitalized)
            month += 1
        }
        self.months = months
        
        self.delegate = self
        self.dataSource = self
        
        let currentMonth = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.month, from: NSDate() as Date)
        self.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        self.selectRow(self.years.index(of: self.year)!, inComponent: 1, animated: true)
        
    }
    
    // Mark: UIPicker Delegate / Data Source
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return months[row]
        case 1:
            return "\(years[row])"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return months.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let month = self.selectedRow(inComponent: 0)+1
        let year = years[self.selectedRow(inComponent: 1)]
        if let block = onDateSelected {
            block(month, year)
        }
        
        self.month = month
        self.year = year
    }
    
}
extension MonthYearPickerView{
    func getMMYYYY() -> String{
        return "\(self.month)/\(self.year)"
    }
}
extension MealMenuViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        if let _ = previewItem{
            return self.previewItem!
        }else{
            return URL.init(fileURLWithPath:"") as QLPreviewItem
        }
        
    }
    
}
