//
//  PhotoGalleryPreviewViewController.swift
//  SchoolApp
//
//  Created by user on 25/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
protocol PhotoGalleryPreviewDelete {
    func deletePhotoGallery(updateArray:[PhotoGallery])
}

class PhotoGalleryPreviewViewController: UIViewController {

    //navigation
    @IBOutlet var buttonBack:UIButton!
    
    @IBOutlet var collectionViewPhotoGallery:UICollectionView!
    
    var arrayOfPhotoGallery:[PhotoGallery] = []
    @IBOutlet var lblTitle:UILabel!
    var index:Int = 0
    var currentIndex:Int{
        get{
            return index
        }
        set{
            index = newValue
            DispatchQueue.main.async {
                if self.arrayOfPhotoGallery.count > 0{
                    self.lblTitle.text = "\(newValue)/\(self.arrayOfPhotoGallery.count)"
                }
            }
        }
    }
    var deleteDelegate:PhotoGalleryPreviewDelete?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup view
        self.setUpView()
        
        self.configurePhotogalleryCollectionView()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            self.collectionViewPhotoGallery.scrollToItem(at:IndexPath.init(item: self.currentIndex-1, section: 0), at:UICollectionView.ScrollPosition.centeredHorizontally, animated: false)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = UIColor.white

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor

    }
    // MARK: - Custom Method
    func setUpView(){
        self.buttonBack.imageView?.contentMode = .scaleAspectFit
        if self.arrayOfPhotoGallery.count > 0{
            self.lblTitle.text = "\(currentIndex)/\(self.arrayOfPhotoGallery.count)"
        }
    }
    func configurePhotogalleryCollectionView(){
//        let objGuideNib = UINib.init(nibName: "PhotoGalleryAlbumCollectionViewCell", bundle: nil)
        
//        self.collectionViewPhotoGallery.register(objGuideNib, forCellWithReuseIdentifier:"PhotoGalleryAlbumCollectionViewCell")
        self.collectionViewPhotoGallery.delegate = self
        self.collectionViewPhotoGallery.dataSource = self
        self.collectionViewPhotoGallery.isScrollEnabled = true
        self.collectionViewPhotoGallery.allowsSelection = false
    }
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func buttonDeleteSelector(sender:UIButton){
        self.presentDeleteAlertController()
    }
    func presentDeleteAlertController(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController{
            let alert = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"Delete"), message: Vocabulary.getWordFromKey(key: "Are you sure you want to delete?"), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.yes"), style: .default, handler: { action -> Void in
                
                self.deleteImageAPIRequest()
                
            })
            let noAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.no"), style: .cancel, handler: nil)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            alert.view.tintColor = kSchoolThemeColor
            self.present(alert, animated: true, completion: nil)
        }
    
    }
    // MARK: - API request
    func deleteImageAPIRequest(){
        
        var iamgeDeleteaParameters:[String:Any] = ["image_id":"\(self.arrayOfPhotoGallery[self.currentIndex-1].id)"]
        
        APIRequestClient.shared.sendLogInRequest(requestType: .POST, queryString:kDeleteSingleImage, parameter:iamgeDeleteaParameters as [String : AnyObject],isHudeShow: true,success: { (responseSuccess) in
            if let success = responseSuccess as? [String:Any],let successMessage = success["message"] as? String{
                DispatchQueue.main.async {
                    if let _ = self.deleteDelegate{
                        self.arrayOfPhotoGallery.remove(at: self.currentIndex-1)
                        self.deleteDelegate!.deletePhotoGallery(updateArray: self.arrayOfPhotoGallery)
                    }
                    ShowToast.show(toatMessage: successMessage)
                    self.buttonBackSelector(sender: self.buttonBack)
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
extension PhotoGalleryPreviewViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.arrayOfPhotoGallery.count == 0{
            collectionView.showMessageLabel()
        }else{
            collectionView.removeMessageLabel()
        }
        return self.arrayOfPhotoGallery.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let dashBoardCell:PreviewImageCollectionCell =  collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewImageCollectionCell", for: indexPath) as! PreviewImageCollectionCell
        let objAlbum = self.arrayOfPhotoGallery[indexPath.item]
        if let objURL = URL.init(string: objAlbum.image){
            dashBoardCell.imgPreview.sd_setImage(with: objURL, placeholderImage:UIImage.init(named:"ic_image_icon"))
        }else{
            dashBoardCell.imgPreview.image = UIImage.init(named: "ic_image_icon")
        }
        return dashBoardCell
        
    }
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        self.currentIndex = currentPage+1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return collectionView.bounds.size// CGSize.init(width: UIScreen.main.bounds.width, height:  UIScreen.main.bounds.height)//collectionView.bounds.size.width*0.5+50+30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsets.zero//UIEdgeInsets.init(top: 20, left: 20, bottom: 0, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 0//15.0
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
