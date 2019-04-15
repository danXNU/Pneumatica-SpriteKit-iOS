//
//  Valvola+Inputs.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import SpriteKit
import UIKit

class PressableInput : SKShapeNode, Tappable {
    static func == (lhs: PressableInput, rhs: PressableInput) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : UUID = UUID()
    var parentValvola : ValvolaConformance?
    var idleColor: UIColor = .red
    
    
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
    
    init(size: CGSize, valvola: ValvolaConformance){
        super.init()
        self.path = CGPath(rect: CGRect(origin: .zero, size: size), transform: nil)
        
        self.fillColor = self.idleColor
        self.parentValvola = valvola
        self.name = "\(self.parentValvola!.labelText)"
        
    }
    
    func tapped() {
        if self.ariaPressure <= 0 {
            self.ariaPressure = 2
        } else {
            self.ariaPressure = 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
