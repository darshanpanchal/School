//
//  AddEventAlbumViewController.swift
//  SchoolApp
//
//  Created by user on 06/08/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import QuickLook


protocol AddEventAlbumDelegate {
    func refreshEventAlbumDelegate()
}
class AddEventAlbumViewController: UIViewController {

    var delegate:AddEventAlbumDelegate?
    
    fileprivate let kNoticeClassID = "class_id"
    fileprivate let kNoticeSectionID = "divison_id"
    fileprivate let kNoticeDate = "album_name"
    fileprivate let kNoticeDescription = "description"
    
    
    
    @IBOutlet var navigationView:UIView!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var tableViewAddNotice:UITableView!
    
    
    @IBOutlet var txtFeildClass:TweeActiveTextField!
    @IBOutlet var txtViewClass:UITextView!
    
    @IBOutlet var txtFeildSection:TweeActiveTextField!
    @IBOutlet var txtViewSection:UITextView!
    
    @IBOutlet var txtFieldDate:TweeActiveTextField!
    
    @IBOutlet var txtFeildDescription:TweeActiveTextField!
    @IBOutlet var txtViewDescription:UITextView!
    
    @IBOutlet var buttonSubmit:RoundButton!
    
    @IBOutlet var buttonAttachMent:RoundButton!
    
    @IBOutlet var viewFileTypeContainer:UIView!
    
    @IBOutlet var collectionViewPhotoGallery:UICollectionView!
    
    var noticeDatePicker:UIDatePicker = UIDatePicker()
    var noticeDatePickerToolbar:UIToolbar = UIToolbar()
    
    var schoolOptions:[SchoolClass] = []
    var classOptions:[SchoolClass] = []
    
    var selectedClass:[SchoolClass]?
    
    var sectionOptions:[StudentSection] = []
    var selectedSection:[StudentSection]?
    
    var addNoticeParameters:[String:Any] = [:]
    var objImagePickerController = UIImagePickerController()
    
    var arrayOfPhotoGallery:[PhotoGalleryAlbum] = []
    
    var previewItem:NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //setupview
        self.setUpView()
        
