//
//  Valvola+Inputs.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import SpriteKit
import UIKit

protocol ValvolaConformance {
    var id: UUID { get }
    var nome: String { get set }
    var descrizione: String { get set }
    
    var labelText: String { get }
    var ios : Set<InputOutput> { get }
    
    func update()
    func enable()
}

enum AriaType {
    case notPresent
    case present(Double)
    
    func get() -> Double {
        switch self {
        case .present(let pressure):
            return pressure
        default:
            return 0.0
        }
    }
}

enum CyclinderState {
    case fuoriuscito
    case interno
    case animating
}

struct MovingPath {
    var startingPoint: CGPoint
    var endPoint: CGPoint
}

protocol Movable: ValvolaConformance {
    var movingState: Double { get }
    var movingPartLocation: CGPoint { get }
    var movingPath: MovingPath { get set }
}
extension Movable {
    var movingState : Double {
        let startPoint = self.movingPath.startingPoint.x
        let endPoint = self.movingPath.endPoint.x
        
        let currentPoint = self.movingPartLocation.x
        
    }
}

protocol IOConformance {
    var id: UUID { get set }
    var parentValvola : ValvolaConformance? { get set }
    var idleColor : UIColor { get set }
    var ariaPressure : Double { get set }
    func update()
}

protocol Tappable: IOConformance {
    func tapped()
}

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
        return self.inputsConnected.max(by: { $0.ariaPressure > $1.ariaPressure })
    }
}

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
    
    func update() {
        
    }
    
}
