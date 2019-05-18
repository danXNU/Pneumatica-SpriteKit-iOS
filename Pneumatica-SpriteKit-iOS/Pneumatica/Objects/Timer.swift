//
//  Timer.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class SpriteTimer: SKShapeNode, ValvolaConformance {
    enum TimerState {
        case isAlreadyFired
        case counting
        case isAbleToFire
    }
    
    var id : UUID = UUID()
    var nome: String = ""
    var descrizione: String = ""
    
    var labelText: String {
        return "Timer"
    }
    
    var state : TimerState = .isAbleToFire
    var timerObject : Timer?
    var duration: TimeInterval = 3
    
    var inputAria: InputOutput!
    var mainOutput: InputOutput!
    
//    var ios: Set<InputOutput> {
//        var set = Set<InputOutput>()
//        set.insert(inputAria)
//        set.insert(mainOutput)
//        return set
//    }
    
    required init(size: CGSize) {
        super.init()
        self.fillColor = .clear
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        self.zPosition = 1
        enable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func enable() {
        self.inputAria  = InputOutput(circleOfRadius: 10, valvola: self)
        self.mainOutput = InputOutput(circleOfRadius: 10, valvola: self)
        
        inputAria.idNumber  = 0
        mainOutput.idNumber = 1
        
        let w = self.frame.size.width
        
        let halfWidth           = w / 2
        inputAria.position.x    = halfWidth  - (inputAria.frame.width / 2)
        inputAria.position.y    = 0 - (inputAria.frame.height / 2)
        inputAria.zPosition     = self.zPosition + 1
        
        mainOutput.position.x   = halfWidth - self.mainOutput.frame.width / 2
        mainOutput.position.y   = self.frame.height - (mainOutput.frame.height / 2)
        mainOutput.zPosition    = self.zPosition + 1
        
        let label           = SKLabelNode(text: labelText)
        label.color         = .white
        label.position.x    = self.frame.width / 2
        label.position.y    = self.frame.height / 2  - label.frame.height / 2
        //        label.position = self.position
        label.zPosition = 2
        addChild(label)
        
        addChild(inputAria)
        addChild(mainOutput)
    }
    
    func update() {
        if self.inputAria.ariaPressure > 0 {
            if self.state == .isAbleToFire {
                startTimer()
            } else if self.state == .isAlreadyFired {
                self.mainOutput.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
            }
        } else if inputAria.ariaPressure <= 0 {
            self.mainOutput.ariaPressure = 0
            self.timerObject?.invalidate()
            self.state = .isAbleToFire
        }
    }
    
    func startTimer() {
        self.state = .counting
        self.timerObject = Timer.scheduledTimer(withTimeInterval: self.duration, repeats: false, block: { (timer) in
            if self.state == .counting {
                self.mainOutput.ariaPressure = self.inputAria.getMostHightInput()?.ariaPressure ?? 0
                self.state = .isAlreadyFired
            }
        })
    }
    
    static var preferredSize: CGSize {
        return .init(width: 100, height: 50)
    }
    
}
