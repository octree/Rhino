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
    
    var css: String = #"""
    html {
        width: 300px;
        height: 400px;
        padding: 20px;
        margin-left: 10px;
        margin-top: 60px;
        background: #ff0000;
        display: block;
    }


    #head {
        width: 200px;
        height: 40px;
        background: #ffa500;
        display: block;
    }
    
    .body {
        width: 200px;
        background: #ffff00;
        display: block;
    }

    .border {
        border-width: 4px;
        border-color: #008000;
    }
    
    .center {
        margin: auto;
        margin-top: 20px;
        width: 100px;
        height: 80px;
        background: #0000ff;
        display: block;
    }

    .bottom {
        margin-bottom: 20px;
        background: #00ffff;
    }
    """#
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(HTMLParser.parse(html))
//        print(CSSParser.parse(css))
        
        Renderer.render(html: html, css: css, in: view)
    }


}

