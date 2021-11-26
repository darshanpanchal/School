//
//  AttendanceAdminViewController.swift
//  SchoolApp
//
//  Created by user on 05/08/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
typealias DDTableViewDelegateDataSource = UITableViewDelegate & UITableViewDataSource
class AttendanceAdminViewController: UIViewController {
    //navigation
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var lblTitle:UILabel!
    
    var isLoadMoreStudentAttendace:Bool = false
    var currentPage:Int = 0
    var arrayOfStudentAttendace:[AdminAttendance] = []
    //Attendance
    @IBOutlet var tableViewAttendance:UITableView!
    
    @IBOutlet var buttonAddAttendance:RoundButton!
    
    @IBOutlet var buttonFilter:UIButton!
    
    var refreshControl = UIRefreshControl()
    
    var isPullToRefresh = false
    
    var filterParameters:[String:Any] = [:]
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpView()
        
        self.configureAttendanceTableView()
        
        if let user = User.getUserFromUserDefault(){
            self.getStudentAttendanceListAPIRequest(userID: user.userId)
        }
    }
    // MARK: - Selector Methods
    @IBAction func buttonDrawerSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
        //        SideMenu.show()
    }
    @IBAction func buttonAddAttendanceSelector(sender:UIButton){
        self.pushToAttendanceDetailView()
    }
    @IBAction func buttonFilterSelector(sender:UIButton){
        if let dvc = self.storyboard?.instantiateViewController(withIdentifier: "AddAccountViewController") as? AddAccountViewController{
            if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
            {    dvc.modalPresentationStyle = .overFullScreen
                dvc.isForClassSectionFilter = true
                dvc.delegate = self
                dvc.filterParameters = self.filterParameters
                rootVC.present(dvc, animated: false, completion: nil)
            }
        }
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"Attendance")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        
        self.buttonAddAttendance.tintColor = kSchoolThemeColor
        self.buttonAddAttendance.backgroundColor = kSchoolThemeColor
    }
    func configureAttendanceTableView(){
        // self.tableViewAttendance.tableHeaderView = self.tableViewHeaderView
        self.tableViewAttendance.rowHeight = UITableView.automaticDimension
        self.tableViewAttendance.estimatedRowHeight = 100.0
        self.tableViewAttendance.delegate = self
        self.tableViewAttendance.dataSource = self
        //Register TableViewCell
        let objNib = UINib.init(nibName: "HomeworkTableViewCell", bundle: nil)
        self.tableViewAttendance.register(objNib, forCellReuseIdentifier: "HomeworkTableViewCell")
        self.tableViewAttendance.separatorStyle = .none
        self.tableViewAttendance.isScrollEnabled = true
        self.tableViewAttendance.reloadData()
        if let user = User.getUserFromUserDefault(),user.userType == .student { //hide footer for students
            self.tableViewAttendance.tableFooterView = UIView()
        }
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshTableView), for: UIControl.Event.valueChanged)
        self.tableViewAttendance.addSubview(refreshControl) // not required when using UITableViewController
    }
    @objc func refreshTableView() {
        DispatchQueue.main.async {
            self.filterParameters = [:]
            self.isPullToRefresh = true
            self.refreshControl.endRefreshing()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
                // Code to refresh table view
                DispatchQueue.global(qos: .background).async {
                    self.currentPage = 0
                    if let user = User.getUserFromUserDefault(){
                        self.getStudentAttendanceListAPIRequest(userID: user.userId,showHud: true)
                    }
                }
            }
        }
    }
    // MARK: - API Request Methods
    func getStudentAttendanceListAPIRequest(userID:String,showHud:Bool = true){
        var notificationParameters = ["user_id":"\(userID)","page":"\(self.currentPage)"]
        let _ = self.filterParameters.map{
            notificationParameters[$0.0] = "\($0.1)"
        }
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kGETAdminAttendance, parameter:notificationParameters as [String : AnyObject],isHudeShow: !self.isPullToRefresh,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayHomework = success["data"] as? [[String:Any]]{//,let arrayNotice = jsonData["notice"] as? [[String:Any]]{
                DispatchQueue.main.async {
                    if self.currentPage == 0{
                        self.arrayOfStudentAttendace.removeAll()
                    }
                    self.isLoadMoreStudentAttendace = arrayHomework.count > 0
                    for var objHomework:[String:Any] in arrayHomework{
                        objHomework.updateJSONNullToString()
                        do{
                            let jsondata = try JSONSerialization.data(withJSONObject:objHomework, options:.prettyPrinted)
                            if let adminAttendance = try? JSONDecoder().decode(AdminAttendance.self, from: jsondata){
                                self.arrayOfStudentAttendace.append(adminAttendance)
                            }
                        }catch{
                            
                        }

                    }
//                    self.tableViewAttendance.reloadSections([0], with: .none)
                    self.tableViewAttendance.reloadData()
                }
            }else{
                DispatchQueue.main.async {
                    ShowToast.show(toatMessage:kCommonError)
                }
            }
        }, fail: { (responseFail) in
            self.isLoadMoreStudentAttendace = false
            DispatchQueue.main.async {
                //self.currentPage = 0
                //self.arrayOfStudentAttendace.removeAll()
                self.tableViewAttendance.reloadData()
            }
            if let failResponse = responseFail  as? [String:Any],let errorMessage = failResponse["message"]{
                if "\(errorMessage)".range(of:"homework",options: .caseInsensitive) != nil{
                    return
                }
                guard !"\(errorMessage)".contains("No more attendance available.") else {
                    return
                }
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
    func pushToAttendanceDetailView(){
        if let addAttendanceDetailView = self.storyboard?.instantiateViewController(withIdentifier: "AddAttendanceViewController") as? AddAttendanceViewController{
            self.navigationController?.pushViewController(addAttendanceDetailView, animated: true)
        }
    }
}
extension AttendanceAdminViewController:FilterDelegate{
    func didConfirmfilterParameters(filterParameters: [String : Any]) {
        self.filterParameters = filterParameters
        self.currentPage = 0
        self.arrayOfStudentAttendace.removeAll()
        //self.refreshTableView()
        DispatchQueue.global(qos: .background).async {
            self.currentPage = 0
            if let user = User.getUserFromUserDefault(){
                self.getStudentAttendanceListAPIRequest(userID: user.userId,showHud: true)
            }
        }
    }
}
extension AttendanceAdminViewController:DDTableViewDelegateDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if self.arrayOfStudentAttendace.count == 0{
                tableView.showMessageLabel(msg: "No attendance available.", backgroundColor: .white, headerHeight: 0.0)
            }else{
                tableView.removeMessageLabel()
            }
            return self.arrayOfStudentAttendace.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let homeworkCell:HomeworkTableViewCell = tableView.dequeueReusableCell(withIdentifier: "HomeworkTableViewCell", for: indexPath) as! HomeworkTableViewCell
            let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
            let classValue = NSMutableAttributedString.init(string: "\(self.arrayOfStudentAttendace[indexPath.row].className) - \(self.arrayOfStudentAttendace[indexPath.row].sectionName)", attributes: self.attributesNormal)
            let studentNameList = "\n\n\(self.arrayOfStudentAttendace[indexPath.row].studentNames)".replacingOccurrences(of:",", with:"\n")+"\n"
            let studentListAttributed = NSAttributedString.init(string: studentNameList, attributes: self.attributesNormal)
            classString.append(classValue)
            classString.append(studentListAttributed)
        
            homeworkCell.lblHomeWorkDetail.attributedText = classString//"\n\(self.arrayOfStudentAttendace[indexPath.row].studentNames)".replacingOccurrences(of:",", with:"\n")+"\n"
        
            homeworkCell.lblHomeWorkDate.text = "\(self.arrayOfStudentAttendace[indexPath.row].attendanceDate.changeDateFormateddMMYYYY)"
        
            if indexPath.row+1 == self.arrayOfStudentAttendace.count, self.isLoadMoreStudentAttendace{ //last index
                DispatchQueue.global(qos: .background).async {
                    self.currentPage += 1
                    if let user = User.getUserFromUserDefault(){
                        self.getStudentAttendanceListAPIRequest(userID: user.userId)
                    }
                }
            }
            return homeworkCell
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension//("\(self.arrayOfStudentAttendace[indexPath.row].studentNames)".count > 200) ? 200.0:UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
struct AdminAttendance: Codable {
    let attendanceDate,className,classID,sectionName,sectionID,studentNames: String
    
    enum CodingKeys: String, CodingKey {
        case attendanceDate = "absent_date"
        case studentNames = "student_name"
        case classID = "class_id"
        case className = "class_name"
        case sectionID = "divison_id"
        case sectionName = "divison_name"
    }
}
