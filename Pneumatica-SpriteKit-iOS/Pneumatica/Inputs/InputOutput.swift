//
//  InputOutput.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 15/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import SpriteKit

class InputOutput: SKShapeNode, IOConformance {
    static func == (lhs: InputOutput, rhs: InputOutput) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : UUID = UUID()
    var parentValvola : ValvolaConformance?
    var idleColor: UIColor = .red
    
    var inputsConnected : Set<InputOutput> = []
    //    var ouputsActivatingMe : Set<InputOutput> = []
    
    var ariaPressure : Double = 0.0 {
        didSet {
            DispatchQueue.main.async {
                if self.ariaPressure == 0 {
                    self.fillColor = self.idleColor
                } else {
                    self.fillColor = .green
                }
            }
        }
    }
    
    init(circleOfRadius: CGFloat, valvola: ValvolaConformance){
        super.init()
        let diameter = circleOfRadius * 2
        self.path = CGPath(ellipseIn: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
        
        self.fillColor = self.idleColor
        self.parentValvola = valvola
        self.name = "\(self.parentValvola!.labelText)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        if inputsConnected.isEmpty {
            self.ariaPressure = 0
            return
        }
        
        if let mostPowerInput = self.getMostHightInput() {
            self.ariaPressure = mostPowerInput.ariaPressure
        } else {
            self.ariaPressure = 0
        }
    }
    
    func addWire(from output: InputOutput) {
        output.inputsConnected.insert(self)
        self.inputsConnected.insert(output)
    }
    
    func removeWire(_ wire: InputOutput) {
        self.inputsConnected.remove(wire)
        wire.inputsConnected.remove(self)
    }
    
    func getMostHightInput() -> InputOutput? {
        return self.inputsConnected.max(by: { $0.ariaPressure < $1.ariaPressure })
    }
}
