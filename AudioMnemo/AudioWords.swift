//
//  AudioWords.swift
//  SQLiteTest
//
//  Created by yong gu on 10/7/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class AudioWords{
    let mainBoard=UIStoryboard.init(name: "Main", bundle: nil)
    var settingVCs: UINavigationController!
    var settingRootVC:SettingRootViewController!
    init(mainVCs: [UIViewController]){
        settingVCs  = mainVCs[3] as! UINavigationController
        settingRootVC = (settingVCs.viewControllers)[0] as! SettingRootViewController
    }
}