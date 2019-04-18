//
//  LineNode.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class LineNode : SKShapeNode {
    
    var objects: [ValvolaConformance] = []
    
    init(size: CGSize, objects: [ValvolaConformance]) {
        super.init()
        self.path = CGPath(rect: .init(origin: .zero, size: size), transform: nil)
        self.objects = objects
        
        let lineWidth   = size.width / 5
        let lineHeight  = size.height
        
        for (index, object) in self.objects.enumerated() {
            let newNode = ListNode(string: object.stringValue, size: .init(width: lineWidth, height: lineHeight))
            newNode.zPosition = self.zPosition + 1
            newNode.position.x = CGFloat(index) * lineHeight
            newNode.position.y = 0
            addChild(newNode)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
