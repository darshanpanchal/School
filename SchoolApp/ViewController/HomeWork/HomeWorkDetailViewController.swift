//
//  HomeWorkDetailViewController.swift
//  SchoolApp
//
//  Created by user on 18/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import QuickLook

class EditedUITextView: UITextView {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(cut(_:)) {
            return false
        }
        if action == #selector(paste(_:)) {
            return false
        }
        if action == #selector(select(_:)) {
            return false
        }
        if action == #selector(selectAll(_:)) {
            return false
        }
        
        return false
        //return super.canPerformAction(action, withSender: sender)
    }
    
}
class HomeWorkDetailViewController: UIViewController {
    
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var navigationView:UIView!
    
    @IBOutlet var lblHomeWorkDate:UILabel!
    @IBOutlet var homeWorkDateView:UIView!
    @IBOutlet var shadowView:ShadowView!
    @IBOutlet var txtHomeWorkDetail:EditedUITextView!
    @IBOutlet var containerView:UIView!
    
    @IBOutlet var buttonHomeWorkDetail:UIButton!
    
    var objHomeWork:Homework?
    
    var previewItem:NSURL?
    
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

        //setUp HomeWorkDetail
        self.setUpView()
        //configure homework detail
        self.configureHomeWorkDetail()
        
        self.txtHomeWorkDetail.isEditable = false
        self.txtHomeWorkDetail.isUserInteractionEnabled = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.HomeWorkDetail")
        self.lblTitle.font = CommonClass.shared.titleFont
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateString = dateFormatter.string(from:Date())
        self.lblHomeWorkDate.text = dateString
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.shadowView.layer.cornerRadius = 10.0
        self.homeWorkDateView.backgroundColor = kSchoolThemeColor
        self.txtHomeWorkDetail.isScrollEnabled = true
        
        if let _ = self.objHomeWork{
            self.buttonHomeWorkDetail.isHidden = !(self.objHomeWork!.attachmentType.count > 0)
            if self.objHomeWork!.attachmentType == "pdf"{
                let image = UIImage.init(named: "ic_pdf_icon")
                self.buttonHomeWorkDetail.setImage(image, for: .normal)
            }else if (self.objHomeWork!.attachmentType  == "doc" || self.objHomeWork!.attachmentType == "docx"){
                 let image = UIImage.init(named: "ic_doc")
                 self.buttonHomeWorkDetail.setImage(image, for: .normal)
            }else{
                let image = UIImage.init(named: "ic_image_icon")
                self.buttonHomeWorkDetail.setImage(image, for: .normal)
            }
        }
    }
    func configureHomeWorkDetail(){
        if let _ = self.objHomeWork{
            self.lblHomeWorkDate.text = self.objHomeWork!.homeworkDate.changeDateFormateddMMYYYY
            
            if let currentUser = User.getUserFromUserDefault(){
                if currentUser.userType == .student{
                    self.txtHomeWorkDetail.text = self.objHomeWork!.homeworkContent
                }else{
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    let classValue = NSMutableAttributedString.init(string: "\(self.objHomeWork!.className)", attributes: self.attributesNormal)
                    //let classValue = NSMutableAttributedString.init(string: "\(self.objHomeWork!.className) - \(self.objHomeWork!.sectionName)", attributes: self.attributesNormal)
                    classString.append(classValue)
                    let homeworkAttributedString = NSAttributedString.init(string:"\n\n\(self.objHomeWork!.homeworkContent)\n" , attributes: self.attributesNormal)
                    classString.append(homeworkAttributedString)
                    self.txtHomeWorkDetail.attributedText = classString//"\(self.arrayOfHomeWork[indexPath.row].homeworkContent)\n"
                }
            }
        }
    }
    func presentPDFInQuickLook(){
        var strURL = ""
        if let _ = self.objHomeWork{
            strURL = self.objHomeWork!.attachment
        }
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
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
            self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonHomeWorkDetailSelector(sender:UIButton){
        self.presentPDFInQuickLook()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
extension HomeWorkDetailViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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
