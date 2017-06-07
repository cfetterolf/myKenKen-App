//
//  CustomNavigationBar.swift
//  KenKen
//
//  Created by Chris Fetterolf on 6/7/17.
//  Copyright © 2017 DeepHouse. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let newSize :CGSize = CGSize(width: self.frame.size.width, height: 35)
        return newSize
    }
    
    
}