        //get school API Request
        self.getSchoolAPIRequest()
        
        
        //configure photogallery collectionview
        self.configurePhotogalleryCollectionView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"Add Event Album")
        self.lblTitle.font = CommonClass.shared.titleFont
        
        self.txtFeildClass.tweePlaceholder = "Class"
        self.txtFeildSection.tweePlaceholder = "Section"
        self.txtFieldDate.tweePlaceholder = "Name"
        self.txtFeildDescription.tweePlaceholder = "Discription"
        
        self.txtViewClass.delegate = self
        self.txtViewSection.delegate = self
        self.txtViewDescription.delegate = self
        
        self.configureFloatTextField(txtfield: self.txtFeildClass)
        self.configureFloatTextField(txtfield: self.txtFeildSection)
        self.configureFloatTextField(txtfield: self.txtFieldDate)
        self.configureFloatTextField(txtfield: self.txtFeildDescription)
        
        //        self.txtViewClass.text = "Test,One,Three"
        //        self.txtFeildClass.minimizePlaceholder()
        
        self.noticeDatePicker.date = Date()
        
        self.buttonSubmit.setTitleColor(UIColor.white, for: .normal)
        self.buttonSubmit.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        
        self.buttonAttachMent.setTitle("Upload Image", for: .normal)
        self.buttonAttachMent.setBackgroundColor(color: kSchoolThemeColor, forState: .normal)
        self.buttonAttachMent.setTitleColor(UIColor.white, for: .normal)
        
        self.configurenoticeDatePicker()
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
    func isValidNewNotice()->Bool{
        guard "\(self.addNoticeParameters[kNoticeClassID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildClass)
                ShowToast.show(toatMessage: "Please select class.")
            }
            return false
        }
        guard "\(self.addNoticeParameters[kNoticeSectionID] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildSection)
                ShowToast.show(toatMessage: "Please select section.")
            }
            return false
        }
        guard "\(self.addNoticeParameters[kNoticeDate] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFieldDate)
                
                ShowToast.show(toatMessage: "Please add event album name.")
            }
            return false
        }
        guard "\(self.addNoticeParameters[kNoticeDescription] ?? "")".count > 0 else {
            DispatchQueue.main.async {
                self.invalidTextField(textField: self.txtFeildDescription)
                ShowToast.show(toatMessage: "Please add event album description.")
            }
            return false
        }
        /*guard self.arrayOfPhotoGallery.count > 0  else {
            DispatchQueue.main.async {
                ShowToast.show(toatMessage: "Please add event album image.")
            }
            return false
        }*/
        return true
    }
    func configurePhotogalleryCollectionView(){
        let objGuideNib = UINib.init(nibName: "PhotoGalleryAlbumCollectionViewCell", bundle: nil)
        
        self.collectionViewPhotoGallery.register(objGuideNib, forCellWithReuseIdentifier:"PhotoGalleryAlbumCollectionViewCell")
        self.collectionViewPhotoGallery.delegate = self
        self.collectionViewPhotoGallery.dataSource = self
    }
    func configurenoticeDatePicker(){
        
        self.noticeDatePickerToolbar.sizeToFit()
        self.noticeDatePickerToolbar.layer.borderColor = UIColor.clear.cgColor
        self.noticeDatePickerToolbar.layer.borderWidth = 1.0
        self.noticeDatePickerToolbar.clipsToBounds = true
        self.noticeDatePickerToolbar.backgroundColor = UIColor.white
        self.noticeDatePicker.datePickerMode = .date
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: 7, to: Date())
        //        self.noticeDatePicker.maximumDate = sevenDaysAgo
        
        let doneButton = UIBarButtonItem(title: Vocabulary.getWordFromKey(key:"Done"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddEventAlbumViewController.doneFormDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let title = UILabel.init()
        title.attributedText = NSAttributedString.init(string: "\(Vocabulary.getWordFromKey(key:"Select Date"))", attributes:[NSAttributedString.Key.font:UIFont.init(name:"Avenir-Heavy", size: 15.0)!])
        
        title.sizeToFit()
        let cancelButton = UIBarButtonItem(title:Vocabulary.getWordFromKey(key:"Cancel"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(AddEventAlbumViewController.cancelFormDatePicker))
        self.noticeDatePickerToolbar.setItems([cancelButton,spaceButton,UIBarButtonItem.init(customView: title),spaceButton,doneButton], animated: false)
        
        
        //self.txtFieldDate.inputView = self.noticeDatePicker
        //self.txtFieldDate.inputAccessoryView = self.noticeDatePickerToolbar
    }
    @objc func doneFormDatePicker(){
        let date =  self.noticeDatePicker.date
        self.txtFieldDate.text = date.ddMMyyyy
        self.addNoticeParameters[kNoticeDate] = date.ddMMyyyy
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        if let _ = self.delegate{
            self.delegate!.refreshEventAlbumDelegate()
        }
        self.navigationController?.popViewController(animated: true)
        //        SideMenu.show()
    }
    @IBAction func buttonSubmitSelector(sender:UIButton){
        
        //Add album without any image API request
        self.addEventAlbumAPIRequest()
    }
    @IBAction func buttonUploadAttachmentSelector(sender:UIButton){
        //Create Event album and redirect to single image upload screen with album id
        self.addEventAlbumAPIRequest()
        /*
        //PresentMedia Selector
        let actionSheetController = UIAlertController.init(title: "", message:"Upload Image", preferredStyle: .actionSheet)
        let cancelSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Cancel"), style: .cancel, handler:nil)
        cancelSelector.setValue(kSchoolThemeColor, forKey: "titleTextColor")
        actionSheetController.addAction(cancelSelector)
        
        
        let cameraSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Camera"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .camera
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        cameraSelector.setValue(kSchoolThemeColor, forKey: "titleTextColor")
        actionSheetController.addAction(cameraSelector)
        
        let photosSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.objImagePickerController = UIImagePickerController()
                self.objImagePickerController.sourceType = .savedPhotosAlbum
                self.objImagePickerController.delegate = self
                self.objImagePickerController.allowsEditing = false
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        photosSelector.setValue(kSchoolThemeColor, forKey: "titleTextColor")
        actionSheetController.addAction(photosSelector)
        
        self.view.endEditing(true)
        self.present(actionSheetController, animated: true, completion: nil)
        */
    }
    @IBAction func buttonPreviewSelector(sender:UIButton){
        self.presentQuickPreviewOfAttachment()
    }
    func presentImagePickerController(){
        self.view.endEditing(true)
        self.present(self.objImagePickerController, animated: true, completion: nil)
        
    }
    func presentQuickPreviewOfAttachment(){
        if let _ = self.previewItem{
            UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
            let previewController = QLPreviewController()
            previewController.dataSource = self
            previewController.delegate = self
            previewController.currentPreviewItemIndex = 0
            self.present(previewController, animated: true, completion: {
                UIApplication.shared.statusBarView?.backgroundColor = UIColor.white
            })
        }
    }
    func sizeHeaderFit(){
        if let headerView =  self.tableViewAddNotice.tableHeaderView {
            headerView.setNeedsLayout()
            headerView.layoutIfNeeded()
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = headerView.frame
            frame.size.height = height
            headerView.frame = frame
            self.tableViewAddNotice.tableHeaderView = headerView
            self.view.layoutIfNeeded()
        }
    }
    func sizeFooterToFit() {
        if let footerView =  self.tableViewAddNotice.tableFooterView {
            footerView.setNeedsLayout()
            footerView.layoutIfNeeded()
            
            let height = footerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var frame = footerView.frame
            frame.size.height = height
            footerView.frame = frame
            self.tableViewAddNotice.tableFooterView = footerView
            self.view.layoutIfNeeded()
        }
    }
    // MARK: - API Request Methods
    func addEventAlbumAPIRequest(){
        if self.isValidNewNotice(){
            
            var fileData:[Data] = []
            let isPDfData = false
            /*
             if let preview = self.previewItem{
             do {
             let imageData = try Data(contentsOf: preview as URL)
             if preview.pathExtension == "pdf"{
             isPDfData = true
             }
             
             fileData = imageData
             } catch {
             print("Unable to load data: \(error)")
             }
             }
             */
            for objImage in self.arrayOfPhotoGallery{
                do{
                    if let objURL = URL.init(string: objImage.albumImage){
                        let imageData:Data = try Data(contentsOf: objURL as URL)
                        fileData.append(imageData)
                    }
                }catch{
                    print("Unable to load data: \(error)")
                }
            }
            
            APIRequestClient.shared.uploadMultipleImage(requestType: .POST, queryString:kAddEventAlbum , parameter: self.addNoticeParameters as [String:AnyObject], imageData: fileData,isPDF:isPDfData, isHudeShow: true, success: { (responseSuccess) in
                print(responseSuccess)
                DispatchQueue.main.async {
                    ProgressHud.hide()
                }
                if let success = responseSuccess as? [String:Any],let strMSG = success["message"]{
                    DispatchQueue.main.async {
                        if let albumJSON = success["data"] as? [String:Any],let albumID = albumJSON["album_id"]{
                            let albumUpdateJSON = ["event_galllery_id":"\(albumID)","album_name":"\(self.addNoticeParameters[self.kNoticeDate]!)"]
                            self.pushToPhotoGalleryDetail(objPhotoAlbum: PhotoGalleryAlbum.init(photoGalleryDetail:albumUpdateJSON))
                        }
                        //self.navigationController?.popViewController(animated: true)
                        ShowToast.show(toatMessage: "\(strMSG)")
                    }
                }else{
                    DispatchQueue.main.async {
                        //self.navigationController?.popViewController(animated: true)
                        ShowToast.show(toatMessage: "Album Added Successfully.")
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
                schoolClassPicker.isSingleSelection = false
                if let _ = self.selectedClass{
                    schoolClassPicker.selectedSchoolClass = NSMutableSet.init(array:self.selectedClass!.map{$0.strClassId})
                }
                self.present(schoolClassPicker, animated: true, completion: nil)
            }
        }
    }
   
}
extension AddEventAlbumViewController:UITextViewDelegate{
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
            //PreesntClass Picker
            self.presentSectionSearchViewController()
        }else if textView == self.txtViewDescription{
            self.txtFeildDescription.resignFirstResponder()
            self.txtFeildDescription.minimizePlaceholder()
            textView.becomeFirstResponder()
        }
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == self.txtViewSection{
            if let array = self.selectedClass,array.count > 0{
                return true
            }else{
                DispatchQueue.main.async {
                    self.invalidTextField(textField: self.txtFeildClass)
                    ShowToast.show(toatMessage: "Please select class to add event album.")
                }
                return false
            }
        }
        return true
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let typpedString = ((textView.text)! as NSString).replacingCharacters(in: range, with: text)
        
        if text == "\n"{
            textView.resignFirstResponder()
            return true
        }
        if textView == self.txtViewDescription{
            self.addNoticeParameters[kNoticeDescription] = "\(typpedString)"
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

extension AddEventAlbumViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let typpedString = ((textField.text)! as NSString).replacingCharacters(in: range, with: string)
        
//        guard !typpedString.isContainWhiteSpace() else{
//            return false
//        }
        self.addNoticeParameters[kNoticeDate] = "\(typpedString)"
        self.validTextField(textField: self.txtFieldDate)
        return true
    }
    
}
extension AddEventAlbumViewController:SearchViewDelegate{
    func didSelectValuesFromSearchView(values: [Any],searchType:SearchType) {
        if searchType == .SchoolClass{
            if let arrayOfClass = values as? [SchoolClass]{
                let objArray = arrayOfClass.map{$0.strName}
                let objArrayId = arrayOfClass.map{$0.strClassId}
                if objArrayId.count > 0{
                    self.addNoticeParameters[kNoticeClassID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.addNoticeParameters[kNoticeClassID] = ""
                }
                self.validTextField(textField: self.txtFeildClass)
                if objArray.count > 0{
                    self.selectedClass = arrayOfClass
                    self.txtViewClass.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildClass.minimizePlaceholder()
                    self.getStudentSectionBasedOnClass(classID: objArrayId.first!)
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
                    self.addNoticeParameters[kNoticeSectionID] = "\(objArrayId.reversed().joined(separator: ","))"
                }else{
                    self.addNoticeParameters[kNoticeSectionID] = ""
                }
                self.validTextField(textField: self.txtFeildSection)
                if objArray.count > 0{
                    self.selectedSection = arrayOfSection
                    self.txtViewSection.text = "\(objArray.reversed().joined(separator: ", "))"
                    self.txtFeildSection.minimizePlaceholder()
                }else{
                    self.selectedSection = []
                    self.txtViewSection.text = ""
                    self.txtFeildSection.maximizePlaceholder()
                }
            }
        }
        
        defer {
            self.sizeHeaderFit()
        }
    }
}
extension AddEventAlbumViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          print(info)
        let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as! NSURL

        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: false, completion: nil)
            return
        }
       
        if let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            self.previewItem = NSURL.init(string: "\(imageURL.absoluteString)")
            if let _ = self.previewItem{
                let objImage = PhotoGalleryAlbum.init(photoGalleryDetail: ["attachment":"\(self.previewItem!)"])
                self.arrayOfPhotoGallery.append(objImage)
                DispatchQueue.main.async {
                    self.collectionViewPhotoGallery.reloadData()
                }
            }
           
        }else{
            UIImageWriteToSavedPhotosAlbum(originalImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

            //UIImageWriteToSavedPhotosAlbum(originalImage, self, #selector(image(path:didFinishSavingWithError:contextInfo:)), nil)
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}

extension AddEventAlbumViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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
extension AddEventAlbumViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /*
        if self.arrayOfPhotoGallery.count == 0{
            collectionView.showMessageLabel(msg: "No events available.", backgroundColor: .white, headerHeight: 0.0)
        }else{
            collectionView.removeMessageLabel()
        }*/
        return self.arrayOfPhotoGallery.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dashBoardCell:PhotoGalleryAlbumCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGalleryAlbumCollectionViewCell", for: indexPath) as! PhotoGalleryAlbumCollectionViewCell
        dashBoardCell.objNameContainer.isHidden = true
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
        dashBoardCell.layer.borderColor = UIColor.black.cgColor
        dashBoardCell.layer.borderWidth = 0.75
        return dashBoardCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width/3, height:  UIScreen.main.bounds.width/2.5)//collectionView.bounds.size.width*0.5+50+30)
    }
   
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.arrayOfPhotoGallery.count > indexPath.item{
            let objPhotoAlbum = self.arrayOfPhotoGallery[indexPath.item]
            self.pushToPhotoGalleryDetail(objPhotoAlbum: objPhotoAlbum)
        }
    }
    func pushToPhotoGalleryDetail(objPhotoAlbum:PhotoGalleryAlbum){
        if let objPhotoGallery = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGallerydetailViewController") as? PhotoGallerydetailViewController{
            objPhotoGallery.objSelectedAlbum = objPhotoAlbum
            objPhotoGallery.isForAdmin = true
            self.navigationController?.pushViewController(objPhotoGallery, animated: true)
        }
    }
}
