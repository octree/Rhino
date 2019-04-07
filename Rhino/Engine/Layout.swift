//
//  Layout.swift
//  Rhino
//
//  Created by Octree on 2019/4/7.
//  Copyright © 2019 Octree. All rights reserved.
//

import Foundation


public struct EdgeSize {
    
    public var left: Double
    public var right: Double
    public var top: Double
    public var bottom: Double
}

public extension EdgeSize {
    
    static var zero: EdgeSize {
        
        return EdgeSize(left: 0, right: 0, top: 0, bottom: 0)
    }
}

public struct Rect {
    
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
}

public extension Rect {
    
    static var zero: Rect {
        
        return Rect(x: 0, y: 0, width: 0, height: 0)
    }
}

public struct Dimensions {
    
    public var content: Rect
    public var padding: EdgeSize
    public var margin: EdgeSize
    public var border: EdgeSize
}

public extension Dimensions {
    
    static var zero: Dimensions {
        
        return Dimensions(content: .zero, padding: .zero, margin: .zero, border: .zero)
    }
}


extension Rect {
    
    func expanded(by edge: EdgeSize) -> Rect {
        
        return Rect(x: x - edge.left,
                    y: y - edge.top,
                    width: width + edge.left + edge.right,
                    height: height + edge.top + edge.bottom)
    }
}

public extension Dimensions {
    
    var paddingBox: Rect {
        
        return content.expanded(by: padding)
    }
    
    var borderBox: Rect {
        
        return paddingBox.expanded(by: border)
    }
    
    var marginBox: Rect {
        
        return borderBox.expanded(by: margin)
    }
}


public enum Display {
    case inline
    case block
    case none
}


public enum BoxType {
    case blockNode(StyledNode)
    case inlineNode(StyledNode)
    case anonymousBlock
}

public class LayoutBox {
    
    public var dimensions: Dimensions
    public var boxType: BoxType
    public var children: [LayoutBox]
    public init(boxType: BoxType) {
        
        self.boxType = boxType
        self.dimensions = .zero
        self.children = []
    }
    
}

public extension StyledNode {
    
    var display: Display {
        
        guard let val = value(forName: "display") else {
            return .inline
        }
        guard case let .keyword(display) = val else {
            return .inline
        }
        
        switch display {
        case "block":
            return .block
        case "none":
            return .none
        default:
            return .inline
        }
    }
}

extension LayoutBox {
    
    /// 如果 block 包含 inline，创建一个 block 容器。
    /// 如果有多个 inline，放在一起
    func getInlineContainer() -> LayoutBox {
        
        switch self.boxType {
        case .inlineNode(_):
            fallthrough
        case .anonymousBlock:
            return self
        case .blockNode(_):
            
            if let last = children.last, case .anonymousBlock = last.boxType {
                return last
            } else {
                let block = LayoutBox(boxType: .anonymousBlock)
                children.append(block)
                return block
            }
        }
    }
}

public final class LayoutTreeBuilder {
    
    public static func buildLayoutTree(styledNode: StyledNode) -> LayoutBox {
        
        let boxType: BoxType
        switch styledNode.display {
        case .block:
            boxType = .blockNode(styledNode)
        case .inline:
            boxType = .inlineNode(styledNode)
        case .none:
            #warning("应该返回一个空的 LayoutBox")
            boxType = .anonymousBlock
        }
        
        let box = LayoutBox(boxType: boxType)
        
        styledNode.children.forEach {
            switch $0.display {
            case .block:
                box.children.append(buildLayoutTree(styledNode: $0))
            case .inline:
                box.getInlineContainer().children.append(buildLayoutTree(styledNode: $0))
            case .none:
                break
            }
        }
        return box
    }
}


public extension LayoutBox {
    
    var styledNode: StyledNode? {
        
        switch self.boxType {
        case let .blockNode(node):
            return node
        case let .inlineNode(node):
            return node
        case .anonymousBlock:
            return nil
        }
    }
}


