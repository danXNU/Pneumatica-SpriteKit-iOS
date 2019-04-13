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

class InputOutput: SKShapeNode {
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
    
    var holdRecognizer : UILongPressGestureRecognizer?
    
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
    
//    func receive(from input: InputOutput) {
//        ouputsActivatingMe.insert(input)
//        if let pressureValue = self.getMostHightInput()?.ariaPressure, pressureValue > 0 {
//            self.ariaPressure = pressureValue
//        }
//    }
    
//    func stopReceiving(from output: InputOutput) {
//        ouputsActivatingMe.remove(output)
//        if let pressureValue = self.getMostHightInput()?.ariaPressure, pressureValue > 0 {
//            self.ariaPressure = pressureValue
//        } else {
//            self.ariaPressure = 0.0
//        }
//    }
    
    func getMostHightInput() -> InputOutput? {
        return self.inputsConnected.max(by: { $0.ariaPressure > $1.ariaPressure })
    }
}
