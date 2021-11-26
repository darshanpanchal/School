//
//  NoticeDetailViewController.swift
//  SchoolApp
//
//  Created by user on 19/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import QuickLook

class NoticeDetailViewController: UIViewController {
    //navigation
    @IBOutlet var buttonBack:UIButton!
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var navigationView:UIView!
    @IBOutlet var buttonNavigationDetail:UIButton!
    
    @IBOutlet var txtNoticeDetail:EditedUITextView!
    @IBOutlet var lblDate:UILabel!
    
    @IBOutlet var containerView:UIView!
    @IBOutlet var shadowView:ShadowView!
    
    
    var objNoticeDetail:Notice = Notice(noticeDetail: [:])
    var attributesBold: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var attributesNormal: [NSAttributedString.Key: Any] = [
        .font:  UIFont.systemFont(ofSize: 17),
        .foregroundColor: UIColor.black,
        ]
    var objHolidayHomework:HolidayHomework?
    var isForHomework:Bool = false
    
    var isForSyllabus:Bool = false
    var objSyllabus:Syllabus?

    var isExamTimeTable:Bool = false
    var objExamTimeTable:ExamTimeTable?
    
    var isStudentRemark:Bool = false
    var objStudentRemark:StudentRemark?
    
    var isForAcheivemnt:Bool = false
    var objAchievement:Achievement?
    
