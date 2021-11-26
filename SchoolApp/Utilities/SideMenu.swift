

import UIKit

fileprivate let sideMenuColor = UIColor.white
fileprivate let titleColorNormal = UIColor.black//LIFVS.generalBlueColor
fileprivate let titleColorSelected = UIColor.black//LIFVS.generalBlueColor

enum position {
    case rightToLeft
    case leftToRight
}
extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
class SideMenu:UIView,UIGestureRecognizerDelegate{
    
    
    static let shared = SideMenu()
    static var openingPosition:position = .leftToRight
    static var viewToShowOnSideMenu = ViewToShowOnSideMenu()//.loadNib() as! ViewToShowOnSideMenu
    static var xPositionOfContainerView:NSLayoutConstraint?
    static let widthOfContainer = UIScreen.main.bounds.width*0.8  // visible part of side menu
    
    static var disablerView:UIView={ // disables user interaction below the size menu
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let tap = UITapGestureRecognizer(target: SideMenu.self, action:#selector(hide))
        tap.delegate = shared
        view.addGestureRecognizer(tap)
        
        let swip = UISwipeGestureRecognizer(target: SideMenu.self, action: #selector(hide))
        swip.delegate = shared
        swip.direction = openingPosition == .rightToLeft ? .right : .left
        view.addGestureRecognizer(swip)
        
        return view
    }()
    
    
    
    static var containerView:UIView={ // Container view which contains every object of the side menu such as collection view
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = sideMenuColor
        
        view.addSubview(viewToShowOnSideMenu)
        viewToShowOnSideMenu.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        viewToShowOnSideMenu.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        
        return view
    }()
    
    
    static func setSelectedItem(index:Int){
        ViewToShowOnSideMenu.selectedCell = index
    }
    
    static func show(){
        UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        self.viewToShowOnSideMenu.updateDataSource()
        self.viewToShowOnSideMenu.listingCollectionView.reloadData()
        if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{ // Application winow which can be acces from anywhere
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0) // Always will be clear to show animation
            
            keyWindow.addSubview(disablerView)
            
            
            disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0).isActive = true
            disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0).isActive = true
            disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 0).isActive = true
            disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: 0).isActive = true
            
            if !disablerView.subviews.contains(containerView){
                
                disablerView.addSubview(containerView)
                containerView.topAnchor.constraint(equalTo: disablerView.topAnchor, constant: 0).isActive = true
                containerView.bottomAnchor.constraint(equalTo: disablerView.bottomAnchor, constant: 0).isActive = true
                containerView.widthAnchor.constraint(equalToConstant: widthOfContainer).isActive = true
                
                if xPositionOfContainerView == nil{
                    if openingPosition == .rightToLeft{
                        xPositionOfContainerView = containerView.leftAnchor.constraint(equalTo: disablerView.rightAnchor, constant: 0)
                    }else{
                        xPositionOfContainerView = containerView.rightAnchor.constraint(equalTo: disablerView.leftAnchor, constant: 0)
                    }
                    disablerView.addConstraint(xPositionOfContainerView!)
                }
                
                
            }
            
            keyWindow.layoutIfNeeded()
            xPositionOfContainerView?.constant = openingPosition == .rightToLeft ? -widthOfContainer : widthOfContainer
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                disablerView.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
                keyWindow.layoutIfNeeded()
                
            }, completion: { (bool) in})
            
        }
    }
    
    @objc static func hide(){
        
        
        xPositionOfContainerView?.constant = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            disablerView.backgroundColor = UIColor.init(white: 0, alpha: 0)
            if let app = UIApplication.shared.delegate as? AppDelegate , let keyWindow = app.window{
                keyWindow.layoutIfNeeded()
            }
            
        }, completion: { (bool) in
            
            disablerView.removeFromSuperview() // removing to from keyWindow
            
        })
    }
    
    //MARK: Gesture delegates
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == SideMenu.disablerView ? true : false
    }
    
    
}


