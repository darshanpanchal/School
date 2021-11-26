//
//  AttendanceViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import FSCalendar

class AttendanceViewController: UIViewController {

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
    var arrayOfUserDetail:[NSManagedObject] = []
    
    
    @IBOutlet var objCalender:FSCalendar!
    @IBOutlet var btnNext:UIButton!
    @IBOutlet var btnPrevious:UIButton!
    
    //monthly detail
    @IBOutlet var lblMonthlyDetail:UILabel!
    @IBOutlet var lblMonthPresentDays:UILabel!
    @IBOutlet var lblMonthPresentDaysValue:UILabel!
    @IBOutlet var lblMonthHoliDays:UILabel!
    @IBOutlet var lblMonthHoliDaysValue:UILabel!
    @IBOutlet var lblMonthAbsentDays:UILabel!
    @IBOutlet var lblMonthAbsentDaysValue:UILabel!
    @IBOutlet var lblMonthLeaveDays:UILabel!
    @IBOutlet var lblMonthLeaveDaysValue:UILabel!
    
    //Yearly detail
    @IBOutlet var lblYearlyDetail:UILabel!
    @IBOutlet var lblTotalWorkingDays:UILabel!
    @IBOutlet var lblTotalWorkingDaysValue:UILabel!
    @IBOutlet var lblTotalPresentDays:UILabel!
    @IBOutlet var lblTotalPresentDaysValue:UILabel!
    @IBOutlet var lblTotalAnnualPercentage:UILabel!
    @IBOutlet var lblTotalAnnualPercentageValue:UILabel!
    
    //color hint
    @IBOutlet var absentHintColorView:UIView!
    @IBOutlet var absentHintLable:UILabel!
    @IBOutlet var holidayHintColorView:UIView!
    @IBOutlet var holidayHintLable:UILabel!
    @IBOutlet var presentHintColorView:UIView!
    @IBOutlet var presentHintLable:UILabel!
    @IBOutlet var leaveHintColorView:UIView!
    @IBOutlet var leaveHintLable:UILabel!
    
    @IBOutlet var tableViewAttendance:UITableView!
    
    
    fileprivate let kHolidayColor:UIColor = UIColor.blue
    fileprivate let kLeaveColor:UIColor = UIColor.rgb(237, green: 198, blue: 0)
    fileprivate let kAbsentColor:UIColor = UIColor.red
    fileprivate let kPresentColor:UIColor = UIColor.green
    
