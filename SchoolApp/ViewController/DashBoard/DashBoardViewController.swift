//
//  DashBoardViewController.swift
//  SchoolApp
//
//  Created by user on 13/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData
import SDWebImage
import SystemConfiguration
import QuickLook
extension Int{
    var isPrime:Bool{
       return ( self > 1 && !(2..<self).contains{self % $0 == 0})
    }
    var reverseNumber:Int{
        var num = self
        var arrayInt:[Int] = []
        arrayInt.append(num % 10)
        while num >= 10 {
           num = num / 10
           arrayInt.append(num%10)
        }
        return arrayInt.reduce(0){ $0 * 10 + $1 }
    }
}
    
class DashBoardViewController: UIViewController {


    //Navigation
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewProfile:UITableView!
    @IBOutlet var tableViewHeight:NSLayoutConstraint!
    @IBOutlet var colletionViewDashBoard:UICollectionView!
    @IBOutlet var buttonDropDown:UIButton!
    //user personal detail
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var lblUserClassName:UILabel!
    @IBOutlet var lblUserMobileNumber:UILabel!
    @IBOutlet var userProfileImageView:UIImageView!
    @IBOutlet var userDetailContainerView:UIView!
    @IBOutlet var tableViewDashBoard:UITableView!
    
    @IBOutlet var dashBoardUserDetailStack:UIStackView!
    
    //file private constant for navigation
    fileprivate let kProfile = "my_profile" ,kAttendance = "attendance" ,kNotice = "notice" ,kHomework = "homework" ,kTransport = "transport" ,kFees = "fees" ,kRemark = "remark" ,kPhotogallery = "photo_gallery" ,kMealMenu = "meal_menu",kSyllabus = "syllabus",kAssignment = "assignment",kMyLeave = "my_leave",kTimeTable = "time_table",kHolidayHomework = "holiday_homework",kWebsite = "website",kLocation = "location",kOnlineFeesPay = "online_fees_pay" ,kPTM = "ptm",kAchievement = "achievement",kExamTimetable = "exam_time_table",kCalendar = "calender"
    
    var arrayOfUserDetail:[NSManagedObject] = []
    var arrayOfDashBoardDetail:[DashBoardModule] = []
    var profile:Bool = false
    var isShowProfile:Bool{
        get{
            return profile
        }
        set{
            profile = newValue
            //Configure updated value
            
        }
    }
    var heightOfTableViewCell:CGFloat{
        get{
            return 50.0
        }
    }
    var previewItem:NSURL?
    
    let strLat : String = "23.035007"
    let strLong : String = "72.529324"
    
    let strLat1 : String = "23.033331"
    let strLong2 : String = "72.524510"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
        ProgressHud.show()
        
        self.setUpView()
        
        
        self.configureDashBoardCollectionView()
        
        self.configureProfileTableView()
        APIRequestClient.shared.fetchAllUserDetailFromDataBase{ (response) in
            self.arrayOfUserDetail = response
            self.tableViewProfile.reloadData()
            self.buttonUserProfile.isEnabled = self.arrayOfUserDetail.count > 0
            if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
                if user.userrole_id == "2"{
                    self.buttonDropDown.isHidden = false
                    self.buttonUserProfile.isHidden = false
                    self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
                }else{
                    self.buttonDropDown.isHidden = true
                    self.buttonUserProfile.isHidden = true
                }
            }
            
            
        }
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(objUserID: user.userId)
        }
        ViewToShowOnSideMenu.selectedCell = 1
//      self.presentPDFInQuickLook()
//        ViewToShowOnSideMenu.selectedCell = 0
//        let number:Int = 12345
//         var arrayInt:[Int]
//        if number > 1{
//            arrayInt = Array(2..<number)
//        }else{
//            arrayInt = [1]
//        }
//         print(arrayInt.filter{$0.isPrime})
//        print(number.reverseNumber)
        //print(arrayInt.filter{$0.isPrime})
//        print(12345.reverseNumber)
        self.setGradientBackground()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //swipe pop
        self.swipeToPopDisable()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.swipeToPopEnable()
    }
    func configureCurrentUserRole(){
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id == "2"{
                self.buttonDropDown.isHidden = false
                self.buttonUserProfile.isHidden = false
                self.dashBoardUserDetailStack.isHidden = false
            }else{
                self.buttonDropDown.isHidden = true
                self.buttonUserProfile.isHidden = true
                self.dashBoardUserDetailStack.isHidden = true
            }
        }else{
            self.buttonDropDown.isHidden = true
            self.buttonUserProfile.isHidden = true
            self.dashBoardUserDetailStack.isHidden = true
        }
    }
    func setGradientBackground() {
        self.userDetailContainerView.layoutIfNeeded()
        let colorTop =   UIColor.init(hexString: "#0B80C3").cgColor//UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor.init(hexString: "#38A3D9").cgColor//UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor
        let colorMiddle = UIColor.init(hexString: "#62C4EE").cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom,colorMiddle,colorTop]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = CGRect.init(origin: .zero, size: CGSize.init(width: UIScreen.main.bounds.width, height: 300.0))//self.userDetailContainerView.bounds