class ViewToShowOnSideMenu:UIView,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    var titleDataSouce = [SidemenuCellModel]() // must be eqaul to imageViewDataSource ,if has imagemode true
    let intialSpacing:CGFloat = UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 50.0
    static var selectedIndex:Int = 1
    
    static var selectedCell:Int{
        get{
            return selectedIndex
        }
        set{
            selectedIndex = newValue
            SideMenu.viewToShowOnSideMenu.listingCollectionView.reloadData()
        }
    }
    
    let cellId = "cellId"
    lazy var listingCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = true
        cv.backgroundColor = .clear
        cv.register(CellForSideMenu.self, forCellWithReuseIdentifier: self.cellId)
        let objGuideNib = UINib.init(nibName: "SideMenuHeaderCollectionView", bundle: nil)
        cv.register(objGuideNib, forCellWithReuseIdentifier:"SideMenuHeaderCollectionView")
        let objSlideNib = UINib.init(nibName: "SideMenuCollectionViewCell", bundle: nil)
        cv.register(objSlideNib, forCellWithReuseIdentifier:"SideMenuCollectionViewCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
   
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        self.titleDataSouce.removeAll()
        let darshboard = SidemenuCellModel()
        darshboard.title = Vocabulary.getWordFromKey(key:"genral.MyDashboard")
        darshboard.id = "profile"
        titleDataSouce.append(darshboard)
        
        let darshboard1 = SidemenuCellModel()
        darshboard1.title = Vocabulary.getWordFromKey(key:"genral.MyDashboard")
        darshboard1.id = "dashboard"
        titleDataSouce.append(darshboard1)
        
//        let sortiment = SidemenuCellModel()
//        sortiment.title = Vocabulary.convert(key: "general.sortiment").uppercased()
//        sortiment.id = "sortiment"
//        titleDataSouce.append(sortiment)
        
        let changePassword = SidemenuCellModel()
        changePassword.title = Vocabulary.getWordFromKey(key:"genral.ChangePassword")
        changePassword.id = "changepassword"
        titleDataSouce.append(changePassword)
        
        let addAcount = SidemenuCellModel()
        addAcount.title = Vocabulary.getWordFromKey(key:"genral.AddAccount")
        addAcount.id = "addacount"
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id == "2"{
                titleDataSouce.append(addAcount)
            }
        }
        
       
        let rateus = SidemenuCellModel()
        rateus.title = Vocabulary.getWordFromKey(key:"genral.RateUs")
        rateus.id = "rateus"
//        titleDataSouce.append(rateus)
        
        let logout = SidemenuCellModel()
        logout.title = Vocabulary.getWordFromKey(key:"genral.logout")
        logout.id = "logout"
        titleDataSouce.append(logout)
        
