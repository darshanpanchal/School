//
//  TransportViewController.swift
//  SchoolApp
//
//  Created by user on 18/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class TransportViewController: UIViewController {

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
    
    @IBOutlet var tableViewTransport:UITableView!
    
    @IBOutlet var buttonBusStopDetail:UIButton!
    @IBOutlet var buttonDriverDetail:UIButton!
    
    @IBOutlet var lblBusDriverDetail:UILabel!
    
    var pickupBus:PickUpBus?
    var dropBus:DropBus?
    
    var arrayOfDriverPickUp:[DriverDetail] = []
    var arrayOfDriverDrop:[DriverDetail] = []
    
    var arrayBusStopTitle:[String] = ["Route","Area","Point","Time"]
    var arrayOfDriver:[String] = ["Driver","Conductor"]
    var isDriver:Bool = false
    var isDriverDetail:Bool{
        get{
            return isDriver
        }
        set{
            self.isDriver = newValue
            //Configure isDriver
            self.configureDriverDetail()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //setupview
        self.setUpView()
        
        //configure saved user detail
        self.configureSavedUserProfileData()
        
        //configure transport tableview
        self.configureTransportTableView()
        
        self.isDriverDetail = false
        
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            self.getDriverDetail(userID: user.userId)
            self.getTransportAPIRequest(userID: user.userId)
        }
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.Transport")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonDriverDetail.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonBusStopDetail.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        
        self.buttonDriverDetail.setTitleColor(UIColor.white, for: .normal)
        self.buttonBusStopDetail.setTitleColor(UIColor.white, for: .normal)
        
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
    func configureTransportTableView(){
        
        let objDriverNib = UINib.init(nibName: "DriverDetailTableViewCell", bundle: nil)
        self.tableViewTransport.register(objDriverNib, forCellReuseIdentifier:"DriverDetailTableViewCell")
        
        let objGuideNib = UINib.init(nibName: "BusStopDetailTableViewCell", bundle: nil)
        self.tableViewTransport.register(objGuideNib, forCellReuseIdentifier:"BusStopDetailTableViewCell")
        self.tableViewTransport.delegate = self
        self.tableViewTransport.dataSource = self
        self.tableViewTransport.isScrollEnabled = true
        self.tableViewTransport.estimatedRowHeight = 100.0
        self.tableViewTransport.rowHeight =  UITableView.automaticDimension
        self.tableViewTransport.reloadData()
    }
    func configureDriverDetail(){
        if self.isDriverDetail{
            self.lblBusDriverDetail.text = Vocabulary.getWordFromKey(key: "genral.DriverDetail")
        }else{
            self.lblBusDriverDetail.text = Vocabulary.getWordFromKey(key: "genral.busStopDetailt")
        }
        DispatchQueue.main.async {
            self.tableViewTransport.reloadData()
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
    // MARK: - API Request Methods
    func getTransportAPIRequest(userID:String){
        let logInParameters = ["user_id":"\(userID)"]
        
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kTransportBusStop, parameter:logInParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any]{
                if let pickUpJSON = successData["pickup"],!(pickUpJSON is NSNull){
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:pickUpJSON, options:.prettyPrinted)
                        if let  objpickUpBus = try? JSONDecoder().decode(PickUpBus.self, from: jsondata){
                            self.pickupBus = objpickUpBus
                        }
                    }catch{
                        
                    }
                }
                if let dropbusJSON = successData["drop"],!(dropbusJSON is NSNull){
                    do{
                        let jsondata = try JSONSerialization.data(withJSONObject:dropbusJSON, options:.prettyPrinted)
                        if let  objdropBus = try? JSONDecoder().decode(DropBus.self, from: jsondata){
                            self.dropBus = objdropBus
                        }
                    }catch{
                        
                    }
                }
               

                DispatchQueue.main.async {
                    self.tableViewTransport.reloadData()
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
    func getDriverDetail(userID:String){
        let logInParameters = ["user_id":"\(userID)"]
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kTransportDriver, parameter:logInParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successData = success["data"] as? [String:Any]{
                
                if let arrayOfPickUp:[[String:Any]] = successData["pickup"] as? [[String:Any]]{
                    self.arrayOfDriverPickUp.removeAll()
                    for objPickUpDriver in arrayOfPickUp{
                        do{
                            let jsondata = try JSONSerialization.data(withJSONObject:objPickUpDriver, options:.prettyPrinted)
                            if let  objpickUpBus = try? JSONDecoder().decode(DriverDetail.self, from: jsondata){
                                self.arrayOfDriverPickUp.append(objpickUpBus)
                            }
                        }catch{
                            
                        }
                    }
                }
                if let arrayOfPickUp:[[String:Any]] = successData["drop"] as? [[String:Any]]{
                    self.arrayOfDriverDrop.removeAll()
                    for objPickUpDriver in arrayOfPickUp{
                        do{
                            let jsondata = try JSONSerialization.data(withJSONObject:objPickUpDriver, options:.prettyPrinted)
                            if let  objpickUpBus = try? JSONDecoder().decode(DriverDetail.self, from: jsondata){
                                self.arrayOfDriverDrop.append(objpickUpBus)
                            }
                        }catch{
                            
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableViewTransport.reloadData()
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
    @IBAction func buttonBusStopDetail(sender:UIButton){
        self.isDriverDetail = false
    }
    @IBAction func buttonDriverDetail(sender:UIButton){
        self.isDriverDetail = true
    }
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
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
extension TransportViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableViewProfile{
            return self.arrayOfUserDetail.count
        }else{
            if self.isDriverDetail{
                return self.arrayOfDriver.count
            }else{
                return self.arrayBusStopTitle.count
            }
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView != self.tableViewProfile{
            if self.isDriverDetail{
                let driverCell:DriverDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "DriverDetailTableViewCell", for: indexPath) as! DriverDetailTableViewCell
                if indexPath.row == 0{
                    driverCell.lblTitle.text = "Driver"
                    if self.arrayOfDriverPickUp.count > 0{
                        driverCell.lblPickUpName.text = self.arrayOfDriverPickUp.first!.name
                        driverCell.lblPickUpMobile.text = self.arrayOfDriverPickUp.first!.mobileNo
                    }
                    if self.arrayOfDriverDrop.count > 0{
                        driverCell.lblDropName.text = self.arrayOfDriverDrop.first!.name
                        driverCell.lblDropMobile.text = self.arrayOfDriverDrop.first!.mobileNo
                    }
                   
                }else{
                    if self.arrayOfDriverPickUp.count > 0{
                        driverCell.lblPickUpName.text = self.arrayOfDriverPickUp.last!.name
                        driverCell.lblPickUpMobile.text = self.arrayOfDriverPickUp.last!.mobileNo
                    }
                    if self.arrayOfDriverDrop.count > 0{
                        driverCell.lblDropName.text = self.arrayOfDriverDrop.last!.name
                        driverCell.lblDropMobile.text = self.arrayOfDriverDrop.last!.mobileNo
                    }
                    driverCell.lblTitle.text = "Conductor"
                }
                return driverCell
            }else{
                let busCell:BusStopDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BusStopDetailTableViewCell", for: indexPath) as! BusStopDetailTableViewCell
                busCell.lblTitle.text = self.arrayBusStopTitle[indexPath.row]
                if indexPath.item % 2 != 0{
                    busCell.containerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.25)
                }else{
                    busCell.containerView.backgroundColor = UIColor.white
                }
                
                if let _ = self.pickupBus,let _ = dropBus{
                    if indexPath.row == 0{
                        busCell.lblPickUp.text = "\(self.pickupBus!.route)"
                        busCell.lblDrop.text = "\(self.dropBus!.route)"
                    }else if indexPath.row == 1{
                        busCell.lblPickUp.text = "\(self.pickupBus!.area)"
                        busCell.lblDrop.text = "\(self.dropBus!.area)"
                    }else if indexPath.row == 2{
                        busCell.lblPickUp.text = "\(self.pickupBus!.point)"
                        busCell.lblDrop.text = "\(self.dropBus!.point)"
                    }else if indexPath.row == 3{
                        busCell.lblPickUp.text = "\(self.pickupBus!.time)"
                        busCell.lblDrop.text = "\(self.dropBus!.time)"
                    }else{
                        busCell.lblPickUp.text = ""
                        busCell.lblDrop.text = ""
                    }
                }
                return busCell
            }
            
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
        if tableView != self.tableViewProfile{
            if self.isDriverDetail{
                return 105.0
            }else{
                return UITableView.automaticDimension
            }
        }else{
            return self.heightOfUserProfileTableViewCell
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.tableViewProfile == tableView else {
            return
        }
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
struct PickUpBus: Codable {
    let studentID, area, point, route: String
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case area, point, route, time
    }
}
struct DropBus: Codable {
    let studentID, area, point, route: String
    let time: String
    
    enum CodingKeys: String, CodingKey {
        case studentID = "student_id"
        case area, point, route, time
    }
}
struct DriverDetail: Codable {
    let name, designation, mobileNo: String
    
    enum CodingKeys: String, CodingKey {
        case name, designation
        case mobileNo = "mobile_no"
    }
}
