//
//  Valvola+Inputs.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import SpriteKit

protocol ValvolaConformance {
    var id: UUID { get }
    var nome: String { get set }
    var descrizione: String { get set }
    
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
    var ariaValue : AriaType = .notPresent {
        didSet {
            DispatchQueue.main.async {
                switch self.ariaValue {
                case .notPresent:
                    self.fillColor = .blue
                case .present(_):
                    self.fillColor = .green
                }
            }
        }
    }
    
    var inputsConnected : Set<InputOutput> = []
    var ouputsActivatingMe : Set<InputOutput> = []
    
//    init(valvola: ValvolaConformance, shape: CGRect) {
//        self.parentValvola = valvola
//        self.id = UUID()
//        self.ariaValue = AriaType.notPresent
//        super.init(rect: shape)
//        self.name = id.uuidString
//    }

//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    init(circleOfRadius: CGFloat, valvola: ValvolaConformance){
        super.init()
        let diameter = circleOfRadius * 2
        self.path = CGPath(ellipseIn: CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter)), transform: nil)
        
        self.parentValvola = valvola
        self.name = id.uuidString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addWire(from output: InputOutput) {
        output.inputsConnected.insert(self)
        self.inputsConnected.insert(output)
    }
    
    func removeWire(_ wire: InputOutput) {
        self.ouputsActivatingMe.remove(wire)
        self.inputsConnected.remove(wire)
        wire.inputsConnected.remove(self)
    }
    
    func receive(from input: InputOutput) {
        ouputsActivatingMe.insert(input)
        if let pressureValue = self.getMostHightInput()?.ariaValue.get(), pressureValue > 0 {
            self.ariaValue = .present(pressureValue)
            self.fillColor = .green
        }
    }
    
    func stopReceiving(from output: InputOutput) {
        ouputsActivatingMe.remove(output)
        if let pressureValue = self.getMostHightInput()?.ariaValue.get(), pressureValue > 0 {
            self.ariaValue = .present(pressureValue)
        } else {
            self.ariaValue = .notPresent
            self.fillColor = .blue
        }
    }
    
    private func getMostHightInput() -> InputOutput? {
        return self.ouputsActivatingMe.max(by: { $0.ariaValue.get() > $1.ariaValue.get() })
    }
}
