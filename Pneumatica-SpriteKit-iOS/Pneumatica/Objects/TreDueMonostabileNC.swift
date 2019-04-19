//
//  TreDueMonostabileNC.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class TreDueMonostabileNC : SKShapeNode, ValvolaConformance {
    enum ValvolaState {
        case aperta
        case chiusa
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "3/2 Mono NC"
    }
    
    var state : ValvolaState = .chiusa {
        didSet {
            switch state {
            case .chiusa:
                self.mainOutput.ariaPressure = 0
            case .aperta:
                self.mainOutput.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
            }
        }
    }
    
    var inputAria : InputOutput!
    var inputLeft: InputOutput!
    var mainOutput: InputOutput!
    
//    var ios: Set<InputOutput> {
//        var set = Set<InputOutput>()
//        set.insert(inputAria)
//        set.insert(inputLeft)
//        set.insert(mainOutput)
//        return set
//    }
    
    required init(size: CGSize) {
        super.init()
        self.fillColor = .clear
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        enable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable() {
        
        self.inputLeft  = InputOutput(circleOfRadius: 10, valvola: self)
        self.inputAria = InputOutput(circleOfRadius: 10, valvola: self)
        self.mainOutput = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputLeft.idNumber = 0
        inputAria.idNumber = 1
        mainOutput.idNumber = 2
        
        let w = self.frame.size.width
        inputLeft.position.x = 0 - (inputLeft.frame.width / 2)
        inputLeft.position.y = self.frame.height / 2 - inputLeft.frame.height / 2
        inputLeft.zPosition = self.zPosition + 1
        
        let halfWidth = w / 2
        inputAria.position.x = halfWidth + halfWidth / 2 - (inputLeft.frame.width / 2)
        inputAria.position.y = 0 - (inputLeft.frame.height / 2)
        inputAria.zPosition = self.zPosition + 1
        
        mainOutput.position.x = self.frame.midX
        mainOutput.position.y = self.frame.height - (mainOutput.frame.height / 2)
        mainOutput.zPosition = self.zPosition + 1
        
        let label = SKLabelNode(text: labelText)
        label.color = .white
        label.position.x = self.frame.width / 2
        label.position.y = self.frame.height / 2  - label.frame.height / 2
        //        label.position = self.position
        label.zPosition = 2
        addChild(label)
        
        addChild(inputLeft)
        addChild(inputAria)
        addChild(mainOutput)
    }
    
    func update() {
        if self.inputLeft.ariaPressure > 0 {
            self.state = .aperta
        } else {
            self.state = .chiusa
        }
    }
    
    
    static var preferredSize: CGSize {
        return .init(width: 200, height: 50)
    }
}