//        let logout = SidemenuCellModel()
//        logout.title = "title.log_out"//Vocabulary.convert(key: "title.log_out").uppercased()
//        logout.id = "logout"
//        titleDataSouce.append(logout)
 
        self.addSubview(listingCollectionView)
        listingCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: intialSpacing).isActive = true
        listingCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        listingCollectionView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        listingCollectionView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true

        
    }
    func updateDataSource(){
        self.titleDataSouce.removeAll()
        let darshboard = SidemenuCellModel()
        darshboard.title = Vocabulary.getWordFromKey(key:"genral.MyDashboard")
        darshboard.id = "profile"
        titleDataSouce.append(darshboard)
        
        let darshboard1 = SidemenuCellModel()
        darshboard1.title = Vocabulary.getWordFromKey(key:"genral.MyDashboard")
        darshboard1.id = "dashboard"
        titleDataSouce.append(darshboard1)
        
        //        let sortiment = SidemenuCellModel()
        //        sortiment.title = Vocabulary.convert(key: "general.sortiment").uppercased()
        //        sortiment.id = "sortiment"
        //        titleDataSouce.append(sortiment)
        
        let changePassword = SidemenuCellModel()
        changePassword.title = Vocabulary.getWordFromKey(key:"genral.ChangePassword")
        changePassword.id = "changepassword"
        titleDataSouce.append(changePassword)
        
        let addAcount = SidemenuCellModel()
        addAcount.title = Vocabulary.getWordFromKey(key:"genral.AddAccount")
        addAcount.id = "addacount"
        if let user = User.getUserFromUserDefault(){ //Id 2 for student and 1 for admin/super admin
            if user.userrole_id == "2"{
                titleDataSouce.append(addAcount)
            }
        }
        
        
        let rateus = SidemenuCellModel()
        rateus.title = Vocabulary.getWordFromKey(key:"genral.RateUs")
        rateus.id = "rateus"
        //        titleDataSouce.append(rateus)
        
        let logout = SidemenuCellModel()
        logout.title = Vocabulary.getWordFromKey(key:"genral.logout")
        logout.id = "logout"
        titleDataSouce.append(logout)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    
    
    
    //MARK: CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
        return titleDataSouce.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item == 0{
          return CGSize(width: self.frame.width, height: 130)
        }else{
          return CGSize(width: self.frame.width, height: 45)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
             let guideCell:SideMenuHeaderCollectionView = collectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuHeaderCollectionView", for: indexPath) as! SideMenuHeaderCollectionView
            guideCell.userProfileImage.layoutIfNeeded()
            guideCell.userProfileImage.layer.cornerRadius = guideCell.userProfileImage.frame.height/2.0
            guideCell.userProfileImage.clipsToBounds = true
            if let user = User.getUserFromUserDefault(){
                guideCell.userName.text = user.username
                guideCell.userclassDetail.text = (user.userrole_id == "1") ? "":"\(user.class_name) - \(user.divison_name)"
                if let objURl = URL.init(string: user.student_photo){
                    guideCell.userProfileImage.sd_setImage(with: objURl, placeholderImage:UIImage.init(named:"ic_user_profile"))
                    guideCell.userProfileBackGround.sd_setImage(with: objURl, placeholderImage:UIImage.init(named:"ic_user_profile"))
                }else{
                    guideCell.userProfileImage.image = UIImage.init(named:"ic_user_profile")
                    guideCell.userProfileBackGround.image = UIImage.init(named:"ic_user_profile")
                    
                }
            }
            return guideCell
        }else{
            let cell:SideMenuCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SideMenuCollectionViewCell", for: indexPath) as! SideMenuCollectionViewCell
            let obj = self.titleDataSouce[indexPath.item]
            if ViewToShowOnSideMenu.selectedCell == indexPath.item {
                cell.lblName.font = UIFont.boldSystemFont(ofSize: 16)
            }else{
                cell.lblName.font = UIFont.systemFont(ofSize: 16)
            }
            cell.lblName.text = obj.title
            switch obj.id {
                    case "logout":
                         cell.objImageView.image = UIImage.init(named: "logout")
                    case "dashboard":
                        cell.objImageView.image = UIImage.init(named: "home_dashboard")
                    case "changepassword":
                        cell.objImageView.image = UIImage.init(named: "change_password")
                    case "addacount":
                        cell.objImageView.image = UIImage.init(named: "add_account")
            default:
                break
                
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        SideMenu.hide()
       
//        if ViewToShowOnSideMenu.selectedCell == indexPath.item{
//            return
//        }
        let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
        let selectedModel = titleDataSouce[indexPath.item]
        if let id = selectedModel.id,let nvc = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
            switch id {
            case "logout":
                self.logout()
                return
            case "profile":
                if let dvc = mainStoryBoard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController{
//                    nvc.pushViewController(dvc, animated: false)
                }
            case "dashboard":
                if let dvc = mainStoryBoard.instantiateViewController(withIdentifier: "DashBoardViewController") as? DashBoardViewController{
                    nvc.pushViewController(dvc, animated: false)
                }
               
            case "changepassword":
                if let dvc = mainStoryBoard.instantiateViewController(withIdentifier: "ChangePasswordViewController") as? ChangePasswordViewController{
                    nvc.pushViewController(dvc, animated: false)
                }
//                let dvc = ItemListView()
//                nvc.pushViewController(dvc, animated: true)
            case "addacount":
                print("addacount")
                if let dvc = mainStoryBoard.instantiateViewController(withIdentifier: "AddAccountViewController") as? AddAccountViewController{
                    if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
                    {    dvc.modalPresentationStyle = .overFullScreen
                        rootVC.present(dvc, animated: false, completion: nil)
                    }
                }
//                let dvc = StoreLocator()
//                dvc.isManualSearch = true
//                dvc.isFromSideMenu = true
//                nvc.pushViewController(dvc, animated: true)
            case "rateus":
                var strURL = ""
                if kBaseURL == kLiveSurat{
                    strURL = "https://itunes.apple.com/us/app/shanti-asiatic-school-connect/id1460219343?ls=1&mt=8"
                }else if kBaseURL == kLiveSurat{
                    strURL = "https://itunes.apple.com/us/app/shanti-asiatic-school-kheda/id1462049324?ls=1&mt=8"
                }else{
                    strURL = "https://itunes.apple.com/us/app/shanti-asiatic-school-vastral/id1462049446?ls=1&mt=8"
                }
                guard let url = URL(string: "\(strURL)") else { return }
                UIApplication.shared.open(url)
//                let dvc = HistoryView()
//                nvc.pushViewController(dvc, animated: true)
            case "logout":
                print("logout")
//                let dvc = ChangeLanguageViewController()
//                nvc.pushViewController(dvc, animated: true)
            default:
                break
            }
            nvc.viewControllers = [nvc.viewControllers.last!]
        }
        
        ViewToShowOnSideMenu.selectedCell = indexPath.item
    }
    
    func logout(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootVC = keyWindow.rootViewController
        {
            let alert = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"genral.logout"), message: Vocabulary.getWordFromKey(key: "genral.logoutmessage"), preferredStyle: .alert)
            let yesAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.yes"), style: .default, handler: { action -> Void in
                

                if let user = User.getUserFromUserDefault(){
                    var logOutParameters:[String:Any] = [:]
                    logOutParameters["user_id"] = "\(user.userId)"
                    
                    APIRequestClient.shared.sendRequest(requestType: .POST, queryString:kUserLogout, parameter:logOutParameters as [String:AnyObject],isHudeShow: true,success: { (responseSuccess) in
                                 DispatchQueue.main.async {
                                    ProgressHud.hide()
                                    let application = UIApplication.shared
                                    application.applicationIconBadgeNumber = 0
                                     User.removeUserFromUserDefault()
                                      let mainStoryBoard = UIStoryboard.init(name: "Main", bundle: nil)
                                      if let rootView = mainStoryBoard.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController{
                                          if let rootNavigation = keyWindow.rootViewController as? UINavigationController{
                                              rootNavigation.popToRootViewController(animated: false)
                                              let nvc = UINavigationController(rootViewController: rootView)
                                              keyWindow.rootViewController = nvc
                                          }
                                          SideMenu.setSelectedItem(index: 0)
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
             
                
               
            })
            
            let noAction = UIAlertAction(title: Vocabulary.getWordFromKey(key: "genral.no"), style: .cancel, handler: nil)
            alert.addAction(noAction)
            alert.addAction(yesAction)
            rootVC.present(alert, animated: true, completion: nil)
        }
    }
    
    
}


class CellForSideMenu:UICollectionViewCell{
    var widthOfImage:NSLayoutConstraint!
    
    var cellAttributes:SidemenuCellModel?{
        didSet{
            
            if let title  = cellAttributes?.title{
                self.textLabel.text =  Vocabulary.getWordFromKey(key: "\(title)").uppercased()
            }else{
                self.textLabel.text = "Unknown"
            }
            
            if let image = cellAttributes?.image{
                self.imageView.image = image
                widthOfImage.constant = frame.height
            }else{
                self.imageView.image = nil
                widthOfImage.constant = 0
            }
        }
    }
    let textLabel:UILabel={
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = titleColorNormal
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let imageView:UIImageView={
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints  = false
        return iv
    }()
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(textLabel)
        self.addSubview(imageView)
        self.imageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1).isActive = true
        widthOfImage = self.imageView.widthAnchor.constraint(equalToConstant: frame.height)
        self.addConstraint(widthOfImage)
        self.imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 5).isActive = true
        textLabel.leftAnchor.constraint(equalTo: self.imageView.rightAnchor, constant: 5).isActive = true
        textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SidemenuCellModel:NSObject{
    var title:String?
    var id:String?
    var image:UIImage?
}




















