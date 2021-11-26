//
//  FeesDetailViewController.swift
//  SchoolApp
//
//  Created by user on 22/03/19.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class FeesDetailViewController: UIViewController {

    @IBOutlet var navigationView:UIView!
    @IBOutlet var lblTitle:UILabel!
    
    @IBOutlet var objectWebView:UIWebView!
    
    var strGraphURL:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //setUpView
        self.navigationView.backgroundColor = kSchoolThemeColor
        self.lblTitle.text = Vocabulary.getWordFromKey(key: "genral.FeesDetail")
        self.objectWebView.backgroundColor = UIColor.white
        self.objectWebView.delegate = self
        if let objUrl = URL.init(string:"\(strGraphURL)"){
            let objectRequest = URLRequest.init(url: objUrl)
            self.objectWebView.loadRequest(objectRequest)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeLeft, andRotateTo: UIInterfaceOrientation.landscapeLeft)
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    @IBAction func buttonBackSelector(sender:UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
extension FeesDetailViewController:UIWebViewDelegate{
    func webViewDidStartLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            ProgressHud.show()
        }
    }
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ShowToast.show(toatMessage: "\(error.localizedDescription)")
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        DispatchQueue.main.async {
            ProgressHud.hide()
        }
    }
}
