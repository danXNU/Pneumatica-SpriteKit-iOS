//
//  ListNode.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class ListNode : SKShapeNode {
    
    init(string: String, size: CGSize) {
        super.init()
        self.path = CGPath(rect: .init(origin: .zero, size: size), transform: nil)
        
        let label = SKLabelNode(text: string)
        label.zPosition = self.zPosition + 1
        label.position.x = 0 + (self.frame.width - label.frame.width) / 2
        label.position.y = self.frame.height / 2 - label.frame.height / 2
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
