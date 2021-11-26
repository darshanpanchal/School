//
//  LogInTableViewCell.swift
//  Live
//
//  Created by ITPATH on 4/4/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit

class LogInTableViewCell: UITableViewCell {

    @IBOutlet var textFieldLogIn:TweeActiveTextField!
    @IBOutlet var btnDropDown:UIButton!
    @IBOutlet var btnSelect:UIButton!
    var cellFrame:CGRect?
    @IBOutlet var leadingContainer:NSLayoutConstraint!
    @IBOutlet var trailingContainer:NSLayoutConstraint!
    @IBOutlet var trailingButtonDropDown:NSLayoutConstraint!
    @IBOutlet var imageTick:UIImageView!
    var iconClick = true
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.selectionStyle = .none
        self.textFieldLogIn.setRightPaddingPoints(20.0)
        //self.textFieldLogIn.minimumFontSize = 25.0
        self.textFieldLogIn.adjustsFontSizeToFitWidth = false
        self.textFieldLogIn.setNeedsLayout()
        self.textFieldLogIn.layoutIfNeeded()
        DispatchQueue.main.async {
            //self.imageTick.image = #imageLiteral(resourceName: "tick_select").withRenderingMode(.alwaysTemplate)
            //self.imageTick.tintColor = UIColor.init(hexString: "#36527D")
        }
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(LogInTableViewCell.tapDetected))
        self.imageTick.addGestureRecognizer(singleTap)
    }
    @objc func tapDetected(){
        DispatchQueue.main.async {
            self.textFieldLogIn.becomeFirstResponder()
        }
    }
    func addDynamicFont(){
        self.textFieldLogIn.adjustsFontForContentSizeCategory = true
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.iconClick = true
            self.addDynamicFont()
        }
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    @IBAction func btnForPasswordField(_ sender: Any) {
        if(iconClick == true) {
            self.textFieldLogIn.isSecureTextEntry = false
            if btnDropDown.tag == 101 {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordEnable_black").withRenderingMode(.alwaysOriginal), for: .normal)
//                self.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordEnable"), for: .normal)
//                self.btnDropDown.imageView?.tintColor = UIColor.white
            }
            iconClick = false
        } else {
            self.textFieldLogIn.isSecureTextEntry = true
            if btnDropDown.tag == 101 {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable_black").withRenderingMode(.alwaysOriginal), for: .normal)
//                self.btnDropDown.imageView?.tintColor = UIColor.black.withAlphaComponent(0.5)
            } else {
                self.btnDropDown.setImage(#imageLiteral(resourceName: "passwordDisable"), for: .normal)
//                self.btnDropDown.imageView?.tintColor = UIColor.white
            }
            iconClick = true
        }
        DispatchQueue.main.async {
            self.textFieldLogIn.becomeFirstResponder()
            let currentText: String = self.textFieldLogIn.text!
            self.textFieldLogIn.text = "";
            self.textFieldLogIn.text = currentText
        }
    }
    func setTextFieldColor(textColor:UIColor,placeHolderColor:UIColor){
        self.textFieldLogIn.textColor = textColor
        self.textFieldLogIn.activeLineColor = placeHolderColor
        self.textFieldLogIn.lineColor = textColor
        self.textFieldLogIn.placeholderColor = placeHolderColor
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
class DashBoardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var objImageView:UIImageView!
    @IBOutlet var objName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.init(hexString: "757575").cgColor
        self.layer.borderWidth = 0.75
        self.clipsToBounds = true
        self.objImageView.contentMode = .scaleAspectFit
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class UserProfileTableViewCell: UITableViewCell {
    @IBOutlet var lblUserName:UILabel!
    @IBOutlet var selectImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class SideMenuHeaderCollectionView: UICollectionViewCell {
    
    @IBOutlet var userProfileImage:UIImageView!
    @IBOutlet var userProfileBackGround:UIImageView!
    @IBOutlet var userName:UILabel!
    @IBOutlet var userclassDetail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       self.userProfileBackGround.blurImage()
        //self.view.addSubview(self.blurredBackground)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class SideMenuCollectionViewCell: UICollectionViewCell {
    @IBOutlet var objImageView:UIImageView!
    @IBOutlet var lblName:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class UserProfileDetailTableViewCell: UITableViewCell {
    @IBOutlet var lblUserProfile:UILabel!
    @IBOutlet var lblUserProfileDetail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class PTMTableViewCell:UITableViewCell {
    
    @IBOutlet var objStatusIndication:UIView!
    @IBOutlet var lblPTMDate:UILabel!
    @IBOutlet var lblAttender:UILabel!
    @IBOutlet var lblPTMDetail:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
class CalendarYealyTableViewCell: UITableViewCell {
    @IBOutlet var lblDay:UILabel!
    @IBOutlet var lblEventDetail:UILabel!
    @IBOutlet var containerView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.lblEventDetail.backgroundColor = UIColor.clear
        
    }
}

extension UIImageView{
    func blurImage()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
}
class HomeworkTableViewCell: UITableViewCell {
    
    @IBOutlet var lblHomeWorkDate:UILabel!
    @IBOutlet var lblHomeWorkDetail:UILabel!
    @IBOutlet var shadowView:ShadowView!
    @IBOutlet var containerView:UIView!
    @IBOutlet var attachMentImageView:UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.shadowView.layer.cornerRadius = 10.0
        self.lblHomeWorkDate.textColor = kSchoolThemeColor
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
class BusStopDetailTableViewCell: UITableViewCell{
    
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblPickUp:UILabel!
    @IBOutlet var lblDrop:UILabel!
    @IBOutlet var containerView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
class DriverDetailTableViewCell:UITableViewCell{
    @IBOutlet var lblTitle:UILabel!
    @IBOutlet var lblPickUpName:UILabel!
    @IBOutlet var lblDropName:UILabel!
    @IBOutlet var lblPickUpMobile:UILabel!
    @IBOutlet var lblDropMobile:UILabel!
    @IBOutlet var lblName:UILabel!
    @IBOutlet var lblMobile:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}
class DashBoardTableViewCell:UITableViewCell{

    @IBOutlet var objImageView:UIImageView!
    @IBOutlet var objName:UILabel!
    @IBOutlet var shadowView:ShadowView!
    @IBOutlet var containerView:UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
//        self.layer.borderColor = UIColor.init(hexString: "757575").cgColor
//        self.layer.borderWidth = 0.75
        self.clipsToBounds = true
        self.objImageView.contentMode = .scaleAspectFit
        self.containerView.clipsToBounds = true
        self.containerView.layer.cornerRadius = 10.0
        self.shadowView.layer.cornerRadius = 10.0
    }
}
class PhotoGalleryAlbumCollectionViewCell: UICollectionViewCell,UIScrollViewDelegate ,UIGestureRecognizerDelegate{
    
    @IBOutlet var objImageView:UIImageView!
    @IBOutlet var objName:UILabel!
    @IBOutlet var objNameContainer:UIView!
    @IBOutlet var objImageScrollView:UIScrollView!
    @IBOutlet var objSelectedImage:UIImageView!
    var isImagePreview:Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 0.75
        self.clipsToBounds = true
        self.objSelectedImage.layer.cornerRadius = 14.0
        self.objSelectedImage.layer.borderColor = UIColor.white.cgColor
        self.objSelectedImage.layer.borderWidth = 1
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func configureImagePreview(){
        self.objImageScrollView.minimumZoomScale = 1.0
        self.objImageScrollView.maximumZoomScale =  3.0
        self.objImageScrollView.delegate = self
        self.layer.borderColor = UIColor.clear.cgColor
        self.objImageView.contentMode = .scaleAspectFit
        self.objImageView.isUserInteractionEnabled = true
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return self.objImageView
    }
}
class PreviewImageCollectionCell:UICollectionViewCell,UIScrollViewDelegate,UIGestureRecognizerDelegate{
    @IBOutlet var imgPreview:UIImageView!
    @IBOutlet weak var scrollview: UIScrollView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.scrollview.minimumZoomScale = 1.0
        self.scrollview.maximumZoomScale = 3.0
        self.scrollview.delegate = self
        self.imgPreview.contentMode = .scaleAspectFit
        self.imgPreview.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 2
        imgPreview.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    //MARK: tap gesture on preview image
    
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        // do something when image tapped
        print("image tapped")
        let scale = min(scrollview.zoomScale * 2, scrollview.maximumZoomScale)
        
        if scale != scrollview.zoomScale {
            let point = gestureRecognizer.location(in: imgPreview)
            
            let scrollSize = scrollview.frame.size
            let size = CGSize(width: scrollSize.width / scale,
                              height: scrollSize.height / scale)
            let origin = CGPoint(x: point.x - size.width / 2,
                                 y: point.y - size.height / 2)
            scrollview.zoom(to:CGRect(origin: origin, size: size), animated: true)
        }else{
            
            self.scrollview!.setZoomScale(self.scrollview!.minimumZoomScale, animated: true)
        }
    }
    
    //MARK: pinch zoom on preview image
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgPreview
    }
}
protocol MyLeaveDelegate {
    func buttonCancelLeave(index:Int)
    func buttonAcceptLeave(index:Int)
}
class MyLeaveTableViewCell: UITableViewCell {
    
    @IBOutlet var lblfromDate:UILabel!
    @IBOutlet var lbltodate:UILabel!
    @IBOutlet var documentImage:UIImageView!
    @IBOutlet var lblleavePostedBy:UILabel!
    @IBOutlet var lbldescription:UILabel!
    @IBOutlet var lblLeaveDays:UILabel!
    @IBOutlet var buttonDocument:UIButton!
    @IBOutlet var lblLeaveType:UILabel!
    @IBOutlet var lblLeaveStatus:UILabel!
    
    @IBOutlet var buttonApproveLeave:UIButton!
    @IBOutlet var buttonCancelLeave:UIButton!
    
    @IBOutlet var lblClassName :UILabel!
    @IBOutlet var lblClassValue:UILabel!
    
    @IBOutlet var lblStudentName:UILabel!
    @IBOutlet var lblStudentValue:UILabel!
    
    
    var delegate:MyLeaveDelegate?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsets.zero//UIEdgeInset.zero
        self.layoutMargins = UIEdgeInsets.zero//UIEdgeInset.zero
    }
    
    @IBAction func buttonApproveLeaveSelector(button:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonAcceptLeave(index: self.tag)
        }
    }
    @IBAction func buttonCancelLeaveSelector(button:UIButton){
        if let _ = self.delegate{
            self.delegate!.buttonCancelLeave(index: self.tag)
        }
    }
}
extension TweeActiveTextField {
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
class BorderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didLoad()
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    func didLoad() {
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
    }
}
