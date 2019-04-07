//
//  Render.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import UIKit

public final class Renderer {
    
    public static func render(html: String, css: String, in view: UIView) {
        
        var dimensions = Dimensions.zero
        dimensions.content = Rect(x: 0,
                                  y: 0,
                                  width: Double(view.frame.width),
                                  height: Double(view.frame.height))
        
        let style = CSSParser.parse(css)
        let dom = HTMLParser.parse(html)
        let styled = StyledTreeBuilder.buildStyledTree(root: dom, stylesheet: style)
        let layoutBox = LayoutTreeBuilder.buildLayoutTree(styledNode: styled)
        layoutBox.layout(containingBlock: dimensions)
        renderSubViews(in: view, layout: layoutBox)
    }
    
    private static func renderSubViews(in view: UIView, layout: LayoutBox) {
        
        let subView = UIView()
        
        if let node = layout.styledNode {
            subView.backgroundColor = node.bg
            subView.layer.borderWidth = CGFloat(layout.dimensions.border.left)
            subView.layer.borderColor = node.borderColor?.cgColor
        }
        subView.frame = layout.dimensions.cgRect
        view.addSubview(subView)
        
        layout.children.forEach { renderSubViews(in: view, layout: $0) }
    }
}

extension StyledNode {
    
    func color(key: String) -> UIColor? {
        if case let .some(.color(c)) = value(forName: key) {
            
            return UIColor(red: CGFloat(c.r) / 255.0,
                           green: CGFloat(c.g) / 255.0,
                           blue: CGFloat(c.b) / 255.0,
                           alpha:1)
        }
        return nil
    }
    
    var bg: UIColor? {
        
        return color(key: "background")
    }
    
    var borderColor: UIColor? {
        
        return color(key: "border-color")
    }
}

extension Dimensions {
    
    var cgRect: CGRect {
        
        let box = borderBox
        return CGRect(x: box.x, y: box.y, width: box.width, height: box.height)
    }
}