//        self.userDetailContainerView.backgroundColor = UIColor.red
        self.userDetailContainerView.layer.insertSublayer(gradientLayer, at: 0)
        //        self.view.layer.insertSublayer(gradientLayer)
       
    }
   
    
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.MyDashboard")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.userProfileImageView.clipsToBounds = true
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.width/2.0
        self.configureCurrentUserRole()
        
        
    }
    func swipeToPopEnable() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    func swipeToPopDisable() {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    func configureCurrentUserDetail(objUserID:String){
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: objUserID) { (response) in
            print(response)
                if let objUserCoreData:Users =  response as? Users{
                    self.lblUserName.text = objUserCoreData.username
                    if let classname = objUserCoreData.class_name,let divisionname = objUserCoreData.divison_name{
                        self.lblUserClassName.text = classname + " "  + "-" + " " + divisionname
                    }
                    self.lblUserMobileNumber.text = objUserCoreData.phone_number1
                    if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
                        self.userProfileImageView.sd_setImage(with: objURl, placeholderImage:UIImage.init(named:"ic_user_profile"))
                        self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                    }else{
                        self.userProfileImageView.image = UIImage.init(named:"ic_user_profile")
                        self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal) 
                    }
                }
            }
        self.getMyDashBoardDataAPIRequest(userID: objUserID)
      }
    func configureDashBoardCollectionView(){
        let objGuideNib = UINib.init(nibName: "DashBoardCollectionViewCell", bundle: nil)
        self.colletionViewDashBoard.register(objGuideNib, forCellWithReuseIdentifier:"DashBoardCollectionViewCell")
        self.colletionViewDashBoard.delegate = self
        self.colletionViewDashBoard.dataSource = self
        
        let objTableNib = UINib.init(nibName: "DashBoardTableViewCell", bundle: nil)
        self.tableViewDashBoard.register(objTableNib, forCellReuseIdentifier: "DashBoardTableViewCell")
        self.tableViewDashBoard.delegate = self
        self.tableViewDashBoard.dataSource = self
    }
    func configureProfileTableView(){
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
        
    }
    func presentPDFInQuickLook(){
        
        let strURL = "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"//"https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"////"
//"https://www.adobe.com/content/dam/acom/en/devnet/acrobat/pdfs/pdf_open_parameters.pdf"
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
    // MARK: - Fetch User detail
    func getUserDetailFromDataBase(){
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonDrawerSelector(sender:UIButton){
        SideMenu.show()
        DispatchQueue.main.async {
            self.view.endEditing(true)
        }
    }
    @IBAction func buttonProfileNavigationSelector(sender:UIButton){
        if self.arrayOfUserDetail.count > 0{
            UIView.animate(withDuration: 0.3) {
                if self.tableViewHeight.constant == 0{
                    self.tableViewHeight.constant = CGFloat(self.arrayOfUserDetail.count) * self.heightOfTableViewCell
                }else{
                    self.tableViewHeight.constant = 0
                }
            }
        }
    }
    @IBAction func buttonProfileSelector(sender:UIButton){
       self.pushToUserProfileView()
    }
    // MARK: - Notification Redirection
    func callNotificationRedirection(slug:String){
        if slug == "my_profile"{
            self.pushToUserProfileView()
         }else if slug == "attendance"{
            self.pushToAttendanceView()
         }else if slug == "transport"{
            self.pushToTransportView()
         }else if slug == "fees"{
             self.pushToFeesView()
         }else if slug == "photo_gallery"{
            self.pushToPhotoGalleryView()
         }else if slug == "meal_menu"{
            self.pushToMealMenuView()
         }else if slug == "syllabus"{
            self.pushToSyllabusView()
         }else if slug == "my_leave"{
            self.pushToMyLeaveView()
         }else if slug == "time_table"{
            self.pushToTimeTableView()
         }else if slug == "holiday_homework"{
            self.pushToHolidayHomeworkView()
         }else if slug == "website"{
            let strURL = kBaseURL//"http://schoolerp.project-demo.info"
            guard let url = URL(string:strURL) else { return }
            UIApplication.shared.open(url)
         }else if slug == "location"{
            if let user = User.getUserFromUserDefault(){
                print(user.schoolLong)
                print(user.schoolLat)
                let objurl = "https://www.google.com/maps?saddr=My+Location&daddr=Shanti Asiatic School Surat"//\(user.schoolLat),\(user.schoolLong)"
                if let strURL = objurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                    guard let url = URL(string:strURL) else { return }
                    UIApplication.shared.open(url)
                }
                
            }
         }else if slug == "online_fees_pay"{
            self.pushToOnlineFeesPayworkView()
         }else if slug == "exam_time_table"{
            self.pushToExamTimeTableView()
         }else if slug == "calender"{
          self.pushToCalendarView()
         }else if slug == "homework"{
           self.pushToHomeWorkView()
         }else if slug == "notice"{
           self.pushToNoticeView()
         }else if slug == "ptm"{
            self.pushToPTMView()
         }else if slug == "remark"{
            self.pushToRemarkView()
         }else if slug == "achievement"{
            self.pushToAchievementView()
         }
    }
    // MARK: - API Request Methods
    func getMyDashBoardDataAPIRequest(userID:String){
        let dashBoardParameters = ["user_id":"\(userID)"]
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kDashBoard, parameter:dashBoardParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            print(responseSuccess)
            if let success = responseSuccess as? [String:Any],let arrayOfDashBoard = success["data"] as? [[String:Any]]{
                self.arrayOfDashBoardDetail.removeAll()
                for objDashBoard:[String:Any] in arrayOfDashBoard{
                    let objDashBoard = DashBoardModule.init(dashBoardDetail: objDashBoard)
                    self.arrayOfDashBoardDetail.append(objDashBoard)
                }
                DispatchQueue.main.async {
                    self.tableViewDashBoard.reloadData()
                    self.colletionViewDashBoard.reloadData()
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
    func pushToUserProfileView(){
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id == "2"{
                if let profileView = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController{
                    self.navigationController?.pushViewController(profileView, animated: true)
                }
        }}
    }
    func pushToAttendanceView(){
        if let user = User.getUserFromUserDefault(),user.userType == .student{
            if let attendanceView = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceViewController") as? AttendanceViewController{
                self.navigationController?.pushViewController(attendanceView, animated: true)
            }
        }else{
            if let attendanceView = self.storyboard?.instantiateViewController(withIdentifier: "AttendanceAdminViewController") as? AttendanceAdminViewController{
                self.navigationController?.pushViewController(attendanceView, animated: true)
            }
        }
        
    }
    func pushToHomeWorkView(){
        if let homeworkView = self.storyboard?.instantiateViewController(withIdentifier: "HomeWorkViewController") as? HomeWorkViewController{
            self.navigationController?.pushViewController(homeworkView, animated: true)
        }
    }
    func pushToTransportView(){
        if let transportView = self.storyboard?.instantiateViewController(withIdentifier: "TransportViewController") as? TransportViewController{
            self.navigationController?.pushViewController(transportView, animated: true)
        }
    }
    func pushToNoticeView(){
        if let noticeView = self.storyboard?.instantiateViewController(withIdentifier: "NoticeViewController") as? NoticeViewController{
            self.navigationController?.pushViewController(noticeView, animated: true)
        }
    }
    
    func pushToFeesView(){
        if let feesView = self.storyboard?.instantiateViewController(withIdentifier: "FeesViewController") as? FeesViewController{
            self.navigationController?.pushViewController(feesView, animated: true)
        }
    }
    func pushToRemarkView(){
        if let remarkView = self.storyboard?.instantiateViewController(withIdentifier: "RemarkViewController") as? RemarkViewController{
            self.navigationController?.pushViewController(remarkView, animated: true)
        }
    }
    func pushToPhotoGalleryView(){
        if let photogalleryView = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGalleryViewController") as? PhotoGalleryViewController{
            self.navigationController?.pushViewController(photogalleryView, animated: true)
        }
    }
    func pushToMealMenuView(){
        if let mealMenuView = self.storyboard?.instantiateViewController(withIdentifier: "MealMenuViewController") as? MealMenuViewController{
            self.navigationController?.pushViewController(mealMenuView, animated: true)
        }
    }
    func pushToSyllabusView(isAssignment:Bool = false){
        if let syllabusView = self.storyboard?.instantiateViewController(withIdentifier: "SyllabusViewController") as? SyllabusViewController{
            syllabusView.isForAssignment = isAssignment
            self.navigationController?.pushViewController(syllabusView, animated: true)
        }
    }
    func pushToAssignmentView(){
        if let assignmentView = self.storyboard?.instantiateViewController(withIdentifier: "AssignmentViewController") as? AssignmentViewController{
            self.navigationController?.pushViewController(assignmentView, animated: true)
        }
    }
    func pushToMyLeaveView(){
        if let myLeaveView = self.storyboard?.instantiateViewController(withIdentifier: "MyLeaveViewController") as? MyLeaveViewController{
            self.navigationController?.pushViewController(myLeaveView, animated: true)
        }
    }
    func pushToTimeTableView(){
        if let timeTableView = self.storyboard?.instantiateViewController(withIdentifier: "TimeTableViewController") as? TimeTableViewController{
            self.navigationController?.pushViewController(timeTableView, animated: true)
        }
    }
    func pushToHolidayHomeworkView(){
        if let holidayHome = self.storyboard?.instantiateViewController(withIdentifier: "HolidayHomeworkViewController") as? HolidayHomeworkViewController{
            self.navigationController?.pushViewController(holidayHome, animated: true)
        }
    }
    func pushToOnlineFeesPayworkView(){
        if let onlineFeesPay = self.storyboard?.instantiateViewController(withIdentifier: "OnlineFeesPayViewController") as? OnlineFeesPayViewController{
            self.navigationController?.pushViewController(onlineFeesPay, animated: true)
        }
    }
    func pushToPTMView(){
        if let ptmView = self.storyboard?.instantiateViewController(withIdentifier: "PTMViewController") as? PTMViewController{
            self.navigationController?.pushViewController(ptmView, animated: true)
        }
    }
    func pushToAchievementView(){
        if let achievementView = self.storyboard?.instantiateViewController(withIdentifier: "AchievementViewController") as? AchievementViewController{
            self.navigationController?.pushViewController(achievementView, animated: true)
        }
    }
    func pushToExamTimeTableView(){
        if let examTimeTableView = self.storyboard?.instantiateViewController(withIdentifier: "ExamTimeTableViewController") as? ExamTimeTableViewController{
            self.navigationController?.pushViewController(examTimeTableView, animated: true)
        }
    }
    func pushToCalendarView(){
        if let calendarView = self.storyboard?.instantiateViewController(withIdentifier: "CalendarViewController") as? CalendarViewController{
            self.navigationController?.pushViewController(calendarView, animated: true)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}

extension DashBoardViewController:UIGestureRecognizerDelegate{
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension DashBoardViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfDashBoardDetail.count == 0{
            collectionView.showMessageLabel()
        }else{
            collectionView.removeMessageLabel()
        }
        return self.arrayOfDashBoardDetail.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dashBoardCell:DashBoardCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashBoardCollectionViewCell", for: indexPath) as! DashBoardCollectionViewCell
        if  self.arrayOfDashBoardDetail.count > indexPath.item{
            
            dashBoardCell.objName.text = self.arrayOfDashBoardDetail[indexPath.item].moduleName
            if let objURL = URL.init(string: self.arrayOfDashBoardDetail[indexPath.item].moduleIcon){
                dashBoardCell.objImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"ic_user_profile"))
            }
        }
        dashBoardCell.objImageView.contentMode = .scaleToFill
        return dashBoardCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width, height: 80.0)//collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0//15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.arrayOfDashBoardDetail.count > indexPath.item{
            let objDashBoard = self.arrayOfDashBoardDetail[indexPath.item]
            switch objDashBoard.slug{
                case kProfile:
                    self.pushToUserProfileView()
                    break
                case kAttendance:
                    self.pushToAttendanceView()
                    break
                case kNotice:
                    self.pushToNoticeView()
                    break
                case kHomework:
                     self.pushToHomeWorkView()
                    break
                case kTransport:
                     self.pushToTransportView()
                    break
                case kFees:
                    self.pushToFeesView()
                    break
                case kRemark:
                    self.pushToRemarkView()
                    break
                case kPhotogallery:
                    self.pushToPhotoGalleryView()
                    break
                case kMealMenu:
                    self.pushToMealMenuView()
                    break
                case kSyllabus:
                    self.pushToSyllabusView()
                    break
                case kAssignment:
                    self.pushToSyllabusView(isAssignment: true)
                    break
                case kMyLeave:
                    self.pushToMyLeaveView()
                    break
                case kTimeTable:
                    self.pushToTimeTableView()
                    break
                case kHolidayHomework:
                    self.pushToHolidayHomeworkView()
                    break
                case kWebsite:
                    let strURL = kWebVastral//"http://schoolerp.project-demo.info"
                    guard let url = URL(string:strURL) else { return }
                    UIApplication.shared.open(url)
                    break
                case kLocation:
                    if let user = User.getUserFromUserDefault(){
                       print(user.schoolLong)
                        print(user.schoolLat)
                        let objurl = "https://www.google.com/maps?saddr=My+Location&daddr=Shanti Asiatic School Kheda"//\(user.schoolLat),\(user.schoolLong)"
                        if let strURL = objurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                            guard let url = URL(string:strURL) else { return }
                            UIApplication.shared.open(url)
                        }
                       
                    }
                    break
                case kOnlineFeesPay:
                    self.pushToOnlineFeesPayworkView()
                    break
                case kPTM:
                    self.pushToPTMView()
                    break
                case kAchievement:
                    self.pushToAchievementView()
                    break
                case kExamTimetable:
                    self.pushToExamTimeTableView()
                    break
                case kCalendar:
                    self.pushToCalendarView()
                    break
                default:
                    break
            }
        }
    }
}
extension DashBoardViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewDashBoard{
            if self.arrayOfDashBoardDetail.count == 0{
                tableView.showMessageLabel()
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfDashBoardDetail.count
        }else{
            return self.arrayOfUserDetail.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewDashBoard{
            let tableCell:DashBoardTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DashBoardTableViewCell", for: indexPath) as! DashBoardTableViewCell
            if  self.arrayOfDashBoardDetail.count > indexPath.row{
                
                tableCell.objName.text = self.arrayOfDashBoardDetail[indexPath.row].moduleName
                if let objURL = URL.init(string: self.arrayOfDashBoardDetail[indexPath.item].moduleIcon){
                    tableCell.objImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"ic_user_profile"))
                }
            }
            tableCell.objImageView.contentMode = .scaleToFill
            return tableCell
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
        if tableView == tableViewDashBoard{
            return 100.0
        }else{
            return self.heightOfTableViewCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tableViewDashBoard{
                if self.arrayOfDashBoardDetail.count > indexPath.item{
                    let objDashBoard = self.arrayOfDashBoardDetail[indexPath.item]
                    switch objDashBoard.slug{
                    case kProfile:
                        self.pushToUserProfileView()
                        break
                    case kAttendance:
                        self.pushToAttendanceView()
                        break
                    case kNotice:
                        self.pushToNoticeView()
                        break
                    case kHomework:
                        self.pushToHomeWorkView()
                        break
                    case kTransport:
                        self.pushToTransportView()
                        break
                    case kFees:
                        self.pushToFeesView()
                        break
                    case kRemark:
                        self.pushToRemarkView()
                        break
                    case kPhotogallery:
                        self.pushToPhotoGalleryView()
                        break
                    case kMealMenu:
                        self.pushToMealMenuView()
                        break
                    case kSyllabus:
                        self.pushToSyllabusView()
                        break
                    case kAssignment:
                        self.pushToSyllabusView(isAssignment: true)
                        break
                    case kMyLeave:
                        self.pushToMyLeaveView()
                        break
                    case kTimeTable:
                        self.pushToTimeTableView()
                        break
                    case kHolidayHomework:
                        self.pushToHolidayHomeworkView()
                        break
                    case kWebsite:
                        let kWebSiteSurat = "http://shantiasiaticsurat.com/"
                        let kWebSiteVastral = "http://shantiasiaticvastral.com/"
                        let kWebSiteKheda = "http://shantiasiatickheda.com/"
                        let strURL = kWebSiteVastral//"http://schoolerp.project-demo.info"
                        guard let url = URL(string:strURL) else { return }
                        UIApplication.shared.open(url)
                        break
                    case kLocation:
                        if let user = User.getUserFromUserDefault(){
                            print(user.schoolLong)
                            print(user.schoolLat)
                            let objurl = "https://www.google.com/maps?saddr=My+Location&daddr=Shanti Asiatic School Vastral"//\(user.schoolLat),\(user.schoolLong)"
                            if let strURL = objurl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                                guard let url = URL(string:strURL) else { return }
                                UIApplication.shared.open(url)
                            }

                        }
                        break
                    case kOnlineFeesPay:
                        self.pushToOnlineFeesPayworkView()
                        break
                    case kPTM:
                        self.pushToPTMView()
                        break
                    case kAchievement:
                        self.pushToAchievementView()
                        break
                    case kExamTimetable:
                        self.pushToExamTimeTableView()
                        break
                    case kCalendar:
                        self.pushToCalendarView()
                        break
                    default:
                        break
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
                                        self.configureCurrentUserDetail(objUserID: "\(userId)")
                                    }
                                    
                                })
                            
                        }
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
extension DashBoardViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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
