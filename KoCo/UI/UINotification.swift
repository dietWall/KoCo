//
//  Notification.swift
//  KoCo
//
//  Created by dietWall on 15.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


extension UIViewController{
    
    struct UINotificationButton{
        let text: String
        let style : UIAlertAction.Style
    }
    
    struct UINotification{
        let title: String
        let alertStyle: UIAlertController.Style
        let message : String
        let actions : [UINotificationButton]
    }
    
    func presentUINotification(notification: UINotification){
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
}


//Error Handler

extension UIViewController{
    
    private func createUINotification(responseCode: Int) -> UINotification{
        return UINotification(title: "Request Failed", alertStyle: .alert, message: "Statuscode : \(responseCode)" , actions: [UINotificationButton(text: "Ok", style: .default)] )
    }
    
    private func createUINotification(errorString: String) -> UINotification{
        return UINotification(title: "Network Error", alertStyle: .alert, message: "Error: \(errorString)" , actions: [UINotificationButton(text: "Ok", style: .default)] )
    }
    
    private func createUINotification()->UINotification{
        return UINotification(title: "Internal Error", alertStyle: .alert, message: "Unknown internal Error" , actions: [UINotificationButton(text: "Ok", style: .default)] )
    }
    

    func wrongStatusCodeHandler(response : HTTPURLResponse){
        let notification = createUINotification(responseCode: response.statusCode)
        self.presentUINotification(notification: notification)
    }
    
    func errorHandler(error: Error){
        let notification = createUINotification(errorString: error.localizedDescription)
        self.presentUINotification(notification: notification)
    }
    
    
    func networkError(response: HTTPURLResponse?, error: Error?){
        guard let response = response else {
            
            guard let error = error else {
                let not = createUINotification(errorString: "Unknown internal error")
                presentUINotification(notification: not)
                return
            }
            
            errorHandler(error: error)
            return
        }
        
        wrongStatusCodeHandler(response: response)
    }
    
    func resultError(){
        let notifification = createUINotification()
        presentUINotification(notification: notifification)
    }
    
}


