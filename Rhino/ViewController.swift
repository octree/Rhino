//
//  ViewController.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var html: String = #"""
    <html>
        <div id="head" class="border"></div>
        <div class="body">
            <div class="center border"></div>
            <div class="center border bottom"></div>
        </div>
    </html>
    """#
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(HTMLParser.parse(html))
    }


}