    var setOfSatSunday:NSMutableSet = NSMutableSet()
    var setOfHoliday:NSMutableSet = NSMutableSet()
    var setOfAbsent:NSMutableSet = NSMutableSet()
    var setOfLeave:NSMutableSet = NSMutableSet()
    var arrayOfHoliday:[Holiday] = []
    var arrayOfLeave:[Leave] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
        }
        self.configureFSCalender()
        if let user = User.getUserFromUserDefault(){
            self.getAttendanceAPIRequest(userID: user.userId, currentMonth: Date().mmddyyyy)
        }
    }
    // MARK: - Custom Methods
    func configureFSCalender(){
        self.objCalender.dataSource = self
        self.objCalender.delegate = self
        self.objCalender.placeholderType = .none
        self.objCalender.appearance.titleFont = UIFont.init(name:"Avenir-Roman", size: 14.0)
        self.objCalender.appearance.headerTitleFont = UIFont.init(name: "Avenir-Heavy", size: 17.0)
        self.objCalender.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14.0)
        self.configureNextMonthSelector()
        self.objCalender.adjustMonthPosition()
        self.objCalender.appearance.selectionColor = kSchoolThemeColor
        self.objCalender.reloadInputViews()
        
    }
    func setUpView(){
        self.tableViewAttendance.tableFooterView = UIView()
        
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.Attenndance")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.presentHintLable.text = Vocabulary.getWordFromKey(key:"genral.Present")
        self.absentHintLable.text = Vocabulary.getWordFromKey(key:"genral.Absent")
        self.holidayHintLable.text = Vocabulary.getWordFromKey(key:"Holiday")
        self.leaveHintLable.text = Vocabulary.getWordFromKey(key:"genral.leave")
        self.absentHintColorView.backgroundColor = kAbsentColor
        self.holidayHintColorView.backgroundColor = kHolidayColor
        self.presentHintColorView.backgroundColor = kPresentColor
        self.leaveHintColorView.backgroundColor = kLeaveColor
        
        self.lblMonthlyDetail.text =  Vocabulary.getWordFromKey(key:"genral.monthly")
        self.lblYearlyDetail.text =  Vocabulary.getWordFromKey(key:"genral.yearly")
        
        self.lblMonthPresentDays.text =  Vocabulary.getWordFromKey(key:"Present Days")
        self.lblMonthHoliDays.text =  Vocabulary.getWordFromKey(key:"genral.holiday")
        self.lblMonthLeaveDays.text =  Vocabulary.getWordFromKey(key:"genral.leavDays")
        self.lblMonthAbsentDays.text =  Vocabulary.getWordFromKey(key:"genral.AbsentDays")
        
        self.lblTotalWorkingDays.text = Vocabulary.getWordFromKey(key:"genral.TotalWorkingDays")
        self.lblTotalPresentDays.text = Vocabulary.getWordFromKey(key:"genral.presentDays")
        self.lblTotalAnnualPercentage.text = Vocabulary.getWordFromKey(key:"genral.annualPercentage")
        
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
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
    // MARK: - API Request Methods
    func getAttendanceAPIRequest(userID:String,currentMonth:String){
        let attendanceParameters = ["user_id":"\(userID)","month":"\(currentMonth)"]
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kStudentAttendance, parameter:attendanceParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            print(responseSuccess)
            if let success = responseSuccess as? [String:Any],let attendanceData = success["data"] as? [String:Any]{
                if let date = self.objCalender.formatter.date(from:"2019-03-03"){
                    print(date.mmddyyyy)
                }
                
                if let arrayOfSatSunday = attendanceData["sat_sun"] as? [String]{
                    self.setOfSatSunday.addObjects(from:arrayOfSatSunday.compactMap{$0.changeDateFormateMMddYYYY})
                    
                }
                if let arrayHoliday = attendanceData["holidays"] as? [[String:Any]]{
                    self.arrayOfHoliday.removeAll()
                    self.arrayOfHoliday = arrayHoliday.compactMap{Holiday.init(holidayName: "\($0["holiday_name"] ?? "")" , holidayDate:"\($0["holiday_date"] ?? "")".changeDateFormateMMddYYYY)}
                    
                    self.setOfSatSunday.addObjects(from: self.arrayOfHoliday.compactMap{$0.holidayDate})
                    
                }
                if let arrayAbsent = attendanceData["absent"] as? [[String:Any]]{
                    self.setOfAbsent.addObjects(from: arrayAbsent.compactMap{"\($0["absent_date"] ?? "")".changeDateFormateMMddYYYY})
                }
                if let arrayLeave = attendanceData["leave"] as? [[String:Any]]{
                    self.arrayOfLeave = arrayLeave.compactMap{Leave.init(LeaveType:"\($0["leave_type"] ?? "")" ,desc: "\($0["description"] ?? "")", LeaveDate:"\($0["leave_date"] ?? "")".changeDateFormateMMddYYYY)}
                    
                    self.setOfLeave.addObjects(from: self.arrayOfLeave.compactMap{$0.LeaveDate})
                }
                if let monthlyDetail = attendanceData["monthly_details"] as? [String:Any]{
                    DispatchQueue.main.async {
                        if let presentday = monthlyDetail["present_days"]{
                            self.lblMonthPresentDaysValue.text = "\(presentday)"
                        }
                        if let absentday = monthlyDetail["absent_days"]{
                            self.lblMonthAbsentDaysValue.text = "\(absentday)"
                        }
                        if let holiday = monthlyDetail["holidays"]{
                            self.lblMonthHoliDaysValue.text = "\(holiday)"
                        }
                        if let leaveday = monthlyDetail["leave_days"]{
                            self.lblMonthLeaveDaysValue.text = "\(leaveday)"
                        }
                    }
                }
                if let yearlyDetail = attendanceData["yearly_details"] as? [String:Any]{
                    DispatchQueue.main.async {
                        if let workday = yearlyDetail["total_working_days"]{
                            self.lblTotalWorkingDaysValue.text = "\(workday)"
                        }
                        if let presentDay = yearlyDetail["total_present_days"]{
                            self.lblTotalPresentDaysValue.text = "\(presentDay)"
                        }
                        if let percentage = yearlyDetail["annual_percentage"]{
                            self.lblTotalAnnualPercentageValue.text = String(format:"%.2f", Float.init("\(percentage)") ?? 0.0)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.objCalender.reloadData()
                }
                print(attendanceData)
                
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
    @IBAction func buttonNextSelector(sender:UIButton){
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage),let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage){
            if currentYear.year == Date().year{
                guard Date().month >= nextMonth.month else {
                    return
                }
            }
            
            self.objCalender.setCurrentPage(nextMonth, animated: true)
            self.configureNextMonthSelector()
            if let user = User.getUserFromUserDefault(){
                self.getAttendanceAPIRequest(userID: user.userId, currentMonth: nextMonth.mmddyyyy)
            }
        }
        
    }
    @IBAction func buttonPreviousSelector(sender:UIButton){
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: objCalender.currentPage){
            self.objCalender.setCurrentPage(previousMonth, animated: true)
            self.configureNextMonthSelector()
            if let user = User.getUserFromUserDefault(){
                self.getAttendanceAPIRequest(userID: user.userId, currentMonth: previousMonth.mmddyyyy)
            }
        }
    }
    @IBAction func buttonAddAttendaceViewSelector(sender:UIButton){
        if let addAttendanceVC = self.storyboard?.instantiateViewController(withIdentifier: "AddAttendanceViewController") as? AddAttendanceViewController{
            self.navigationController?.pushViewController(addAttendanceVC, animated: true)
        }
    }
    func configureNextMonthSelector(){
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage)
        let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage)
        if currentYear!.year == Date().year{
            self.btnNext.isEnabled = Date().month >= nextMonth!.month
        }else{
            self.btnNext.isEnabled = true
        }
        
    }
      // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
