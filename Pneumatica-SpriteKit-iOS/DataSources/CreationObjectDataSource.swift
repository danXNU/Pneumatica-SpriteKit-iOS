//
//  CreationObjectDataSource.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 16/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import UIKit
import SpriteKit
import DXPneumatic


enum ValvoleTypes: CaseIterable {
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
}

class ObjectCreationDataSource : NSObject, UITableViewDataSource {
        
    func createInstanceOf(type: ValvoleTypes) -> UIValvola {
        switch type {
        case .and:
            let object = IPAnd(name: "AND")
            object.postInit()
            
            let node = DXPneumatic.ValvolaAnd(model: object, size: .init(width: 100, height: 50))
            return node
        case .or:
            let object = IPOr(name: "OR")
            object.postInit()
            
            let node = DXPneumatic.ValvolaOR(model: object, size: .init(width: 100, height: 50))
            return node
        case .frl:
            let object = IPFrl(name: "FRL")
            object.postInit()
            
            let node = DXPneumatic.GruppoFRL(model: object, size: .init(width: 100, height: 50))
            return node
        case .cde:
            let object = IPCilindroDE(name: "CDE")
            object.postInit()
            
            let node = DXPneumatic.CilindroDoppioEffetto(model: object, size: .init(width: 200, height: 50))
            return node
        case .treDueMS:
            let object = IPTreDueMS(name: "3/2 MS")
            object.postInit()
            
            let node = DXPneumatic.TreDueMonostabileNC(model: object, size: .init(width: 100, height: 50))
            return node
        case .treDueBS:
            let object = IPTreDueBS(name: "3/2 BS")
            object.postInit()
            
            let node = DXPneumatic.TreDueBistabile(model: object, size: .init(width: 100, height: 50))
            return node
        case .timer:
            let object = IPTimer(name: "Timer")
            object.postInit()
            
            let node = DXPneumatic.SpriteTimer(model: object, size: .init(width: 100, height: 50))
            return node
        case .cinqueDueMS:
            let object = IPCinqueDueMS(name: "5/2 MS")
            object.postInit()
            
            let node = DXPneumatic.CinqueDueMonostabile(model: object, size: .init(width: 100, height: 50))
            return node
        case .cinqueDueBS:
            let object = IPCinqueDueBS(name: "5/2 BS")
            object.postInit()
            
            let node = DXPneumatic.CinqueDueBistabile(model: object, size: .init(width: 100, height: 50))
            return node
        case .pulsante:
            let object = IPPulsante(name: "Pulsante")
            object.postInit()
            
            let node = DXPneumatic.Pulsante(model: object, size: .init(width: 100, height: 50))
            return node
        case .finecorsa:
            let object = IPFinecorsa(name: "Finecorsa")
            object.postInit()
            
            let node = DXPneumatic.Finecorsa(model: object, size: .init(width: 100, height: 50))
            return node
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ValvoleTypes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoldCell") as! BoldCell
//        cell.mainLabel.text = types[indexPath.row].keyStringClass
        return cell
    }
    
}
