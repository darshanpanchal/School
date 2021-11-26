//
//  PhotoGallerydetailViewController.swift
//  SchoolApp
//
//  Created by user on 25/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MobileCoreServices
import OpalImagePicker
import PhotosUI

class PhotoGallerydetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    //navigation
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonDelete:UIButton!
    
    
    @IBOutlet var collectionViewPhotoGallery:UICollectionView!
    var arrayOfPhotoGallery:[PhotoGallery] = []
    @IBOutlet var buttonAddAlbum:RoundButton!
    var objSelectedAlbum:PhotoGalleryAlbum?
    var objImagePickerController = UIImagePickerController()
    var previewItem:NSURL?
    var isForAdmin:Bool = false
    var itemsSelected : [IndexPath:Bool] = [:]
    var isEdit: Bool = false
    var selectedImagesAry:[String] = []
    
    var objectSet:NSMutableSet = NSMutableSet()
    var longPressGR = UILongPressGestureRecognizer()
    var objSelectedImageMutableSet:NSMutableSet{
        get{
            return objectSet
        }
        set{
            self.objectSet = newValue
            //Configure Application edit state
            print("====== \(newValue.count) ======")
        }
        
        
    }
    
    var isEditImageDelete:Bool{
        return self.objSelectedImageMutableSet.count > 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //setup view
        self.setUpView()
        if let currentUser = User.getUserFromUserDefault(){
            if currentUser.userType == .admin{
                self.setupLongPressGesture()
            }
        }
        self.configurePhotogalleryCollectionView()
        self.collectionViewPhotoGallery.allowsMultipleSelection = true
        if let user = User.getUserFromUserDefault(),let _ = self.objSelectedAlbum{
            self.lblTitle.text = self.objSelectedAlbum!.albumName
            //get photoGalleryAlbum
            self.getPhotoGalleryAlbumViewAPIRequest(userID:user.userId,albumID:self.objSelectedAlbum!.albumID)
            self.buttonAddAlbum.isHidden = (user.userType == .student)
        }
    }
    func setupLongPressGesture(){
        self.longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(longPressGR:)))
        self.longPressGR.minimumPressDuration = 0.5
        self.longPressGR.delaysTouchesBegan = false
        self.collectionViewPhotoGallery.isUserInteractionEnabled = true
        self.collectionViewPhotoGallery.addGestureRecognizer(longPressGR)
    }
    
    @objc func handleLongPress(longPressGR: UILongPressGestureRecognizer) {
        
        if longPressGR.state == .began{
            
            let point = longPressGR.location(in: self.collectionViewPhotoGallery)
            let indexPath = self.collectionViewPhotoGallery.indexPathForItem(at: point)
            
            if let indexPath = indexPath {
                _ = self.collectionViewPhotoGallery.cellForItem(at: indexPath) as? PhotoGalleryAlbumCollectionViewCell
                let objPhotoAlbum = self.arrayOfPhotoGallery[indexPath.item]
                self.buttonDelete.isHidden = false
                self.objSelectedImageMutableSet.add(objPhotoAlbum.id)
                self.itemsSelected[indexPath] = true
                
                DispatchQueue.main.async {
                    self.collectionViewPhotoGallery.reloadData()
                }
                self.isEdit = true
            } else {
                print("Could not find index path")
            }
        }
        if longPressGR.state != .ended {
            return
        }
    }
    func configurePhotogalleryCollectionView(){
        let objGuideNib = UINib.init(nibName: "PhotoGalleryAlbumCollectionViewCell", bundle: nil)
        
        self.collectionViewPhotoGallery.register(objGuideNib, forCellWithReuseIdentifier:"PhotoGalleryAlbumCollectionViewCell")
        self.collectionViewPhotoGallery.delegate = self
        self.collectionViewPhotoGallery.dataSource = self
    }
    // MARK: - API Request Methods
    func getPhotoGalleryAlbumViewAPIRequest(userID:String,albumID:String){
        let dashBoardParameters = ["user_id":"\(userID)","event_id":"\(albumID)"]
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kPhotoGalleryAlbumGallery, parameter:dashBoardParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let arrayOfDashBoard = success["data"] as? [[String:Any]]{
                self.objSelectedImageMutableSet.removeAllObjects()
                self.arrayOfPhotoGallery.removeAll()
                for objPhotoGallery:[String:Any] in arrayOfDashBoard{
                    if let id = objPhotoGallery["pk"],let galleryID = objPhotoGallery["event_galllery_id"],let image:String = objPhotoGallery["attachment"] as? String,
                        let objImage = image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                        
                        self.arrayOfPhotoGallery.append(PhotoGallery.init(id: "\(id)", galleryID: "\(galleryID)", image: "\(objImage)"))
                    }
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
    func uploadImageToCreateAlbumAndUpdate(objImage:UIImage){
        
        
        if let _ = self.objSelectedAlbum,let compressedData:Data = objImage.jpeg(.lowest) as? Data,let objCompressedImage = UIImage.init(data: compressedData) as? UIImage,let imageData = objCompressedImage.pngData(){
            let uploadImageParameters = ["album_id":"\(self.objSelectedAlbum!.albumID)"]
            APIRequestClient.shared.uploadMultipleImage(requestType: .POST, queryString:kUploadAlbumSingleImage , parameter: uploadImageParameters as [String:AnyObject], imageData: [imageData],isPDF:false, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let arrayOfDashBoard = success["data"] as? [[String:Any]]{
                    
                    self.arrayOfPhotoGallery.removeAll()
                    for objPhotoGallery:[String:Any] in arrayOfDashBoard{
                        if let id = objPhotoGallery["pk"],let galleryID = objPhotoGallery["event_galllery_id"],let image:String = objPhotoGallery["attachment"] as? String,
                            let objImage = image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                            self.arrayOfPhotoGallery.append(PhotoGallery.init(id: "\(id)", galleryID: "\(galleryID)", image: "\(objImage)"))
                        }
                    }
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                        self.objSelectedImageMutableSet.removeAllObjects()
                        self.itemsSelected.removeAll()
                        self.buttonDelete.isHidden = true
                        self.isEdit = false
                        self.collectionViewPhotoGallery.reloadData()
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
    func uploadMultipleImagesToCreateAlbumAndUpdate(arrayOfData:[Data]){
        if let _ = self.objSelectedAlbum,arrayOfData.count > 0{
            let uploadImageParameters = ["album_id":"\(self.objSelectedAlbum!.albumID)"]
            APIRequestClient.shared.uploadMultipleImage(requestType: .POST, queryString:kUploadAlbumSingleImage , parameter: uploadImageParameters as [String:AnyObject], imageData:arrayOfData,isPDF:false, isHudeShow: true, success: { (responseSuccess) in
                if let success = responseSuccess as? [String:Any],let arrayOfDashBoard = success["data"] as? [[String:Any]]{
                    
                    self.arrayOfPhotoGallery.removeAll()
                    for objPhotoGallery:[String:Any] in arrayOfDashBoard{
                        if let id = objPhotoGallery["pk"],let galleryID = objPhotoGallery["event_galllery_id"],let image:String = objPhotoGallery["attachment"] as? String,
                            let objImage = image.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed){
                            self.arrayOfPhotoGallery.append(PhotoGallery.init(id: "\(id)", galleryID: "\(galleryID)", image: "\(objImage)"))
                        }
                    }
                    DispatchQueue.main.async {
                        ProgressHud.hide()
                        self.objSelectedImageMutableSet.removeAllObjects()
                        self.itemsSelected.removeAll()
                        self.collectionViewPhotoGallery.reloadData()
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
    func showDeleteAlert(){
        self.presentDeleteAlertController()
    }
    func deleteMultipleImageAPIRequest(){
        var iamgeDeleteaParameters:[String:Any] = [:]
        if let objStringID = self.objSelectedImageMutableSet.allObjects as? [String]{
            iamgeDeleteaParameters["image_id"] = "\(objStringID.joined(separator: ","))"
        }
        print(iamgeDeleteaParameters)
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kDeleteSingleImage, parameter:iamgeDeleteaParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successMessage = success["message"] as? String{
                DispatchQueue.main.async {
                    print(successMessage)
                    ShowToast.show(toatMessage: successMessage)
                    var deleteNeedIndexPaths: [IndexPath] = []
                    for (key,value) in  self.itemsSelected{
                        if value{
                            deleteNeedIndexPaths.append(key)
                        }
                    }
                    for i in deleteNeedIndexPaths.sorted(by: { $0.item > $1.item}){
                        self.arrayOfPhotoGallery.remove(at: i.item)
                    }
                    self.collectionViewPhotoGallery.deleteItems(at: deleteNeedIndexPaths)
                    self.itemsSelected.removeAll()
                    self.objSelectedImageMutableSet.removeAllObjects()
                    self.buttonDelete.isHidden = true
                    self.isEdit = false
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
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.NoticeDetail")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonBack.imageView?.contentMode = .scaleAspectFit
        self.buttonAddAlbum.backgroundColor = kSchoolThemeColor
    }
    func presentDeleteAlertController(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController{
            let alert = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Delete"), message: Vocabulary.getWordFromKey(key: "Are you sure you want to delete?"), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.yes"), style: .default, handler: { action -> Void in
                
                self.deleteMultipleImageAPIRequest()
                
            })
            let noAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.no"), style: .cancel, handler: nil)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            alert.view.tintColor = kSchoolThemeColor
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    // MARK: - Selector Methods
    @IBAction func buttonDeleteSelector(sender:UIButton){
        if self.objSelectedImageMutableSet.count == 0{
            ShowToast.show(toatMessage: "Please select at least one image to delete")
            let image = UIImage(named: "delete_update")?.withRenderingMode(.alwaysTemplate)
            self.buttonDelete.setImage(image, for: .normal)
            self.buttonDelete.tintColor = UIColor.white
        }else{
            self.showDeleteAlert()
        }
        
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: PhotoGalleryViewController.self) {
                if let objPhotoGalleryViewController = controller as? PhotoGalleryViewController{
                    objPhotoGalleryViewController.refreshEventAlbumDelegate()
                }
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    @IBAction func buttonUploadAttachmentSelector(sender:UIButton){
        
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
                self.objImagePickerController.allowsEditing = true
                self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                self.view.endEditing(true)
                self.presentImagePickerController()
            }
        }
        cameraSelector.setValue(kSchoolThemeColor, forKey: "titleTextColor")
        actionSheetController.addAction(cameraSelector)
        
        let photosSelector = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"Photos"), style: .default) { (_) in
            DispatchQueue.main.async {
                self.presentMultipleImages()
                /*
                 self.objImagePickerController = UIImagePickerController()
                 self.objImagePickerController.sourceType = .savedPhotosAlbum
                 self.objImagePickerController.delegate = self
                 self.objImagePickerController.allowsEditing = false
                 self.objImagePickerController.mediaTypes = [kUTTypeImage as String]
                 self.view.endEditing(true)
                 self.presentImagePickerController()
                 */
            }
        }
        photosSelector.setValue(kSchoolThemeColor, forKey: "titleTextColor")
        actionSheetController.addAction(photosSelector)
        
        self.view.endEditing(true)
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
    func presentMultipleImages(){
        let imagePicker = OpalImagePickerController()
        presentOpalImagePickerController(imagePicker, animated: true,
                                         select: { (assets) in
                                            self.dismiss(animated: true, completion: {
                                                var imagesData:[Data] = []
                                                for objAssest in assets{
                                                    if objAssest.imageData.count > 0{
                                                        let objOriginalImageData = objAssest.imageData
                                                        if let objImage = UIImage.init(data: objOriginalImageData){
                                                            if let compressedData:Data = objImage.jpeg(.lowest) as? Data,let objCompressedImage = UIImage.init(data: compressedData) as? UIImage{
                                                                print("Original :- \(Double(objOriginalImageData.count) / 1024.0 / 1024) MB Compressed :- \(Double(compressedData.count) / 1024.0 / 1024) MB")
                                                                imagesData.append(objCompressedImage.pngData() ?? compressedData)
                                                            }
                                                        }
                                                    }else{
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                self.uploadMultipleImagesToCreateAlbumAndUpdate(arrayOfData: imagesData)
                                            })
        }, cancel: {
            self.dismiss(animated: true, completion: {
                
            })
            
        })
    }
    
    // MARK: - Navigation
    func presentPhotoGllaryPreview(index:Int){
        if let preview = self.storyboard?.instantiateViewController(withIdentifier: "PhotoGalleryPreviewViewController") as? PhotoGalleryPreviewViewController{
            preview.arrayOfPhotoGallery = self.arrayOfPhotoGallery
            preview.currentIndex = index
            preview.deleteDelegate = self
            self.present(preview, animated: true, completion: nil)
        }
    }
    func presentImagePickerController(){
        self.view.endEditing(true)
        self.present(self.objImagePickerController, animated: true, completion: nil)
        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    
}
extension PhotoGallerydetailViewController:PhotoGalleryPreviewDelete{
    
    func deletePhotoGallery(updateArray: [PhotoGallery]) {
        self.arrayOfPhotoGallery = updateArray
        DispatchQueue.main.async {
            self.collectionViewPhotoGallery.reloadData()
        }
    }
}
extension PhotoGallerydetailViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            dismiss(animated: false, completion: nil)
            return
        }
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.uploadImageToCreateAlbumAndUpdate(objImage: editedImage)
        }else {
            self.uploadImageToCreateAlbumAndUpdate(objImage: originalImage)
        }
        
        
        /*
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
         }*/
        
        
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

extension PhotoGallerydetailViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
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
            
            dashBoardCell.objName.text = "\(indexPath.row)"//self.arrayOfDashBoardDetail[indexPath.item].moduleName
            let objAlbum = self.arrayOfPhotoGallery[indexPath.item]
            
            if let objURL = URL.init(string: objAlbum.image){
                
                dashBoardCell.objImageView.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"ic_image_icon"))
            }else{
                dashBoardCell.objImageView.image = UIImage.init(named:"ic_image_icon")
            }
            if self.objSelectedImageMutableSet.contains(objAlbum.id) {
                dashBoardCell.objSelectedImage.isHidden = false
            } else {
                dashBoardCell.objSelectedImage.isHidden = true
            }
        }
        dashBoardCell.objNameContainer.isHidden = true
        dashBoardCell.objImageView.contentMode = .scaleAspectFill
        
        return dashBoardCell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize.init(width: UIScreen.main.bounds.width/3, height:  UIScreen.main.bounds.width/3.0)//collectionView.bounds.size.width*0.5+50+30)
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
        let cell = collectionView.cellForItem(at: indexPath) as?PhotoGalleryAlbumCollectionViewCell
        let objPhotoAlbum = self.arrayOfPhotoGallery[indexPath.item]
        
        if self.isEdit{
            if self.objSelectedImageMutableSet.contains(objPhotoAlbum.id){
                self.objSelectedImageMutableSet.remove(objPhotoAlbum.id)
                self.itemsSelected[indexPath] = false
                if self.objSelectedImageMutableSet.count == 0{
                   self.buttonDelete.isHidden = true
                   self.isEdit = false
                }
            }else{
                self.objSelectedImageMutableSet.add(objPhotoAlbum.id)
                self.itemsSelected[indexPath] = true
            }
            
        }else{
            if self.arrayOfPhotoGallery.count > indexPath.item{
                self.presentPhotoGllaryPreview(index: indexPath.item+1)
            }
        }
        
        DispatchQueue.main.async {
            self.collectionViewPhotoGallery.reloadData()
        }
    }
}
/*
 {
 "pk": "4",
 "event_galllery_id": "2",
 "attachment": "http://schoolerp.project-demo.info/assets/uploads/events/birth_day/2.JPG"
 }
 */
struct PhotoGallery {
    let id,galleryID,image:String
}
extension PHAsset {
    var imageData:Data{
        var thumbnail = Data()
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.resizeMode = .fast
        options.isSynchronous = true
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            if let objdata = data {
                thumbnail = objdata
            }
        }
        return thumbnail
    }
    var image : UIImage {
        
        var thumbnail = UIImage()
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: self, options: options) { data, _, _, _ in
            if let data = data {
                thumbnail = UIImage(data: data) ?? UIImage()
            }
        }
        return thumbnail
    }
    
}
extension UIImage{
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizedTo1MB() -> UIImage? {
        guard let imageData = self.pngData() else { return nil }
        let megaByte = 1000.0
        
        var resizingImage = self
        var imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        
        while imageSizeKB > megaByte { // ! Or use 1024 if you need KB but not kB
            guard let resizedImage = resizingImage.resized(withPercentage: 0.1),
                let imageData = resizedImage.pngData() else { return nil }
            
            resizingImage = resizedImage
            imageSizeKB = Double(imageData.count) / megaByte // ! Or devide for 1024 if you need KB but not kB
        }
        
        return resizingImage
    }
}
