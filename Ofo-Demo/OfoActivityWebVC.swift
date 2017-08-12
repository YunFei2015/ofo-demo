//
//  ActivityWebVC.swift
//  Ofo-Demo
//
//  Created by 云菲 on 2017/7/29.
//  Copyright © 2017年 Freya. All rights reserved.
//

import UIKit
import WebKit

class OfoActivityWebVC: UIViewController {
    var webView : WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        
        webView = WKWebView(frame : self.view.frame)
        view.addSubview(webView)
        
        self.title = "热门活动"
        let url = URL(string: "https://m.ofo.so/active.html")!
        let request = URLRequest(url: url)
        webView.load(request)
        
//        request.httpMethod = "GET"
//        
//        let configuration : URLSessionConfiguration = URLSessionConfiguration.default
//        let session : URLSession = URLSession(configuration: configuration)
//        let task : URLSessionDataTask = session.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
//            if error == nil{
//                do{
//                    let responseData : NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
//                    print(responseData)
//                }catch{
//                    
//                }
//            }
//        }
//        
//        task.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
