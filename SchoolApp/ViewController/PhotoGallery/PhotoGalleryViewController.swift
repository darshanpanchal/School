//
//  FeesViewController.swift
//  SchoolApp
//
//  Created by user on 20/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import CoreData

class PhotoGalleryViewController: UIViewController {
    //navigation view
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDrawer:UIButton!
    @IBOutlet var buttonUserProfile:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewProfile:UITableView!
    @IBOutlet var tableViewHeight:NSLayoutConstraint!
    @IBOutlet var buttonDropDown:UIButton!
    
    @IBOutlet var buttonAddAlbum:RoundButton!
    
    var heightOfUserProfileTableViewCell:CGFloat{
        get{
            return 50.0
        }
    }
    
    var arrayOfUserDetail:[NSManagedObject] = []
    
    @IBOutlet var collectionViewPhotoGallery:UICollectionView!
    var arrayOfPhotoGallery:[PhotoGalleryAlbum] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupview
        self.setUpView()
        //configure saved user detail
        self.configureSavedUserProfileData()
        
        //configure photogallery collectionview
        self.configurePhotogalleryCollectionView()
        if let user = User.getUserFromUserDefault(){
            self.configureCurrentUserDetail(userID: user.userId)
            //get photoGalleryAlbum
            self.getPhotoGalleryAlbumViewAPIRequest(userID:user.userId)
        }
    }
    
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.photogallery")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonDrawer.setBackgroundImage(UIImage.init(named: "ic_arrow_back"), for: .normal)
        self.buttonDrawer.imageView?.contentMode = .scaleAspectFit
        self.buttonAddAlbum.backgroundColor = kSchoolThemeColor
    }
    func configureCurrentUserDetail(userID:String){
        APIRequestClient.shared.fetchUserDetailFromDataBase(userId: userID) { (response) in
            if let objUserCoreData:Users =  response as? Users{
                if let objURl = URL.init(string: objUserCoreData.student_photo ?? ""){
                    self.buttonUserProfile.sd_setBackgroundImage(with: objURl, for: .normal, completed: nil)
                }else{
                    self.buttonUserProfile.setBackgroundImage(UIImage.init(named:"ic_profile_circle"), for: .normal)
                }
                self.buttonUserProfile.tintColor = UIColor.clear
            }
        }
    }
    func configurePhotogalleryCollectionView(){
        let objGuideNib = UINib.init(nibName: "PhotoGalleryAlbumCollectionViewCell", bundle: nil)
        
        self.collectionViewPhotoGallery.register(objGuideNib, forCellWithReuseIdentifier:"PhotoGalleryAlbumCollectionViewCell")
        self.collectionViewPhotoGallery.delegate = self
        self.collectionViewPhotoGallery.dataSource = self
    }
    func configureSavedUserProfileData(){
        APIRequestClient.shared.fetchAllUserDetailFromDataBase{ (response) in
            self.arrayOfUserDetail = response
            self.tableViewProfile.reloadData()
            if let user = User.getUserFromUserDefault(){
                self.buttonUserProfile.isHidden = !(self.arrayOfUserDetail.count > 0 && user.userType == .student) // 2 for student and 1 for admin
                if user.userType == .student{
                    self.buttonDropDown.isHidden = !(self.arrayOfUserDetail.count > 1)
                }else{
                    self.buttonDropDown.isHidden = true //hide for admin
                }
                self.buttonAddAlbum.isHidden = (user.userType == .student)
//                self.buttonFilter.isHidden = !(self.buttonUserProfile.isHidden)
            }
        }
        let objGuideNib = UINib.init(nibName: "UserProfileTableViewCell", bundle: nil)
        self.tableViewProfile.register(objGuideNib, forCellReuseIdentifier:"UserProfileTableViewCell")
        self.tableViewProfile.delegate = self
        self.tableViewProfile.dataSource = self
        self.tableViewProfile.isScrollEnabled = false
        self.tableViewProfile.reloadData()
    }
    // MARK: - API Request Methods
    func getPhotoGalleryAlbumViewAPIRequest(userID:String){
        let dashBoardParameters = ["user_id":"\(userID)"]
        
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kPhotoGalleryAlbum, parameter:dashBoardParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfDashBoard = success["data"] as? [[String:Any]]{
                self.arrayOfPhotoGallery.removeAll()
                for objDashBoard:[String:Any] in arrayOfDashBoard{
                    let objDashBoard = PhotoGalleryAlbum.init(photoGalleryDetail: objDashBoard)
                    self.arrayOfPhotoGallery.append(objDashBoard)
                }
                DispatchQueue.main.async {
                    self.collectionViewPhotoGallery.reloadData()
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
    func pushToPhotoGalleryDetail(objPhotoAlbum:PhotoGalleryAlbum){
        if let objPhotoGallery = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGallerydetailViewController") as? PhotoGallerydetailViewController{
            objPhotoGallery.objSelectedAlbum = objPhotoAlbum
            self.navigationController?.pushViewController(objPhotoGallery, animated: true)
        }
    }
    @IBAction func buttonAddAlbumSelector(sender:UIButton){
        //add album view controller
        self.pushToAddAlbumViewController()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func pushToAddAlbumViewController(){
        if let addAlbumViewController = self.storyboard?.instantiateViewController(withIdentifier: "AddEventAlbumViewController") as? AddEventAlbumViewController{
            addAlbumViewController.delegate = self
            self.navigationController?.pushViewController(addAlbumViewController, animated: true)
        }
    }
}
extension PhotoGalleryViewController:AddEventAlbumDelegate{
    func refreshEventAlbumDelegate() {
        if let user = User.getUserFromUserDefault(){
            //get photoGalleryAlbum
            self.getPhotoGalleryAlbumViewAPIRequest(userID:user.userId)
        }
    }
}
extension PhotoGalleryViewController:UITableViewDelegate,UITableViewDataSource{
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
        return profileCell//UITableViewCell()
        
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
extension PhotoGalleryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfPhotoGallery.count == 0{
            collectionView.showMessageLabel(msg: "No events available.", backgroundColor: .white, headerHeight: 0.0)
        }else{
            collectionView.removeMessageLabel()
        }
        return self.arrayOfPhotoGallery.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dashBoardCell:PhotoGalleryAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGalleryAlbumCollectionViewCell", for: indexPath) as! PhotoGalleryAlbumCollectionViewCell
        if  self.arrayOfPhotoGallery.count > indexPath.item{
            
            
            let objAlbum = self.arrayOfPhotoGallery[indexPath.item]
            dashBoardCell.objName.text = objAlbum.albumName
            if let objURL = URL.init(string: objAlbum.albumImage){
                dashBoardCell.objImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"ic_image_icon"))
            }else{
                dashBoardCell.objImageView.image = UIImage.init(named: "ic_image_icon")
            }
            
        }
        dashBoardCell.objImageView.contentMode = .scaleAspectFill
        return dashBoardCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width/3, height:  UIScreen.main.bounds.width/2.5)//collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if let user = User.getUserFromUserDefault(){
            guard user.userType == .admin else{
                return CGSize.zero
            }
        }
        return CGSize.init(width: collectionView.bounds.width, height: 85.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0//15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.arrayOfPhotoGallery.count > indexPath.item{
            let objPhotoAlbum = self.arrayOfPhotoGallery[indexPath.item]
           self.pushToPhotoGalleryDetail(objPhotoAlbum: objPhotoAlbum)
        }
    }
}
