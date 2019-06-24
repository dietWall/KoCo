//
//  Image.swift
//  KoCo
//
//  Created by dietWall on 24.06.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    
    static func fromURL(url: URL)throws ->UIImage?{
        let imgData = try Data(contentsOf: url)
        let img = UIImage(data: imgData)
        return img
    }
    
    static func imageWith(string: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = .lightGray
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        nameLabel.text = string
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
}
