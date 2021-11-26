//
//  CommonClass.swift
//  CommonAppSetUp
//
//  Created by ITPATH on 2/23/18.
//  Copyright © 2018 ITPATH. All rights reserved.
//

import UIKit
import SystemConfiguration

var IsiPhone5:Bool{
    get{
        return UIScreen.main.bounds.height == 568.0
    }
}

class CommonClass: NSObject {

    //SingleTon
    static let shared:CommonClass = {
       let common = CommonClass()
       return common
    }()
    var isConnectedToInternet:Bool{
        get{
            var zeroAddress = sockaddr_in()
            zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    SCNetworkReachabilityCreateWithAddress(nil, $0)
                }
            }) else {
                return false
            }
            
            var flags: SCNetworkReachabilityFlags = []
            if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
                return false
            }
            
            let isReachable = flags.contains(.reachable)
            let needsConnection = flags.contains(.connectionRequired)
            return (isReachable && !needsConnection)
        }
    }
    static let isSimulator: Bool = {
        return TARGET_OS_SIMULATOR == 1
    }()
    var noInternetAlertController:UIAlertController{
        get{
            let alertController = UIAlertController.init(title:"No Internet", message: "Please check your connection and try again.", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            return alertController
        }
    }
    var userBlockAlert:UIAlertController{
        get{
            let alertController = UIAlertController.init(title:Vocabulary.getWordFromKey(key:"block.hint"), message:
                Vocabulary.getWordFromKey(key:"blockMSG.hint"), preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            return alertController
        }
    }
    var titleFont:UIFont{
        get{
            return  UIFont.init(name: "Avenir-Heavy", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
        }
    }
    func getScaledFont(forFont name: String, textStyle: UIFont.TextStyle) -> UIFont {
        
        /// Uncomment the code below to check all the available fonts and have them printed in the console to double check the font name with existing fonts 😉
        
        /*
         for family: String in UIFont.familyNames
         {
         print("\(family)")
         for names: String in UIFont.fontNames(forFamilyName: family)
         {
         print("== \(names)")
         }
         } */
        
        let userFont =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        
        let pointSize = userFont.pointSize
        guard let customFont = UIFont(name: name, size: pointSize > 25 ? 25 : userFont.pointSize < 14 ? 14:userFont.pointSize) else {
            fatalError("""
                Failed to load the "\(name)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return UIFontMetrics.default.scaledFont(for: customFont, maximumPointSize: 25)
        //UIFontMetrics.default.scaledFont(for: customFont)
    }
    func getScaledWithOutMinimum(forFont name: String,textStyle: UIFont.TextStyle)->UIFont{
        let userFont =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
        
        let pointSize = userFont.pointSize
        guard let customFont = UIFont(name: name, size: pointSize > 25 ? 25 : userFont.pointSize) else {
            fatalError("""
                Failed to load the "\(name)" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
                """
            )
        }
        return UIFontMetrics.default.scaledFont(for: customFont, maximumPointSize: 25)
    }
    func getScaledFontSize()->CGFloat{
        let userFont =  UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)
        let customeFont = UIFontMetrics.default.scaledFont(for: UIFont(), maximumPointSize: 25)
        let pointSize = customeFont.pointSize
        return pointSize > 25 ? 25 : userFont.pointSize
    }
    func showAlertControllerWith(message:String, title:String){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window,let rootViewController = keyWindow.rootViewController{
            let alertController = UIAlertController.init(title:"\(title)", message: "\(message)", preferredStyle: .alert)
            let alertAction = UIAlertAction.init(title: Vocabulary.getWordFromKey(key:"ok.title"), style: .cancel, handler: nil)
            alertController.addAction(alertAction)
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    /*
    func addFirebaseAnalytics(parameters:[String:Any]){
        //item_name content_type item_id
        Analytics.logEvent(AnalyticsEventSelectContent, parameters:parameters)
      
    }
    func addFaceBookAnalytics(eventName:String,parameters:AppEvent.ParametersDictionary){
        let event = AppEvent(name: "\(eventName)", parameters: parameters, valueToSum: nil)
        AppEventsLogger.log(event)
    }*/
    func showInternetAlert(){
       // self.rootViewController?.present(noInternetAlertController, animated: true, completion: nil)
    }
    //Post URLRequest
    func postRequest(requestURL:String,dictParameters:[String:String],success:@escaping SUCCESS,fail:@escaping FAIL){
       
        
        if  let requestBody = try? JSONSerialization.data(withJSONObject: dictParameters, options:.prettyPrinted){
            
            let objURL = URL(string:"\(kBaseURL)\(requestURL)")!
            var objURLRequest = URLRequest(url:objURL)
            objURLRequest.setTypePOST()
            objURLRequest.httpBody = requestBody
            objURLRequest.setJSONHeader()
            let task = URLSession.shared.dataTask(with: objURLRequest) { (data, response, error) in
                if error != nil{
                    fail(["error":"\(error!.localizedDescription)"])
                }
                if let json = data!.getJSONDictionary(){
                    success(json)
                }else{
                    fail(["status":"0","statusMesssage":""])
                }
            }
            task.resume()
        }
    }
    
    //Get URLRequest
    func getRequest(requestURL:String,success:SUCCESS,fail:FAIL){
    }
}
protocol TableViewProtocol{
    func registerCellNIB(cellID:String)
}
extension TableViewProtocol where Self:UITableView{
    func registerCellNIB(cellID:String){
        let nib = UINib(nibName: "\(cellID)", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "\(cellID)")
    }
}
protocol NavigationProtocol {
    func addNavigationBackButton()
}
extension NavigationProtocol where Self : UIViewController{
    func addNavigationBackButton(){
        
        
    }
}
class DDURLSession: URLSession {
    
}
@IBDesignable
class NoInternetConnection:UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
@IBDesignable
class ProgressHud: UIView {
    fileprivate static let rootView = {
        return UIApplication.shared.keyWindow!
    }()
    
    fileprivate static let blurView:UIView = {
        let view = UIView(frame: UIScreen.main.bounds)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        view.alpha = 0.2
        return view
    }()
    fileprivate static let hudView:UIView = {
         let view = UIView()
         view.translatesAutoresizingMaskIntoConstraints = false
         view.backgroundColor = UIColor.clear
         view.layer.cornerRadius = 6.0
         view.clipsToBounds = true
         view.layoutIfNeeded()
         return view
    }()
    fileprivate static let gifImageView:UIImageView = {
        let imageData = try? Data(contentsOf: Bundle.main.url(forResource: "SASERP", withExtension: "gif")!)
        if let advTimeGif = UIImage.sd_animatedGIF(with: imageData!){
            let objImage = UIImageView()
            objImage.image = advTimeGif
            objImage.contentMode = .scaleAspectFit
            objImage.translatesAutoresizingMaskIntoConstraints = false
            return objImage
        }
        return UIImageView()
        
    }()
    fileprivate static let activity:UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startAnimating()
        view.style = .whiteLarge
        view.hidesWhenStopped = false
        view.color = UIColor.black
        
       return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    static func show(){
        rootView.addSubview(blurView)
        self.addObserver()
        self.addActivity()
    }
    static func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name:UIDevice.orientationDidChangeNotification, object: nil)
    }
    @objc static func rotated(){
        print(UIScreen.main.bounds)
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight:
            print("landscape")
        default:
            print("Portrait")
        }
        blurView.frame = UIScreen.main.bounds
        //blurView.frame = CGRect.init(origin: .zero, size: CGSize.init(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width))
        
    }
    static func addActivity(){
        rootView.addSubview(hudView)
        hudView.widthAnchor.constraint(equalToConstant: 125).isActive = true
        hudView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        hudView.centerXAnchor.constraint(equalTo: hudView.superview!.centerXAnchor).isActive = true
        hudView.centerYAnchor.constraint(equalTo: hudView.superview!.centerYAnchor).isActive = true
        
//        hudView.addSubview(activity)
//        activity.centerXAnchor.constraint(equalTo: activity.superview!.centerXAnchor).isActive = true
//        activity.centerYAnchor.constraint(equalTo: activity.superview!.centerYAnchor).isActive = true
        rootView.isUserInteractionEnabled = false
        
        hudView.addSubview(gifImageView)
        gifImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        gifImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        gifImageView.centerXAnchor.constraint(equalTo: gifImageView.superview!.centerXAnchor).isActive = true
        gifImageView.centerYAnchor.constraint(equalTo: gifImageView.superview!.centerYAnchor).isActive = true
        
        
    }
    static func hide(){
        
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
            rootView.isUserInteractionEnabled = true
            blurView.removeFromSuperview()
            hudView.removeFromSuperview()
        }
    
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension URLRequest{
    mutating func setTypePOST(){
        self.httpMethod = "POST"
    }
    mutating func setTypeGET(){
        self.httpMethod = "GET"
    }
    mutating func setJSONHeader(){
        self.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
}
extension Data{
    func getJSONDictionary()->NSDictionary?{
        do {
            let json = try JSONSerialization.jsonObject(with: self) as? NSDictionary
            return json
        } catch let error as NSError {
            print("\(error.localizedDescription)")
            return nil
        }
    }
}
extension StringProtocol {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }
    var firstCapitalized: String {
        guard let first = first else { return "" }
        return String(first).capitalized + dropFirst()
    }
}
extension String{
    func converTo12hoursFormate()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "hh:mm a"
             let date12:String = dateFormatter.string(from: date)
             return "\(date12)"
        }else{
            return self
        }
    }
    func converTo24hoursFormate()->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        if let date = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "HH:mm"
            let date24:String = dateFormatter.string(from: date)
            return "\(date24)"
        }else{
            return self
        }
    }
    func capitalizingFirstLetter() -> String {
        let first = String(prefix(1)).capitalized
        let other = String(dropFirst())
        return first.uppercased() + other.lowercased()
    }
    func removeWhiteSpaces()->String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    var removingWhitespacesAndNewlines: String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    func convertString(string: String) -> String {
        let data = string.data(using: String.Encoding.ascii, allowLossyConversion: true)
        return NSString(data: data!, encoding: String.Encoding.ascii.rawValue)! as String
    }
    func compareCaseInsensitive(str:String)->Bool{
        return self.caseInsensitiveCompare(str) == .orderedSame
    }
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    func isContainWhiteSpace()->Bool{
        guard self.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines) == nil else{
            return true
        }
        return false
    }
    func isOnlyWhiteSpace()->Bool{
        let whiteSpaceSet = NSCharacterSet.whitespacesAndNewlines
        guard self.trimmingCharacters(in: whiteSpaceSet).count != 0 else{
            return true
        }
        return false
    }
   static func getSelectedLanguage()->String{
        if let selection = UserDefaults.standard.value(forKey: "selectedLanguageCode") as? String{ // 1 eng , 2 swed
            return selection.removeWhiteSpaces().lowercased()
        }
        return "1"
    }
}
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue) //UIImage.JPEGRepresentation(self, quality.rawValue)
    }
}
class SafeAreaConstraint:NSLayoutConstraint{
    var isTopConstraint:Bool = true
    @IBInspectable
    var isTop:Bool{
        get{
            return self.isTopConstraint
        }
        set{
            self.isTopConstraint = newValue
        }
    }
    var isSafeArea:Bool = true
    @IBInspectable
    public var isSafe:Bool{
        get{
            return isSafeArea
        }
        set{
            self.isSafeArea = newValue
        }
    }
    override var constant: CGFloat{
        get{
            return self.isSafe ? checkForIphoneX():0
        }
        set{
            super.constant = newValue
        }
    }
    override init() {
        super.init()
    }
    func checkForIphoneX()-> CGFloat{
        if(UIDevice.current.userInterfaceIdiom == .phone){
            if(UIScreen.main.nativeBounds.size.height == 2436.0){ //iPhoneX
                return  self.isTop ? 44.0 : 34.0
            }
        }
        return 0.0
    }
}
class ShowToast: NSObject {
    static var lastToastLabelReference:UILabel?
    static var initialYPos:CGFloat = 0
    class func show(toatMessage:String)
    {
        DispatchQueue.main.async {
            guard toatMessage != kCommonError else{
                
               return
            }
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            ShowHud.hide()
            if lastToastLabelReference != nil
            {
                let prevMessage = lastToastLabelReference!.text?.replacingOccurrences(of: " ", with: "").lowercased()
                let currentMessage = toatMessage.replacingOccurrences(of: " ", with: "").lowercased()
                if prevMessage == currentMessage
                {
                    return
                }
            }
            
            let cornerRadious:CGFloat = 12
            let toastContainerView:UIView={
                let view = UIView()
                view.layer.cornerRadius = cornerRadious
                view.translatesAutoresizingMaskIntoConstraints = false
                view.backgroundColor = UIColor.init(hexString: "#808080")//UIColor.black//kSchoolThemeColor//UIColor.black.withAlphaComponent(0.8)
                view.alpha = 1
                return view
            }()
            let labelForMessage:UILabel={
                let label = UILabel()
                label.layer.cornerRadius = cornerRadious
                label.layer.masksToBounds = true
                label.textAlignment = .center
                label.numberOfLines = 0
                label.adjustsFontSizeToFitWidth = true
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = toatMessage
                label.textColor = .white
                label.backgroundColor = UIColor.init(white: 0, alpha: 0)
                return label
            }()
            
            keyWindow.addSubview(toastContainerView)
            
            let fontType = UIFont.boldSystemFont(ofSize: DeviceType.isIpad() ? 14 : 12)
            labelForMessage.font = fontType
            
            let sizeOfMessage = NSString(string: toatMessage).boundingRect(with: CGSize(width: keyWindow.frame.width, height: keyWindow.frame.height), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:fontType], context: nil)
            
            let topAnchor = toastContainerView.bottomAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0)
            keyWindow.addConstraint(topAnchor)
            
            toastContainerView.centerXAnchor.constraint(equalTo: keyWindow.centerXAnchor, constant: 0).isActive = true
            
            var extraHeight:CGFloat = 0
            if (keyWindow.frame.size.width) < (sizeOfMessage.width+20)
            {
                extraHeight = (sizeOfMessage.width+20) - (keyWindow.frame.size.width)
                toastContainerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: 5).isActive = true
                toastContainerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor, constant: -5).isActive = true
            }
            else
            {
                toastContainerView.widthAnchor.constraint(equalToConstant: sizeOfMessage.width+20).isActive = true
            }
            let totolHeight:CGFloat = sizeOfMessage.height+25+extraHeight
            toastContainerView.heightAnchor.constraint(equalToConstant:totolHeight).isActive = true
            toastContainerView.addSubview(labelForMessage)
            lastToastLabelReference = labelForMessage
            labelForMessage.topAnchor.constraint(equalTo: toastContainerView.topAnchor, constant: 0).isActive = true
            labelForMessage.bottomAnchor.constraint(equalTo: toastContainerView.bottomAnchor, constant: 0).isActive = true
            labelForMessage.leftAnchor.constraint(equalTo: toastContainerView.leftAnchor, constant: 5).isActive = true
            labelForMessage.rightAnchor.constraint(equalTo: toastContainerView.rightAnchor, constant: -5).isActive = true
            keyWindow.layoutIfNeeded()
            
            let padding:CGFloat = initialYPos == 0 ? (DeviceType.isIpad() ? 100 : 70) : 10 // starting position
            initialYPos += padding+totolHeight
            topAnchor.constant = initialYPos
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.4, options: .curveEaseIn, animations: {
                keyWindow.layoutIfNeeded()
            }, completion: { (bool) in
                
                topAnchor.constant = 0
                UIView.animate(withDuration: 0.4, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveLinear, animations: {
                    keyWindow.layoutIfNeeded()
                }, completion: { (bool) in
                    if let lastToastShown = lastToastLabelReference,labelForMessage == lastToastShown
                    {
                        lastToastLabelReference = nil
                    }
                    initialYPos -= (padding+totolHeight)
                    toastContainerView.removeFromSuperview()
                })
            })
        }
    }
   }
}
class ShowHud:NSObject
{
    static let disablerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.15)
        return view
    }()
    
    static let containerView:UIView={
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = UIColor.white//UIColor.init(white: 0.3, alpha: 0)
        return view
    }()
    static var loadingIndicator:UIActivityIndicatorView={
        let loading = UIActivityIndicatorView()
        loading.translatesAutoresizingMaskIntoConstraints = false
        loading.style = .whiteLarge
        loading.backgroundColor = .clear
        loading.color = .black
        loading.layer.cornerRadius = 16
        loading.layer.masksToBounds = true
        return loading
    }()
    static let loadingMsgLabel:UILabel={
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please wait"//Vocabulary.getWordFromKey(key: "loading_hud_please_wait").capitalizingFirstLetter()
        label.textAlignment = .center
        let fontType = UIFont.systemFont(ofSize: DeviceType.isIpad() ? 16 : 14)
        label.font = fontType
        label.textColor = .white
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.alpha = 0
        return label
    }()
    
    static var timerToHideHud:Timer?
    static var timerToShowHud:Timer?
    
    class func show(loadingMessage:String = "Please wait"/*Vocabulary.getWordFromKey(key: "loading_hud_please_wait")*/)
    {
        ShowHud.timerToHideHud?.invalidate()
        UIApplication.shared.resignFirstResponder()
        
        ShowHud.timerToShowHud = Timer.scheduledTimer(timeInterval: 1, target: ShowHud.self, selector: #selector(ShowHud.showHudAfterOneSecond), userInfo: nil, repeats: false)
        
        
    }
    
    class func hide(){
        
        ShowHud.timerToShowHud?.invalidate()
        ShowHud.timerToHideHud = Timer.scheduledTimer(timeInterval: 1, target: ShowHud.self, selector: #selector(ShowHud.hideAfterOneSecond), userInfo: nil, repeats: false)
    }
    
    @objc class func hideAfterOneSecond(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        ShowHud.loadingIndicator.stopAnimating()
        ShowHud.disablerView.removeFromSuperview()
        timerToHideHud?.invalidate()
    }
    @objc class func showHudAfterOneSecond(){
        if let app = UIApplication.shared.delegate as? AppDelegate, let keyWindow = app.window
        {
            if !ShowHud.loadingIndicator.isAnimating
            {
                //  loadingMsgLabel.text = loadingMessage
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                keyWindow.addSubview(disablerView)
                disablerView.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
                disablerView.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
                disablerView.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
                disablerView.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
                ShowHud.loadingIndicator.startAnimating()
                
                disablerView.addSubview(containerView)
                
                containerView.centerXAnchor.constraint(equalTo: disablerView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: disablerView.centerYAnchor).isActive = true
                let squareSize:CGFloat = DeviceType.isIpad() ? 160 : 140
                containerView.widthAnchor.constraint(equalToConstant: squareSize).isActive = true
                containerView.heightAnchor.constraint(equalToConstant: squareSize).isActive = true
                
                
                containerView.addSubview(loadingMsgLabel)
                loadingMsgLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor ,constant:-10).isActive = true
                loadingMsgLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor,constant:-6).isActive = true
                loadingMsgLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor,constant:6).isActive = true
                
                containerView.addSubview(loadingIndicator)
                loadingIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
                loadingIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            }
            else
            {
                //  loadingMsgLabel.text = loadingMessage
            }
        }
    }
}

class DeviceType{
    class func isIpad()->Bool
    {
        return UIDevice.current.userInterfaceIdiom == .pad ? true : false
    }
}
class CustomTextField:UITextField{
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    
    /*
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }*/
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
class RoundButton:UIButton{
    
    required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.layer.cornerRadius = self.bounds.size.height/2
            self.layer.masksToBounds = true
            self.clipsToBounds = true
        
    }
}
class GradientButton: UIButton {
    
    public let buttongradient: CAGradientLayer = CAGradientLayer()
    
    override var isSelected: Bool {  // or isHighlighted?
        didSet {
            updateGradientColors()
        }
    }
    
    func updateGradientColors() {
        let colors: [UIColor]
        
        if isSelected {
            colors = [UIColor.init(hexString:"2963AF"), UIColor.init(hexString:"2963AF").withAlphaComponent(0.5),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),UIColor.white.withAlphaComponent(0.1)]
        } else {
            colors = [UIColor.white.withAlphaComponent(0.1),UIColor.init(hexString:"2963AF").withAlphaComponent(0.2),
                      UIColor.init(hexString:"2963AF").withAlphaComponent(0.5), UIColor.init(hexString:"2963AF")]
        }
        
        buttongradient.colors = colors.map { $0.cgColor }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGradient()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateGradient()
    }
    
    func setupGradient() {
        buttongradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        buttongradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        self.layer.insertSublayer(buttongradient, at: 0)
        
        updateGradientColors()
    }
    
    func updateGradient() {
        buttongradient.frame = self.bounds
        buttongradient.cornerRadius = buttongradient.frame.height / 2
    }
}
class Reachability {
    
    class func isAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
class ShadowView:UIView{
    private var theShadowLayer: CAShapeLayer?
    
   
    override func layoutSubviews() {
        super.layoutSubviews()
            let rounding = CGFloat.init(10.0)
            var shadowLayer = CAShapeLayer.init()
            shadowLayer.name = "ShadowLayer1"
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.3).cgColor
            shadowLayer.shadowRadius = CGFloat.init(2.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 1.0)
            if  let arraySublayer1:[CALayer] = self.layer.sublayers?.filter({$0.name == "ShadowLayer1"}),let sublayer1 =  arraySublayer1.first{
                    sublayer1.removeFromSuperlayer()
            }
            self.layer.insertSublayer(shadowLayer, below: nil)
            shadowLayer = CAShapeLayer.init()
            shadowLayer.name = "ShadowLayer2"
            shadowLayer.path = UIBezierPath.init(roundedRect: bounds, cornerRadius: rounding).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowColor = UIColor.init(red: 60.0/255.0, green: 64.0/255.0, blue: 67.0/255.0, alpha:0.15).cgColor
            shadowLayer.shadowRadius = CGFloat.init(6.0)
            shadowLayer.shadowOpacity = Float.init(0.5)
            shadowLayer.shadowOffset = CGSize.init(width: 0.0, height: 2.0)
            if  let arraySublayer2:[CALayer] = self.layer.sublayers?.filter({$0.name == "ShadowLayer2"}),let sublayer2 =  arraySublayer2.first{
                sublayer2.removeFromSuperlayer()
            }
            self.layer.insertSublayer(shadowLayer, below: nil)
        
    }
}
extension String {
    
    func fileName() -> String {
        return NSURL(fileURLWithPath: self).deletingPathExtension?.lastPathComponent ?? ""
    }
    
    func fileExtension() -> String {
        return NSURL(fileURLWithPath: self).pathExtension ?? ""
    }
}
extension UIColor {
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    static func getThemeTextColor()->UIColor{
        return UIColor.rgb(15, green: 10, blue: 78)
    }
    
    static func getYellowishColor()->UIColor{
        return UIColor.rgb(254, green: 193, blue: 0)
    }
    
    static func switchColor()->UIColor{
        return UIColor.getThemeTextColor()//UIColor.rgb(14, green: 195, blue: 249)
    }
    var imageRepresentation : UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}
extension UIViewController{
    var containerTopContant:CGFloat{
        get{
            if(UIDevice.current.userInterfaceIdiom == .phone){
                if(UIScreen.main.nativeBounds.size.height == 2436.0){ //iPhoneX
                    return  44.0
                }
            }
            return 0.0
        }
    }
    var containerBottomConstant:CGFloat{
        get{
            if(UIDevice.current.userInterfaceIdiom == .phone){
                if(UIScreen.main.nativeBounds.size.height == 2436.0){ //iPhoneX
                    return  34.0
                }
            }
            return 0.0
        }
    }
}
extension Dictionary
{
    func updatedValue(_ value: Value, forKey key: Key) -> Dictionary<Key, Value> {
        var result = self
        result[key] = value
        return result
    }
    
    var nullsRemoved: [Key: Value] {
        let tup = filter { !($0.1 is NSNull) }
        return tup.reduce([Key: Value]()) { $0.updatedValue($1.value, forKey: $1.key) }
    }
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
extension UIView{
    func addShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true,cornerRadius:CGFloat) {
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.clear.cgColor
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = offSet
        shadowLayer.shadowOpacity = 1.0//opacity
        shadowLayer.shadowRadius = radius
        layer.insertSublayer(shadowLayer, at: 0)
    }
    
    func dropShadow(color: UIColor, opacity: Float = 1.0, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath.init(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations:nil)
    }
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
    func invalideField(){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 4, y: self.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 4, y: self.center.y))
        self.layer.add(animation, forKey: "position")
        //self.setBorder(color: .red)
    }
    func setBorder(width:CGFloat = 0.4,color:UIColor){
        self.layer.masksToBounds = false
        self.layer.borderWidth = width
        self.layer.borderColor = color.cgColor
    }
    func validField(){
        self.setBorder(color: .clear)
    }
    func showMessageLabel(msg:String = Vocabulary.getWordFromKey(key:"NoSearchResult"),backgroundColor:UIColor = UIColor.init(white:1, alpha: 1),headerHeight:CGFloat = 0.0){
        DispatchQueue.main.async {
            let label = UILabel()
            label.text = msg
//            label.font = UIFont.italicSystemFont(ofSize: DeviceType.isIpad() ? 20 : 16)
            label.font = UIFont(name: "Avenir-Roman", size: 17.0)
            label.textColor = UIColor.black
            label.numberOfLines = 0
            label.tag = 851
            label.alpha = self.alpha
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            for view in self.subviews{
                if view.tag == 851{
                    view.removeFromSuperview()
                }
            }
            self.addSubview(label)
            if let superView = self.superview{
                superView.layoutIfNeeded()
                
            }
            var lableY = self.bounds.origin.y
            if msg == Vocabulary.getWordFromKey(key:"NoSearchResult"){
                lableY = (UIScreen.main.bounds.height > 568.0) ? self.bounds.origin.y+10.0 :  self.bounds.origin.y + 70.0
            }
            if headerHeight > 0.0{
                if self.bounds.height > headerHeight{
                    let objY =  (UIScreen.main.bounds.height > 568.0) ? headerHeight : 380.0
                    let heightOflbl = (UIScreen.main.bounds.height > 568.0) ? self.bounds.height-headerHeight : 60.0
                    label.frame = CGRect(x: self.bounds.origin.x, y: objY, width: self.bounds.width, height: heightOflbl)
                }
            }else{
                label.frame = CGRect(x: self.bounds.origin.x, y: lableY, width: self.bounds.width, height: self.bounds.height)
            }
            
            
        }
    }
    
    func removeMessageLabel(){
        DispatchQueue.main.async {
            for view in self.subviews{
                if view.tag == 851{
                    view.removeFromSuperview()
                }
            }
        }
    }
    func circularImg(imgWidth:CGFloat) {
        self.layer.cornerRadius = imgWidth / 2
        self.clipsToBounds = true
//        self.layer.borderColor = UIColor.lightGray.cgColor
//        self.layer.borderWidth = 1.5
    }
}
extension UIButton {
    func addBorderWith(width:CGFloat,color:UIColor){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: forState)
    }
}
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
extension Dictionary where  Key == String {
    mutating func updateJSONNullToString(){
        let keysToRemove = self.keys.filter{(self[$0] is NSNull)}
        for key in keysToRemove {
            self["\(key)"] = "" as? Value
        }
    }
}
extension UITableView {
    func scrollToBottom(animated: Bool) {
        let y = contentSize.height - frame.size.height
        setContentOffset(CGPoint(x: 0, y: (y<0) ? 0 : y), animated: animated)
    }
}
extension UITableViewCell {
    
    func hideSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: self.bounds.size.width, bottom: 0, right: 0)
    }
    
    func showSeparator() {
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
extension Dictionary where Value: Any {
    func isEqual(to otherDict: [Key: Any],
                 allPossibleValueTypesAreKnown: Bool = false) -> Bool {
        guard allPossibleValueTypesAreKnown &&
            self.count == otherDict.count else { return false }
        for (k1,v1) in self {
            guard let v2 = otherDict[k1] else { return false }
            switch (v1, v2) {
            case (let v1 as Double, let v2 as Double) : if !(v1.isEqual(to: v2)) { return false }
            case (let v1 as Int, let v2 as Int) : if !(v1==v2) { return false }
            case (let v1 as String, let v2 as String): if !(v1==v2) { return false }
                // ... fill in with types that are known to you to be
            // wrapped by the 'Any' in the dictionaries
            default: return false
            }
        }
        return true
    }
}
extension String { // Caluculate dynamic height of content
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    var changeDateFormateMMddYYYY:String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
    var changeUpdateDateFormateddMMYYYY:String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter.date(from: self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "dd/MM/yyyy"//
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
    var changeDateFormateddMMYYYY:String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
    var changeDateFormat:String{
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = dateFormatter.date(from: self){
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
    var changeDateFormatCalender:String{
        let dateFormatter = DateFormatter()
        let tempLocale = dateFormatter.locale // save locale temporarily
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = dateFormatter.date(from: self){
            let dateFormatter = DateFormatter()
            //dateFormatter.dateStyle = .medium
            dateFormatter.dateFormat = "dd MMM yyyy"
            //dateFormatter.locale = tempLocale // reset the locale
            let dateString = dateFormatter.string(from: date)
            return dateString
        }else{
            return self
        }
    }
    var changeTimeformat:String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let date1 = dateFormatter.date(from: self){
            dateFormatter.dateFormat = "h:mm a"
            return dateFormatter.string(from:date1)
        }else{
            return self
        }
    }

}
class LocalizableLanguage:NSObject{
    var title:String?
}
extension UITextField {
    @IBInspectable var placeholderTextColor: UIColor {
        get {
            return attributedPlaceholder?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor ?? .clear
        }
        set {
            guard let attributedPlaceholder = attributedPlaceholder else { return }
            let attributes: [NSAttributedString.Key: UIColor] = [.foregroundColor: newValue]
            self.attributedPlaceholder = NSAttributedString(string: attributedPlaceholder.string, attributes: attributes)
        }
    }
}
/*
extension ImageViewForURL {
    
    func addShadow(to edges:[UIRectEdge], radius:CGFloat){
        
        let toColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
        let fromColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        //
        // Set up its frame.
        let viewFrame = self.frame
        for edge in edges{
            let gradientlayer          = CAGradientLayer()
            gradientlayer.colors       = [fromColor.cgColor,toColor.cgColor]
            gradientlayer.shadowRadius = radius
            
            switch edge {
            case UIRectEdge.top:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.bottom:
                gradientlayer.startPoint = CGPoint(x: 0.5, y: 1.0)
                gradientlayer.endPoint = CGPoint(x: 0.5, y: 0.0)
                gradientlayer.frame = CGRect(x: 0.0, y: viewFrame.height - gradientlayer.shadowRadius, width: viewFrame.width, height: gradientlayer.shadowRadius)
            case UIRectEdge.left:
                gradientlayer.startPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.frame = CGRect(x: 0.0, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            case UIRectEdge.right:
                gradientlayer.startPoint = CGPoint(x: 1.0, y: 0.5)
                gradientlayer.endPoint = CGPoint(x: 0.0, y: 0.5)
                gradientlayer.frame = CGRect(x: viewFrame.width - gradientlayer.shadowRadius, y: 0.0, width: gradientlayer.shadowRadius, height: viewFrame.height)
            default:
                break
            }
            self.layer.addSublayer(gradientlayer)
        }
    }
}*/
public enum Model : String {
    case simulator     = "simulator/sandbox",
    //iPod
    iPod1              = "iPod 1",
    iPod2              = "iPod 2",
    iPod3              = "iPod 3",
    iPod4              = "iPod 4",
    iPod5              = "iPod 5",
    //iPad
    iPad2              = "iPad 2",
    iPad3              = "iPad 3",
    iPad4              = "iPad 4",
    iPadAir            = "iPad Air ",
    iPadAir2           = "iPad Air 2",
    iPad5              = "iPad 5", //aka iPad 2017
    iPad6              = "iPad 6", //aka iPad 2018
    //iPad mini
    iPadMini           = "iPad Mini",
    iPadMini2          = "iPad Mini 2",
    iPadMini3          = "iPad Mini 3",
    iPadMini4          = "iPad Mini 4",
    //iPad pro
    iPadPro9_7         = "iPad Pro 9.7\"",
    iPadPro10_5        = "iPad Pro 10.5\"",
    iPadPro12_9        = "iPad Pro 12.9\"",
    iPadPro2_12_9      = "iPad Pro 2 12.9\"",
    //iPhone
    iPhone4            = "iPhone 4",
    iPhone4S           = "iPhone 4S",
    iPhone5            = "iPhone 5",
    iPhone5S           = "iPhone 5S",
    iPhone5C           = "iPhone 5C",
    iPhone6            = "iPhone 6",
    iPhone6plus        = "iPhone 6 Plus",
    iPhone6S           = "iPhone 6S",
    iPhone6Splus       = "iPhone 6S Plus",
    iPhoneSE           = "iPhone SE",
    iPhone7            = "iPhone 7",
    iPhone7plus        = "iPhone 7 Plus",
    iPhone8            = "iPhone 8",
    iPhone8plus        = "iPhone 8 Plus",
    iPhoneX            = "iPhone X",
    iPhoneXS           = "iPhone XS",
    iPhoneXSMax        = "iPhone XS Max",
    iPhoneXR           = "iPhone XR",
    //Apple TV
    AppleTV            = "Apple TV",
    AppleTV_4K         = "Apple TV 4K",
    unrecognized       = "?unrecognized?"
}

// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#
//MARK: UIDevice extensions
// #-#-#-#-#-#-#-#-#-#-#-#-#-#-#

public extension UIDevice {
    public var type: Model {
        var systemInfo = utsname()
        uname(&systemInfo)
        let modelCode = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
                
            }
        }
        var modelMap : [ String : Model ] = [
            "i386"      : .simulator,
            "x86_64"    : .simulator,
            //iPod
            "iPod1,1"   : .iPod1,
            "iPod2,1"   : .iPod2,
            "iPod3,1"   : .iPod3,
            "iPod4,1"   : .iPod4,
            "iPod5,1"   : .iPod5,
            //iPad
            "iPad2,1"   : .iPad2,
            "iPad2,2"   : .iPad2,
            "iPad2,3"   : .iPad2,
            "iPad2,4"   : .iPad2,
            "iPad3,1"   : .iPad3,
            "iPad3,2"   : .iPad3,
            "iPad3,3"   : .iPad3,
            "iPad3,4"   : .iPad4,
            "iPad3,5"   : .iPad4,
            "iPad3,6"   : .iPad4,
            "iPad4,1"   : .iPadAir,
            "iPad4,2"   : .iPadAir,
            "iPad4,3"   : .iPadAir,
            "iPad5,3"   : .iPadAir2,
            "iPad5,4"   : .iPadAir2,
            "iPad6,11"  : .iPad5, //aka iPad 2017
            "iPad6,12"  : .iPad5,
            "iPad7,5"   : .iPad6, //aka iPad 2018
            "iPad7,6"   : .iPad6,
            //iPad mini
            "iPad2,5"   : .iPadMini,
            "iPad2,6"   : .iPadMini,
            "iPad2,7"   : .iPadMini,
            "iPad4,4"   : .iPadMini2,
            "iPad4,5"   : .iPadMini2,
            "iPad4,6"   : .iPadMini2,
            "iPad4,7"   : .iPadMini3,
            "iPad4,8"   : .iPadMini3,
            "iPad4,9"   : .iPadMini3,
            "iPad5,1"   : .iPadMini4,
            "iPad5,2"   : .iPadMini4,
            //iPad pro
            "iPad6,3"   : .iPadPro9_7,
            "iPad6,4"   : .iPadPro9_7,
            "iPad7,3"   : .iPadPro10_5,
            "iPad7,4"   : .iPadPro10_5,
            "iPad6,7"   : .iPadPro12_9,
            "iPad6,8"   : .iPadPro12_9,
            "iPad7,1"   : .iPadPro2_12_9,
            "iPad7,2"   : .iPadPro2_12_9,
            //iPhone
            "iPhone3,1" : .iPhone4,
            "iPhone3,2" : .iPhone4,
            "iPhone3,3" : .iPhone4,
            "iPhone4,1" : .iPhone4S,
            "iPhone5,1" : .iPhone5,
            "iPhone5,2" : .iPhone5,
            "iPhone5,3" : .iPhone5C,
            "iPhone5,4" : .iPhone5C,
            "iPhone6,1" : .iPhone5S,
            "iPhone6,2" : .iPhone5S,
            "iPhone7,1" : .iPhone6plus,
            "iPhone7,2" : .iPhone6,
            "iPhone8,1" : .iPhone6S,
            "iPhone8,2" : .iPhone6Splus,
            "iPhone8,4" : .iPhoneSE,
            "iPhone9,1" : .iPhone7,
            "iPhone9,3" : .iPhone7,
            "iPhone9,2" : .iPhone7plus,
            "iPhone9,4" : .iPhone7plus,
            "iPhone10,1" : .iPhone8,
            "iPhone10,4" : .iPhone8,
            "iPhone10,2" : .iPhone8plus,
            "iPhone10,5" : .iPhone8plus,
            "iPhone10,3" : .iPhoneX,
            "iPhone10,6" : .iPhoneX,
            "iPhone11,2" : .iPhoneXS,
            "iPhone11,4" : .iPhoneXSMax,
            "iPhone11,6" : .iPhoneXSMax,
            "iPhone11,8" : .iPhoneXR,
            //AppleTV
            "AppleTV5,3" : .AppleTV,
            "AppleTV6,2" : .AppleTV_4K
        ]
        
        if let model = modelMap[String.init(validatingUTF8: modelCode!)!] {
            if model == .simulator {
                if let simModelCode = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
                    if let simModel = modelMap[String.init(validatingUTF8: simModelCode)!] {
                        return simModel
                    }
                }
            }
            return model
        }
        return Model.unrecognized
    }
}
extension UIButton {
    /// 0 => .ScaleToFill
    /// 1 => .ScaleAspectFit
    /// 2 => .ScaleAspectFill
    @IBInspectable
    var imageContentMode: Int {
        get {
            return self.imageView?.contentMode.rawValue ?? 0
        }
        set {
            if let mode = UIView.ContentMode(rawValue: newValue),
                self.imageView != nil {
                self.imageView?.contentMode = mode
            }
        }
    }
}
extension UIApplication {
    var statusBarView: UIView? {
        if #available(iOS 13, *)
        {
            let statusBar = UIView(frame: (UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame)!)
            UIApplication.shared.keyWindow?.addSubview(statusBar)
            return statusBar
        }else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
