//
//  HelpViewController.swift
//  AudioMnemo
//
//  Created by yong gu on 10/10/15.
//  Copyright © 2015 Thu. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController{
    
    @IBOutlet var textView1: UITextView!
    
    override func viewDidLoad() {
        let text1 = "Scan\n In Scan, tap right/left half of screen to move to next/last word\n press left speaker button to enunciate the word and the right speaker to enunciate the translation"
        textView1.text = text1
        textView1.editable = false
    }
}