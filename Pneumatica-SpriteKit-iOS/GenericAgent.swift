//
//  GenericAgent.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Daniel Fortesque on 21/01/2020.
//  Copyright © 2020 Dani Tox. All rights reserved.
//

import Foundation
import DXPneumatic

class GenericAgent: ObservableObject {
    @Published var isShowingValvoleList: Bool = true
    @Published var isShowingVariablesEditor: Bool = true
    @Published var selectedValvola: UIValvola? = nil {
        willSet {
            if let oldValvola = selectedValvola {
                valvolaSelectionChanged?(oldValvola, false)
            }
        }
        didSet {
            if let valvolaJustSelected = selectedValvola {
                valvolaSelectionChanged?(valvolaJustSelected, true)
            }
            if let observingValvola = selectedValvola?.valvolaModel as? ObservingObject {
                self.selectedListenerObject = observingValvola
            } else {
                self.selectedListenerObject = nil
            }
        }
    }
    
    @Published var firstSelectedIO: GraphicalIO? = nil {
        willSet {
            if let oldIO = firstSelectedIO {
                ioSelectionChanged?(oldIO, false)
            }
        }
        didSet {
            if let ioJustSelected = firstSelectedIO {
                ioSelectionChanged?(ioJustSelected, true)
            }
        }
    }
    
    @Published var secondSelectedIO: GraphicalIO? = nil {
        willSet {
            if let oldIO = secondSelectedIO {
                ioSelectionChanged?(oldIO, false)
            }
        }
        didSet {
            if let ioJustSelected = secondSelectedIO {
                ioSelectionChanged?(ioJustSelected, true)
            }
        }
    }
    
    
    @Published var isDragging: Bool = false
    @Published var hasToSelectMovableObjects: Bool = false
    @Published var selectedListenerObject: ObservingObject? = nil
    
    var valvolaCreationCompletion: ((UIValvola) -> Void)? = nil
    var valvolaSelectionChanged: ((UIValvola, Bool) -> Void)? = nil
    var ioSelectionChanged: ((GraphicalIO, Bool) -> Void)? = nil
    
    public func createInstanceOf(type: ValvoleTypes) {
        switch type {
        case .and:
            let object = IPAnd(name: "AND")
            object.postInit()
            
            let node = DXPneumatic.ValvolaAnd(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .or:
            let object = IPOr(name: "OR")
            object.postInit()
            
            let node = DXPneumatic.ValvolaOR(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .frl:
            let object = IPFrl(name: "FRL")
            object.postInit()
            
            let node = DXPneumatic.GruppoFRL(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .cde:
            let object = IPCilindroDE(name: "CDE")
            object.postInit()
            
            let node = DXPneumatic.CilindroDoppioEffetto(model: object, size: .init(width: 200, height: 50))
            valvolaCreationCompletion?(node)
        case .treDueMS:
            let object = IPTreDueMS(name: "3/2 MS")
            object.postInit()
            
            let node = DXPneumatic.TreDueMonostabileNC(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .treDueBS:
            let object = IPTreDueBS(name: "3/2 BS")
            object.postInit()
            
            let node = DXPneumatic.TreDueBistabile(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .timer:
            let object = IPTimer(name: "Timer")
            object.postInit()
            
            let node = DXPneumatic.SpriteTimer(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .cinqueDueMS:
            let object = IPCinqueDueMS(name: "5/2 MS")
            object.postInit()
            
            let node = DXPneumatic.CinqueDueMonostabile(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .cinqueDueBS:
            let object = IPCinqueDueBS(name: "5/2 BS")
            object.postInit()
            
            let node = DXPneumatic.CinqueDueBistabile(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .pulsante:
            let object = IPPulsante(name: "Pulsante")
            object.postInit()
            
            let node = DXPneumatic.Pulsante(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        case .finecorsa:
            let object = IPFinecorsa(name: "Finecorsa")
            object.postInit()
            
            let node = DXPneumatic.Finecorsa(model: object, size: .init(width: 100, height: 50))
            valvolaCreationCompletion?(node)
        }
    }
    
}

enum ValvoleTypes: CaseIterable, CustomStringConvertible {
    case and
    case or
    case frl
    case cde
    case treDueMS
    case treDueBS
    case timer
    case cinqueDueMS
    case cinqueDueBS
    case pulsante
    case finecorsa
    
    static func type(at index: Int) -> ValvoleTypes {
        return ValvoleTypes.allCases[index]
    }
    
    var description: String {
        switch self {
        case .and:
            return "AND"
        case .or:
            return "OR"
        case .frl:
            return "FRL"
        case .cde:
            return "Cilindro DE"
        case .treDueMS:
            return "3/2 Monostabile"
        case .treDueBS:
            return "3/2 Bistabile"
        case .timer:
            return "Timer"
        case .cinqueDueMS:
            return "5/2 Monostabile"
        case .cinqueDueBS:
            return "5/2 Bistabile"
        case .pulsante:
            return "Pulsante"
        case .finecorsa:
            return "Finecorsa"
        }
    }
}