    var previewItem:NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.txtNoticeDetail.isEditable = false
        self.txtNoticeDetail.isUserInteractionEnabled = true
        self.txtNoticeDetail.isScrollEnabled = true
        //Configure current notice
        self.configureCurrentNoticeDetail()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarView?.backgroundColor = kSchoolThemeColor
    }
    // MARK: - Custom Methods
    func setUpView(){
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.NoticeDetail")
        self.lblTitle.font = CommonClass.shared.titleFont
        self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_pdf_icon"), for: .normal)
        
        self.lblDate.textColor = UIColor.white
        self.lblDate.backgroundColor = kSchoolThemeColor
        self.lblDate.clipsToBounds = true
//        self.lblDate.layer.cornerRadius = 10.0
        
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.shadowView.layer.cornerRadius = 10.0
    }
    func configureCurrentNoticeDetail(){
        if self.isForHomework{ //holiday homework detail
            self.lblTitle.text = Vocabulary.getWordFromKey(key:"Holiday Homework Detail")

            if let homework = self.objHolidayHomework{
                
                 self.buttonNavigationDetail.isHidden = !(homework.attachment.count > 0)
                if homework.attachment.fileExtension() == "pdf"{
                    self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_pdf_icon"), for: .normal)
                }else{
                    self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_image_icon"), for: .normal)
                }
                self.txtNoticeDetail.text = homework.description
                self.lblDate.text = homework.holidayName
            }
        }else if isForSyllabus{//syllabus detail
             self.lblTitle.text = Vocabulary.getWordFromKey(key:"Syllabus Detail")
            if let syllabus = self.objSyllabus{
                self.lblTitle.text = "\(self.objSyllabus!.syllabusType)"
                if syllabus.syllabusType.count == 0{
                    self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.AssignmentDetail")
                }
                self.buttonNavigationDetail.isHidden = !(syllabus.attachment.count > 0)
                if syllabus.attachment.fileExtension() == "pdf"{
                    self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_pdf_icon"), for: .normal)
                }else{
                    self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_image_icon"), for: .normal)
                }
                if syllabus.syllabusType.count == 0{
                    let subject = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                    let subjectValue = NSMutableAttributedString.init(string: "\(syllabus.subject)", attributes: self.attributesNormal)
                    
                    let desc = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                    let descValue = NSMutableAttributedString.init(string: "\(syllabus.objDescription)\n", attributes: self.attributesNormal)
                    
                    subject.append(subjectValue)
                    subject.append(desc)
                    subject.append(descValue)
                    
                    self.txtNoticeDetail.attributedText = subject//"Subject :- \(syllabus.subject) \nDesc :- \(syllabus.objDescription)"
                }else{
                    let subject1 = NSMutableAttributedString.init(string: "\nSubject :-  ", attributes: self.attributesBold)
                    let subject1Value = NSMutableAttributedString.init(string: "\(syllabus.subject)", attributes: self.attributesNormal)
                    
                    let type1 = NSMutableAttributedString.init(string: "\n\nType :- ", attributes: self.attributesBold)
                    let typeValue1 = NSMutableAttributedString.init(string: "\(syllabus.syllabusType)", attributes: self.attributesNormal)
                    
                    let desc1 = NSMutableAttributedString.init(string: "\n\nDesc :- ", attributes: self.attributesBold)
                    let descValue1 = NSMutableAttributedString.init(string: "\(syllabus.objDescription)\n", attributes: self.attributesNormal)
                    
                    subject1.append(subject1Value)
                    subject1.append(type1)
                    subject1.append(typeValue1)
                    subject1.append(desc1)
                    subject1.append(descValue1)
                    self.txtNoticeDetail.attributedText = subject1//"Subject :- \(syllabus.subject) \nType :- \(syllabus.syllabusType) \n\(syllabus.objDescription)"
                }
                
                self.lblDate.text = syllabus.modifie.changeDateFormat
            }
        }else if self.isExamTimeTable,let objTimeTable = self.objExamTimeTable{
            self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.ExamTimeTableDetail")
            self.buttonNavigationDetail.isHidden = !(objTimeTable.attachment.count > 0)
            if objTimeTable.attachment.fileExtension() == "pdf"{
                self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_pdf_icon"), for: .normal)
            }else{
                self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_image_icon"), for: .normal)
            }
            self.txtNoticeDetail.text = objTimeTable.description
            self.lblDate.text = objTimeTable.examName
            
        }else if self.isStudentRemark,let objRemark = self.objStudentRemark{//student remark
            self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.RemarkDetail")
            self.buttonNavigationDetail.isHidden = true
            
            let type = NSMutableAttributedString.init(string: "Type : ", attributes: self.attributesBold)
            let typeValue = NSMutableAttributedString.init(string: "\(objRemark.remarkType)", attributes: self.attributesNormal)
            let category = NSMutableAttributedString.init(string: "\n\nCategory : ", attributes: self.attributesBold)
            let categoryValue = NSMutableAttributedString.init(string: "\(objRemark.category) ", attributes: self.attributesNormal)
            
            let otherString = NSMutableAttributedString.init(string: "\n\n\(objRemark.remarkName)\n\n\(objRemark.remarkSMSText)\n", attributes: self.attributesNormal)
            type.append(typeValue)
            type.append(category)
            type.append(categoryValue)
            type.append(otherString)
            
      
            
            if let currentUser = User.getUserFromUserDefault(){
                if currentUser.userType == .student{
                  self.txtNoticeDetail.attributedText = type
                }else{
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    let classValue = NSMutableAttributedString.init(string: "\(objRemark.className)\n", attributes: self.attributesNormal)
                    //let classValue = NSMutableAttributedString.init(string: "\(objRemark.className) - \(objRemark.sectionName)\n", attributes: self.attributesNormal)
                    classString.append(classValue)
                    let studentString = NSMutableAttributedString.init(string: "\nStudent : ", attributes: self.attributesBold)
                    let studentValue = NSAttributedString.init(string:"\n\n\(objRemark.studentName)\n\n", attributes: self.attributesNormal)
                    classString.append(studentString)
                    classString.append(studentValue)
                    classString.append(type)
                    
                  self.txtNoticeDetail.attributedText = classString
                }
            }
            //"Type : \(objStudentRemark.remarkType) \nCategory : \(objStudentRemark.category) \n\n\(objStudentRemark.remarkName)\n\(objStudentRemark.remarkSMSText)"
            self.lblDate.text = objRemark.remarkDate.changeDateFormateddMMYYYY
            
        }else if self.isForAcheivemnt,let objAchievment = self.objAchievement{//achievemnt remark
            self.lblTitle.text = Vocabulary.getWordFromKey(key:"genral.achievmentDetail")
            self.buttonNavigationDetail.isHidden = true
            
            let achirvement = NSMutableAttributedString.init(string: "\n\(Vocabulary.getWordFromKey(key: "genral.achievment")) :  ", attributes: self.attributesBold)
            let achirvementValue = NSMutableAttributedString.init(string: " \(objAchievment.activityName)", attributes: self.attributesNormal)
            
            let desc = NSMutableAttributedString.init(string: "\n\nPositions : ", attributes: self.attributesBold)
            let descValue = NSMutableAttributedString.init(string: "\(objAchievment.positionName)\n", attributes: self.attributesNormal)
            
            achirvement.append(achirvementValue)
            achirvement.append(desc)
            achirvement.append(descValue)
            
             self.txtNoticeDetail.attributedText  = achirvement
            /*
             self.txtNoticeDetail.text = "\(Vocabulary.getWordFromKey(key: "genral.achievment")) : \(self.objAchievement!.activityName)\n\(Vocabulary.getWordFromKey(key:"Positions")) : \(self.objAchievement!.positionName)"*/
             self.lblDate.text = self.objAchievement!.achievementDate.changeDateFormat
        }else{//notice detail
            self.buttonNavigationDetail.isHidden = !(objNoticeDetail.attachmentType.count > 0)
            if objNoticeDetail.attachmentType == "pdf"{
                self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_pdf_icon"), for: .normal)
            }else{
                self.buttonNavigationDetail.setBackgroundImage(UIImage.init(named: "ic_image_icon"), for: .normal)
            }
            if let objCurrentUser = User.getUserFromUserDefault(){
                if objCurrentUser.userType == .student{
                    self.txtNoticeDetail.text = "\(objNoticeDetail.noticeContent)\n"
                }else{ //add class name and section name and student name for admin role
                    let classString = NSMutableAttributedString.init(string: "\nClass : ", attributes: self.attributesBold)
                    let classValue = NSMutableAttributedString.init(string: "\(objNoticeDetail.className)\n", attributes: self.attributesNormal)
                    //let classValue = NSMutableAttributedString.init(string: "\(objNoticeDetail.className) - \(objNoticeDetail.sectionName)\n", attributes: self.attributesNormal)
                    classString.append(classValue)
                    let notificationContent = NSAttributedString.init(string:"\n\(objNoticeDetail.noticeContent)\n", attributes: self.attributesNormal)
                    classString.append(notificationContent)
                    self.txtNoticeDetail.attributedText = classString
                }
            }
            self.lblDate.text = objNoticeDetail.noticeDate.changeDateFormateddMMYYYY
        }
        }
       
    // MARK: - Selector Methods
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonNavigationRightSelector(sender:UIButton){
        
        self.presentPDFInQuickLook()
    }
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    func presentPDFInQuickLook(){
        var strURL = ""
        if self.isForHomework,let _ = self.objHolidayHomework{
             strURL = self.objHolidayHomework!.attachment
        }else if self.isForSyllabus,let _ = self.objSyllabus{
             strURL = self.objSyllabus!.attachment
        }else if self.isExamTimeTable,let _ = self.objExamTimeTable{
            strURL = self.objExamTimeTable!.attachment
        }else if self.isStudentRemark,let _ = self.objStudentRemark{
            return
        }else{
            strURL = objNoticeDetail.attachment
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

}
extension NoticeDetailViewController:QLPreviewControllerDataSource,QLPreviewControllerDelegate{
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