public extension LayoutBox {
    
    
    /// layout
    /// 计算布局信息，转换成 Frame 等各种信息
    ///
    /// - Parameter containingBlock: 父组件的布局信息
    func layout(containingBlock: Dimensions) {
        
        switch self.boxType {
        case .blockNode(_):
            layoutBlock(containingBlock: containingBlock)
        case .inlineNode(_):
            break
        case .anonymousBlock:
            break
        }
    }
    
    private func layoutBlock(containingBlock: Dimensions) {
        
        calculateBlockWidth(containingBlock: containingBlock)
        calculateBlockPosition(containingBlock: containingBlock)
        layoutChildren()
        calculateBlockHeight()
    }
    
    private func calculateBlockWidth(containingBlock: Dimensions) {
        
        let style = styledNode!
        let auto = Value.keyword("auto")
        
        var width = style.value(forName: "width") ?? auto
        let zero = Value.length(0, .px)
        
        var marginLeft = style.lookup("margin-left", "margin", zero)
        var marginRight = style.lookup("margin-right", "margin", zero)
        
        let borderLeft = style.lookup("border-left-width", "border-width", zero)
        let borderRight = style.lookup("border-right-width", "border-width", zero)
        
        let paddingLeft = style.lookup("padding-left", "padding", zero)
        let paddingRight = style.lookup("padding-right", "padding", zero)
        
        let total = [marginLeft, marginRight, paddingLeft, paddingRight, borderLeft, borderRight, width].map { $0.px }.reduce(0, +)
        
        if width != auto && total > containingBlock.content.width {
            
            if marginLeft == auto {
                
                marginLeft = zero
            }
            
            if marginRight == auto {
                
                marginRight = zero
            }
        }
        
        let underflow = containingBlock.content.width - total
        switch (width == auto, marginLeft == auto, marginRight == auto) {
        case (false, false, false):
            // 如果都不是 auto，多余的部分添加到右边
            marginRight = .length(marginRight.px + underflow, .px)
        case (false, false, true):
            marginRight = .length(underflow, .px)
        case (false, true, false):
            marginLeft = .length(underflow, .px)
        case (true, _, _):
            if marginLeft == auto {
                marginLeft = zero
            }
            if marginRight == auto {
                marginRight = zero
            }
            if underflow > 0 {
                width = .length(underflow, .px)
            } else {
                width = zero
                marginRight = .length(marginRight.px + underflow, .px)
            }
        case (false, true, true):
            
            marginLeft = .length(underflow / 2, .px)
            marginRight = marginLeft
        }
        
        self.dimensions.content.width = width.px
        
        self.dimensions.padding.left = paddingLeft.px
        self.dimensions.padding.right = paddingRight.px
        
        self.dimensions.border.left = borderLeft.px
        self.dimensions.border.right = borderRight.px
        
        self.dimensions.margin.left = marginLeft.px
        self.dimensions.margin.right = marginRight.px
    }
    
    private func calculateBlockPosition(containingBlock: Dimensions) {
        
        let style = styledNode!
        
        let zero = Value.length(0, .px)
        
        dimensions.margin.top = style.lookup("margin-top", "margin", zero).px
        dimensions.margin.bottom = style.lookup("margin-bottom", "margin", zero).px
        
        dimensions.border.top = style.lookup("border-top-width", "border-width", zero).px;
        dimensions.border.bottom = style.lookup("border-bottom-width", "border-width", zero).px
        
        dimensions.padding.top = style.lookup("padding-top", "padding", zero).px
        dimensions.padding.bottom = style.lookup("padding-bottom", "padding", zero).px
        
        dimensions.content.x = containingBlock.content.x + dimensions.margin.left + dimensions.padding.left + dimensions.border.left
        
        dimensions.content.y = containingBlock.content.y + dimensions.margin.top + dimensions.padding.top + dimensions.border.top
    }
    
    private func layoutChildren() {
        
        var d = self.dimensions
        children.forEach {
            $0.layout(containingBlock: d)
            // relative layout
            d.content.y += $0.dimensions.marginBox.height
            self.dimensions.content.height += $0.dimensions.marginBox.height
        }
    }
    
    private func calculateBlockHeight() {
        
        let style = styledNode!
        if case let .some(.length(h, .px)) = style.value(forName: "height") {
            
            dimensions.content.height = h
        }
    }
}
