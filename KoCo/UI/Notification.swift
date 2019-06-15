//
//  Notification.swift
//  KoCo
//
//  Created by dietWall on 15.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


extension UIViewController{
    
    struct NotificationButton{
        let text: String
        let style : UIAlertAction.Style
    }
    
    struct Notification{
        let title: String
        let alertStyle: UIAlertController.Style
        let message : String
        let actions : [NotificationButton]
    }
    
//    struct AlertButton{
//        let button: UIAlertAction
//        let completion : (UIAlertAction)->Void
//    }
//
//    struct Alert{
//        let title: String
//        let alertStyle: UIAlertController.Style
//        let message : String
//        let buttons : [AlertButton]
//    }
    
    func createNotification(notification: Notification){
        let alert = UIAlertController(title: notification.title, message: notification.message, preferredStyle: notification.alertStyle)
        
        for button in notification.actions{
            alert.addAction(UIAlertAction(title: NSLocalizedString(button.text, comment: ""), style: button.style,  handler: { _ in
                //Just a notification, nothing to do here
            }))
        }
        
        //Present from the main queue
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    //Maybe add Completion as a paramter??
//    func createAlert(alert : Alert){
//
//        let view = UIAlertController(title: alert.title, message: alert.message, preferredStyle: alert.alertStyle)
//
//        for button in alert.buttons{
//            view.addAction(UIAlertAction(title: NSLocalizedString(button.button.text, comment: ""), style: button.button.style,  handler: button.completion))
//        }
//
//        //Present from the main queue
//        DispatchQueue.main.async { [weak self] in
//            self?.present(view, animated: true, completion: nil)
//        }
//    }
    
}
