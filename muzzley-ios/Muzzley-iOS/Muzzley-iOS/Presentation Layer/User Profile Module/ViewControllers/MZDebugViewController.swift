//
//  MZDebugViewController.swift
//  Muzzley-iOS
//
//  Created by Jorge Mendes on 05/05/16.
//  Copyright © 2016 Muzzley. All rights reserved.
//

import UIKit
import MessageUI

class MZDebugViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var textArea: UITextView!
    
    @IBAction func uiBtEmail(_ sender: Any) {
       self.sendEmailWithLogFiles()
    }
    fileprivate var content: String = ""
    
    convenience init() {
        self.init(nibName: "MZDebugViewController", bundle: Bundle.main)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            UIAlertView(title: "Email sent with success", message: "", delegate: self, cancelButtonTitle: "ok").show()
            break
        case .failed:
            UIAlertView(title: NSLocalizedString("mobile_send_mail_error_title", comment: ""), message: NSLocalizedString("mobile_send_mail_error_text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: "")).show()
            break
        default:
            break
            
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Debug Logs"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Disable", style: .done, target: self, action: #selector(MZDebugViewController.disableLogs(_:)))
        self.loadFiles()
    }
    
    func sendEmailWithLogFiles()
    {
        //let window: UIWindow?
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([])
        
        let executableName = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let build =  Bundle.main.infoDictionary?["CFBundleVersion"] as! String
        let model = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        let name = UIDevice.current.name
        let systemName = UIDevice.current.systemName
        
        let appVersion = executableName + "/" + version + "." + build + " (" + model + "/" + systemName + " " + systemVersion + ")"
        
        mailComposerVC.setSubject("iOS Debug Info - " + appVersion)
        
        var mailBody = "This is the debug log for the userID: " + MZSession.sharedInstance.authInfo!.userId + ".\nApplication ID: " + MZSession.sharedInstance.authInfo!.clientId + "\nApp Info: " + appVersion
        mailBody += "\n\n\n----------------------------------------------------------------------------------\n\n\n"
        
        mailBody += "\n\n-------------- Begin stats from phone --------------\n\n"
        var excelStr = MZAppStatsHelper.shared.getDailyInfoStringCSV()
        mailBody += excelStr
        mailBody += "\n\n-------------- End stats from phone --------------\n\n"
        
        
        
        mailBody += "\n\n-------------- Begin log from phone --------------\n\n"
        mailBody += self.textArea.text
        mailBody += "\n\n-------------- End log from phone --------------\n\n"
        
        mailBody += "\n\n----------------------------------------------------------------------------------\n\n"
        
        mailComposerVC.setMessageBody(mailBody, isHTML: false)
        
        if(MFMailComposeViewController.canSendMail())
        {
            UIApplication.shared.keyWindow?.rootViewController?.present(mailComposerVC, animated: true, completion: nil)
        }
        else
        {
            let sendMailErrorAlert = UIAlertView(title: NSLocalizedString("mobile_send_mail_error_title", comment: ""), message: NSLocalizedString("mobile_send_mail_error_text", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("mobile_ok", comment: ""))
            sendMailErrorAlert.show()
        }
    }
    
    fileprivate func loadFiles() {
        
        var bundleSteps: [String] = []
        do {
            bundleSteps = try FileManager.default.contentsOfDirectory(atPath: logsDirectory)
        } catch let ex {
//            dLog(message: "\(ex)")
            return
        }
        
        bundleSteps.forEach { (fileName: String) in
            self.content += fileName
            
            if let content: String = try! String(contentsOfFile: logsDirectory + "/" + fileName, encoding: String.Encoding.utf8) {
                self.content += content + "==========EOF==========\n\n"
            }
        }
        
        self.textArea.text = content
        let range = NSMakeRange(self.textArea.text.characters.count - 1, 1);
        self.textArea.scrollRangeToVisible(range);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let range = NSMakeRange(self.textArea.text.characters.count - 1, 1);
        self.textArea.scrollRangeToVisible(range);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func disableLogs(_ sender: AnyObject) {
        UserDefaults.standard.set(false, forKey: "DebugEnabled")
        UserDefaults.standard.synchronize()
    }

}
