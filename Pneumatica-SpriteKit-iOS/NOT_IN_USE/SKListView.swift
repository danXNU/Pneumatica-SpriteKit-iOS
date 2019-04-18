//
//  SKListView.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class SKListView : SKShapeNode {
    
    struct ListLine {
        var objects : [ValvolaConformance]
    }
    
    var objects : [ValvolaConformance] = []
    var lines: [ListLine] = []
    
   
    
    init(size: CGSize, objects: [ValvolaConformance]) {
        super.init()
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        self.objects = objects
        
        createVirtualLines()
        createLineNodes(size, objects)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createLineNodes(_ size: CGSize, _ objects: [ValvolaConformance]) {
        let currentWidth = Int(size.width)
        let currentHeight = Int(size.height)
        let lineHeight = currentHeight / self.lines.count
        
        var tempObjects = objects
        
        for lineIndex in 1...self.lines.count {
            let size        = CGSize(width: currentWidth, height: lineHeight)
            var lineObjects = [ValvolaConformance]()
            if tempObjects.count < 5 {
                lineObjects = tempObjects
            } else {
                lineObjects = Array(tempObjects.prefix(upTo: 5))
            }
            let lineNode    = LineNode(size: size, objects: lineObjects)
            
            if tempObjects.count < 5 {
                tempObjects.removeAll()
            } else {
                tempObjects.removeFirst(5)
            }
            
            
            lineNode.zPosition = self.zPosition + 1
            lineNode.position.x = 0
            lineNode.position.y = CGFloat(lineIndex * lineHeight)
            
            self.addChild(lineNode)
        }
    }
    
    fileprivate func createVirtualLines() {
        let typesCount      = Float(objects.count)
        let linesRequired   = Int((typesCount / 5.0).rounded(.awayFromZero))
        var tempArray       = objects
        
        
        for i in 0..<linesRequired {
            let index = i * 5
            let objects = Array(tempArray.prefix(upTo: index))
            if objects.count < 5 {
                tempArray.removeAll()
            } else {
                tempArray.removeFirst(5)
            }
            
            
            let newLine = ListLine(objects: objects)
            self.lines.append(newLine)
        }
    }
    
}
