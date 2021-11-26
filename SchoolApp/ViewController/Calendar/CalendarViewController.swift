//
//  CalendarViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import FSCalendar

class CalendarViewController: UIViewController {
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
    
    var heightOfHeaderViewTable:CGFloat{
        get{
            return 90.0
        }
    }
    
    var arrayOfUserDetail:[NSManagedObject] = []
    var arrayOfYearlyCalendarColor:[String] = ["#000080","#0000FF","#007BA7","#87CEEB","#40E0D0","#0D98BA","#007FFF","#008080","#00FFFF","#008000","#00FF00","#808000","   #FFFF00","#FFD700","#FF6600","#964B00","#FF0000","#800000","#FF0080","#C71585","#FD6C9E","#FF00FF","#800080","#8A2BE2","#4B0082","#000000","#003153","#007BA7",
        "#800020","#CD7F32","#007BA7","#00A86B"]
    
    @IBOutlet var tableViewCalendarYealy:UITableView!
    @IBOutlet var containerViewMonthly:UIView!
    @IBOutlet var objSegmentController:UISegmentedControl!
    
    @IBOutlet var objCalender:FSCalendar!
    @IBOutlet var btnNext:UIButton!
    @IBOutlet var btnPrevious:UIButton!
    
    @IBOutlet var lblEvents:UILabel!
    @IBOutlet var lblEventsColorView:UIView!
    @IBOutlet var lblHoliday:UILabel!
    @IBOutlet var lblHolidayColorView:UIView!
    
    var isMonthly:Bool = false
    var isMonthlySelected:Bool{
        get{
            return isMonthly
        }
        set{
            isMonthly = newValue
            //Configure Monthly
            self.configureMonthlySelected()
        }
    }
    fileprivate let kHolidayColor:UIColor = UIColor.red
    fileprivate let kEventColor:UIColor = UIColor.blue
    
    
    var setOfHoliday:NSMutableSet = NSMutableSet()
    var setOfEvent:NSMutableSet = NSMutableSet()
    
    var arrayOfHoliday:[EventHoliday] = []
    var arrayOfEvents:[EventHoliday] = []
    