extension AttendanceViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.arrayOfUserDetail.count
      
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
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
            return profileCell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return self.heightOfUserProfileTableViewCell
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
extension AttendanceViewController:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.setOfSatSunday.contains(date.mmddyyyy){ //include holiday
            return [kHolidayColor]
        }else if self.setOfLeave.contains(date.mmddyyyy){
            return [kLeaveColor]
        }else if self.setOfAbsent.contains(date.mmddyyyy){
            return [kAbsentColor]
        }else if date <= Date(){
            return [kPresentColor]
        }else{
            return [UIColor.white]
        }
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if self.setOfSatSunday.contains(date.mmddyyyy){
            return [kHolidayColor]
        }else if self.setOfLeave.contains(date.mmddyyyy){
            return [kLeaveColor]
        }else if self.setOfAbsent.contains(date.mmddyyyy) {
            return [kAbsentColor]
        }else if date <= Date(){
            return [kPresentColor]
        }else{
            return [UIColor.white]
        }
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let arrayFilterHoliday =  self.arrayOfHoliday.filter{$0.holidayDate == date.mmddyyyy}
        let arrayFilterLeave = self.arrayOfLeave.filter{$0.LeaveDate == date.mmddyyyy}
        if arrayFilterHoliday.count > 0{
            
            let alertController = UIAlertController.init(title:"Event Information" , message: "\(arrayFilterHoliday.first!.holidayName.replacingOccurrences(of:",", with: "\n")) \n \(arrayFilterHoliday.first!.holidayDate.changeUpdateDateFormateddMMYYYY)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
                
            }))
            self.present(alertController, animated: true, completion: nil)
        }else if arrayFilterLeave.count > 0{
            let alertController = UIAlertController.init(title:"Leave Information" , message: "\(arrayFilterLeave.first!.desc.replacingOccurrences(of:",", with: "\n")) \n \(arrayFilterLeave.first!.LeaveDate.changeUpdateDateFormateddMMYYYY)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
                
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 1
    }
}
extension Date {
    var day:Int {return Calendar.current.component(.day, from:self)}
    var month:Int {return Calendar.current.component(.month, from:self)}
    var year:Int {return Calendar.current.component(.year, from:self)}
    var mmddyyyy:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
    var ddMMyyyy:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
    
}
struct Holiday {
    var holidayName , holidayDate:String
}
struct Leave {
    var LeaveType,desc, LeaveDate:String
}
