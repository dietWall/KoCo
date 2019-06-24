//
//  TextField.swift
//  KoCo
//
//  Created by dietWall on 15.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import UIKit


extension UIViewController{
    
    func jumpToTextField(textField: UITextField)
    {
        DispatchQueue.main.async {
            let newPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
    
}