    var arrayOfYearlySection:[String] = []
    var arrayOfyearlyImage:[String] = []
    var arrayOfMonthYealy:[[EventHoliday]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        
        self.configureSavedUserProfileData()
        
        self.configureCalendarTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getCalendarYealyTableAPIRequest(userID: user.userId)
            self.getCalendarMonthlyAPIRequest(userID: user.userId, currentMonth: Date().mmddyyyy)
        }
        self.isMonthlySelected = false
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.Calendar")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.objSegmentController.tintColor = kSchoolThemeColor
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key:"genral.YealyView"), forSegmentAt: 0)
        self.objSegmentController.setTitle(Vocabulary.getWordFromKey(key:"genral.MonthlyView"), forSegmentAt: 1)
        let font = UIFont.systemFont(ofSize: 18)
        self.objSegmentController.setTitleTextAttributes([NSAttributedString.Key.font: font],
                                                         for: .normal)
        self.configureFSCalender()
        
        self.lblHoliday.text = "Holiday"//Vocabulary.getWordFromKey(key: "genral.holiday")
        self.lblHolidayColorView.backgroundColor = kHolidayColor
        self.lblEvents.text = Vocabulary.getWordFromKey(key: "genral.Events")
        self.lblEventsColorView.backgroundColor = kEventColor
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
    }
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
    func configureNextMonthSelector(){
        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage)
        let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage)
        if currentYear!.year == Date().year{
            self.btnNext.isEnabled = true//Date().month >= nextMonth!.month
        }else{
            self.btnNext.isEnabled = true
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
    func configureMonthlySelected(){
        if self.isMonthlySelected{
            self.tableViewCalendarYealy.isHidden = true
            self.containerViewMonthly.isHidden = false
        }else{
            self.tableViewCalendarYealy.isHidden = false
            self.containerViewMonthly.isHidden = true
        }
    }
    //
    func configureCalendarTableView(){
        // self.tableViewHomeWork.tableHeaderView = self.tableViewHeaderView
        self.tableViewCalendarYealy.rowHeight = UITableView.automaticDimension
        self.tableViewCalendarYealy.estimatedRowHeight = 100.0
        self.tableViewCalendarYealy.delegate = self
        self.tableViewCalendarYealy.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "CalendarYealyTableViewCell", bundle: nil)
        self.tableViewCalendarYealy.register(objNib, forCellReuseIdentifier: "CalendarYealyTableViewCell")
        self.tableViewCalendarYealy.separatorStyle = .none
        self.tableViewCalendarYealy.isScrollEnabled = true
        self.tableViewCalendarYealy.tableHeaderView = UIView()
        self.tableViewCalendarYealy.tableFooterView = UIView()
        self.tableViewCalendarYealy.reloadData()
    }
    // MARK: - API Request Methods
    func getCalendarYealyTableAPIRequest(userID:String){
        let leaveParameters = ["user_id":"\(userID)","view":"\(0)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kCalendarMonthly, parameter:leaveParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let calendar = success["data"] as? [[String:Any]]{
                self.arrayOfYearlySection.removeAll()
                self.arrayOfMonthYealy.removeAll()
                self.arrayOfyearlyImage.removeAll()
                for objMonth:[String:Any] in calendar{
                    if let headerIMage = objMonth["img"]{
                        self.arrayOfyearlyImage.append("\(headerIMage)")

                    }
                    if let header = objMonth["header"]{
                        self.arrayOfYearlySection.append("\(header)")
                    }
                    if let arrayMonth = objMonth["month"] as? [[String:Any]]{
                        
                        var modelArrayMonth:[EventHoliday] = []
                        for var objMonthData:[String:Any] in arrayMonth{
                            do{
                                objMonthData.updateJSONNullToString()
                                let jsondata = try JSONSerialization.data(withJSONObject:objMonthData, options:.prettyPrinted)
                                if let events = try? JSONDecoder().decode(EventHoliday.self, from: jsondata){
                                    modelArrayMonth.append(events)
                                }
                            }catch{
                                
                            }
                        }
                        self.arrayOfMonthYealy.append(modelArrayMonth)
                    }
                }
                DispatchQueue.main.async {
                    self.tableViewCalendarYealy.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    guard !"\(errorMessage)".contains("No exam schedule available.") else {
                        
                        return
                    }
                    ShowToast.show(toatMessage: "\(errorMessage)")
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        })
    }
    func getCalendarMonthlyAPIRequest(userID:String,currentMonth:String){
        let monthlyParameters = ["user_id":"\(userID)","month":"\(currentMonth)","view":"\(1)"]
        APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kCalendarMonthly, parameter:monthlyParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any]{
                if let arrayEvent = successData["events"] as? [[String:Any]]{
                    self.arrayOfEvents.removeAll()
                    for var objEvent:[String:Any] in arrayEvent{
                        objEvent.updateJSONNullToString()
                        do{
                            let jsondata = try JSONSerialization.data(withJSONObject:objEvent, options:.prettyPrinted)
                            if let events = try? JSONDecoder().decode(EventHoliday.self, from: jsondata){
                                self.arrayOfEvents.append(events)
                            }
                        }catch{
                            
                        }
                    }
                    self.setOfEvent.addObjects(from: self.arrayOfEvents.compactMap{$0.eventDate.changeDateFormateMMddYYYY})
                }
                if let arrayOfHoliday = successData["holidays"] as? [[String:Any]]{
                     self.arrayOfHoliday.removeAll()
                    for var objHoliday:[String:Any] in arrayOfHoliday{
                        objHoliday.updateJSONNullToString()
                        do{
                            let jsondata = try JSONSerialization.data(withJSONObject:objHoliday, options:.prettyPrinted)
                            if let eventsHoliday = try? JSONDecoder().decode(EventHoliday.self, from: jsondata){
                                self.arrayOfHoliday.append(eventsHoliday)
                            }
                        }catch{
                            
                        }
                    }
                    self.setOfHoliday.addObjects(from: self.arrayOfHoliday.compactMap{$0.eventDate.changeDateFormateMMddYYYY})

                }
                DispatchQueue.main.async {
                     self.objCalender.reloadData()
                    self.objCalender.reloadInputViews()
                    self.tableViewCalendarYealy.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                DispatchQueue.main.async {
                    guard !"\(errorMessage)".contains("No exam schedule available.") else {
                        
                        return
                    }
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
    @IBAction func buttonSegmentSelected(sender:UISegmentedControl){
        self.isMonthlySelected = !self.isMonthlySelected
    }
    @IBAction func buttonNextSelector(sender:UIButton){
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: objCalender.currentPage),let currentYear = Calendar.current.date(byAdding: .year, value: 0, to: objCalender.currentPage){
            /*
            if currentYear.year == Date().year{
                guard Date().month >= nextMonth.month else {
                    return
                }
            }*/
            
            self.objCalender.setCurrentPage(nextMonth, animated: true)
            self.configureNextMonthSelector()
            if let user = User.getUserFromUserDefault(){
                self.getCalendarMonthlyAPIRequest(userID: user.userId, currentMonth: nextMonth.mmddyyyy)
            }
        }
        
    }
    @IBAction func buttonPreviousSelector(sender:UIButton){
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: objCalender.currentPage){
            self.objCalender.setCurrentPage(previousMonth, animated: true)
            self.configureNextMonthSelector()
            if let user = User.getUserFromUserDefault(){
                self.getCalendarMonthlyAPIRequest(userID: user.userId, currentMonth: previousMonth.mmddyyyy)
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
extension CalendarViewController:FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance{
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.setOfHoliday.contains(date.mmddyyyy){ //include holiday
            return [kHolidayColor]
        }else if self.setOfEvent.contains(date.mmddyyyy){
            return [kEventColor]
        }else{
            return [UIColor.clear]
        }
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if self.setOfHoliday.contains(date.mmddyyyy){ //include holiday
            return [kHolidayColor]
        }else if self.setOfEvent.contains(date.mmddyyyy){
            return [kEventColor]
        }else{
            return [UIColor.clear]
        }
      
    }
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let arrayFilterEvents =  self.arrayOfEvents.filter{$0.eventDate.changeDateFormateMMddYYYY == date.mmddyyyy}
        let arrayFilterHoliday =  self.arrayOfHoliday.filter{$0.eventDate.changeDateFormateMMddYYYY == date.mmddyyyy}
        if arrayFilterEvents.count > 0{
            var eventName = arrayFilterEvents.first!.eventName
            if arrayFilterHoliday.count > 0{
                eventName += ",\(arrayFilterHoliday.first!.eventName)"
            }
            print(eventName)
            let updateName = eventName.replacingOccurrences(of:",", with: "\n")
            
            let alertController = UIAlertController.init(title:"Event Information", message: "\(updateName) \n \(arrayFilterEvents.first!.eventDate.changeDateFormateddMMYYYY)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
                
            }))
            self.present(alertController, animated: true, completion: nil)
        }else if arrayFilterHoliday.count > 0{
            var eventName = arrayFilterHoliday.first!.eventName
            if arrayFilterEvents.count > 0{
                eventName += ",\(arrayFilterEvents.first!.eventName)"
            }
            let updateName = eventName.replacingOccurrences(of:",", with: "\n")
            print(eventName)
            let alertController = UIAlertController.init(title:"Event Information", message: "\(updateName) \n \(arrayFilterHoliday.first!.eventDate.changeDateFormateddMMYYYY)", preferredStyle: .alert)
            alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
                
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 1
    }
}
extension CalendarViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableViewCalendarYealy{
            return self.arrayOfYearlySection.count
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewCalendarYealy{
            if self.arrayOfMonthYealy.count > section{
                return self.arrayOfMonthYealy[section].count
            }else{
                return 0
            }
            
        }else{
            return self.arrayOfUserDetail.count
        }
        
    }
    func getDayNameBy(stringDate: String) -> String{
        let df  = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        let date = df.date(from: stringDate)!
        df.dateFormat = "EEE"
        let calendar = Calendar.current
        
        return "\(calendar.component(.day, from: date)) \n\(df.string(from: date))"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableViewCalendarYealy{
            let calendarCell:CalendarYealyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CalendarYealyTableViewCell", for: indexPath) as! CalendarYealyTableViewCell
            if self.arrayOfMonthYealy.count > indexPath.section{
                let arryMonth = self.arrayOfMonthYealy[indexPath.section]
                if arryMonth.count > indexPath.row{
                    let objMonth = arryMonth[indexPath.row]
                    let eventType = objMonth.eventTypeName.components(separatedBy:",")
                    let eventName = objMonth.eventName.components(separatedBy:",")
                    if eventType.count > 1,eventName.count > 1,eventType.count == eventName.count{
                        var eventDetailString = ""
                        for name in eventName{
                            eventDetailString.append("\(name)\n")
                        }
                        print(eventType)
                        print(eventName)
                        calendarCell.lblEventDetail.text = "\(eventDetailString)"
                    }else{
                        calendarCell.lblEventDetail.text = "\(objMonth.eventName)"
                    }
                    
                    calendarCell.lblDay.text =  self.getDayNameBy(stringDate:objMonth.eventDate)
                    if self.arrayOfYearlyCalendarColor.count > indexPath.row{
                        calendarCell.containerView.backgroundColor = UIColor.init(hexString:self.arrayOfYearlyCalendarColor[indexPath.row]) .withAlphaComponent(0.25)
                    }else{
                        calendarCell.containerView.backgroundColor = UIColor.random().withAlphaComponent(0.25)
                    }
                    
                    calendarCell.selectionStyle = .none
                }
            }
            return calendarCell
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
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.tableViewCalendarYealy{
            
            let headerView = UIView.init(frame: CGRect.init(origin: .zero, size: CGSize.init(width: tableView.bounds.width, height: self.heightOfHeaderViewTable)))
            headerView.clipsToBounds = true
//            headerView.layer.cornerRadius = 10.0
            headerView.backgroundColor = kSchoolThemeColor
            let objImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: self.heightOfHeaderViewTable))
            
            if self.arrayOfyearlyImage.count > 0{
                if let objURL = URL.init(string: self.arrayOfyearlyImage[section]){
                    objImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"calendar_background"))
                }else{
                    objImageView.image = UIImage.init(named: "calendar_background")
                }
            }else{
                objImageView.image = UIImage.init(named: "calendar_background")
            }
            objImageView.clipsToBounds = true
            objImageView.contentMode = .scaleAspectFill
            headerView.addSubview(objImageView)
            let lblHeder = UILabel.init(frame: CGRect.init(x: 20, y: self.heightOfHeaderViewTable*0.4, width: tableView.bounds.width-20.0, height: 30.0))
            lblHeder.textColor = UIColor.white
            lblHeder.shadowColor = UIColor.black.withAlphaComponent(0.5)
            lblHeder.shadowOffset = CGSize.init(width: 2, height: 1)
            lblHeder.font = UIFont.boldSystemFont(ofSize: 22.0)
            lblHeder.text = "\(self.arrayOfYearlySection[section])".replacingOccurrences(of: "_", with: ",")//self.arrayOfFees[section]
            headerView.addSubview(lblHeder)
            /*
            let lblHeder = UILabel.init(frame: CGRect.init(x: 50, y: 3, width: tableView.bounds.width-50.0, height: 30.0))
            lblHeder.textColor = UIColor.white
            lblHeder.text = "Test"//self.arrayOfFees[section]
            headerView.addSubview(lblHeder)
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(FeesViewController.tapDetected))
            headerView.tag = section
            headerView.addGestureRecognizer(singleTap)
            let containerView = UIView.init(frame: CGRect.init(x: 0, y: 2, width: tableView.bounds.width, height: 36.0))
            containerView.addSubview(headerView)
            objImageView.backgroundColor = UIColor.clear
            objImageView.contentMode = .scaleAspectFit*/
            return headerView
        }else{
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.tableViewCalendarYealy{
            return self.heightOfHeaderViewTable
        }else{
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableViewCalendarYealy{
            return UITableView.automaticDimension
        }else{
            return self.heightOfUserProfileTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableViewCalendarYealy{
            if self.arrayOfMonthYealy.count > indexPath.section{
                let arryMonth = self.arrayOfMonthYealy[indexPath.section]
                if arryMonth.count > indexPath.row{
                    let objMonth = arryMonth[indexPath.row]
                    let updatedName = objMonth.eventName.replacingOccurrences(of:",", with:"\n")
                    let alertController = UIAlertController.init(title:"Event Information", message: "\(updatedName) \n \(objMonth.eventDate.changeDateFormateddMMYYYY)", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction.init(title:Vocabulary.getWordFromKey(key: "ok.title"), style: .cancel, handler: { (_) in
                        
                    }))
                    self.present(alertController, animated: true, completion: nil)
//                    calendarCell.lblEventDetail.text = "\(objMonth.eventName) \(objMonth.eventTypeName)"
//                    calendarCell.lblDay.text =  self.getDayNameBy(stringDate:objMonth.eventDate)
                    
                }
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
}
struct EventHoliday: Codable {
    
    let eventDate, eventName, eventTypeName, isHoliday: String
    
    enum CodingKeys: String, CodingKey {
        case eventDate = "event_date"
        case eventName = "event_name"
        case eventTypeName = "event_type_name"
        case isHoliday = "is_holiday"
    }
    init(from decoder : Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventDate = try values.decodeIfPresent(String.self, forKey: .eventDate) ?? ""
        self.eventName = try values.decodeIfPresent(String.self, forKey: .eventName) ?? ""
        self.eventTypeName = try values.decodeIfPresent(String.self, forKey: .eventTypeName) ?? ""
        self.isHoliday = try values.decodeIfPresent(String.self, forKey: .isHoliday) ?? ""
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
