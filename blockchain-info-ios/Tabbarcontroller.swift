//
//  tabbarcontroller.swift
//  blockchain-info-ios
//
//  Created by staff on 2019/01/28.
//  Copyright © 2019 takumi-kimura. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // カスタマイズ
        
        // アイコンの色
        UITabBar.appearance().tintColor = UIColor(red: 255/255, green: 233/255, blue: 51/255, alpha: 1.0) // yellow
        
        // 背景色
        UITabBar.appearance().barTintColor = UIColor(red: 66/255, green: 74/255, blue: 93/255, alpha: 1.0) // grey black
        
    }

}
