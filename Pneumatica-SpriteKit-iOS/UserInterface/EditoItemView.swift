//
//  EditoItemView.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 22/01/2020.
//  Copyright © 2020 Dani Tox. All rights reserved.
//

import SwiftUI
import DXPneumatic

struct EditoItemView: View {
    @ObservedObject var itemManager: EditorItemManager
    
    var body: some View {
        VStack {
            Text("\(itemManager.variable.headerName)")
            
            if itemManager.type == .string {
                TextField(itemManager.variable.headerName, text: $itemManager.stringValue)
            } else if itemManager.type == .int {
                HStack {
                    Text("\(itemManager.doubleValue)")
                    Stepper(itemManager.variable.headerName, value: $itemManager.intValue)
                }
            } else if itemManager.type == .double {
                HStack {
                    Text("\(itemManager.doubleValue)")
                    Stepper(itemManager.variable.headerName, onIncrement: { self.itemManager.doubleValue += 0.1 }, onDecrement: { self.itemManager.doubleValue -= 0.1 })
                }
            }
        }
    }
}


class EditorItemManager: ObservableObject {
    var genericAgent: GenericAgent
    var variable: EditorVariable<BaseValvola>
    
    @Published var value: GenericVariable {
        didSet {
            genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].value = value
        }
    }
    
    @Published var stringValue: String = "" {
        didSet {
            if stringValue == "" { return }
            genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].value = GenericVariable.string(stringValue)
        }
    }
    
    @Published var intValue: Int = -1 {
        didSet {
            if intValue <= -1 { return }
            genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].value = GenericVariable.int(intValue)
        }
    }
    
    @Published var doubleValue: Double = -1 {
        didSet {
            if doubleValue <= -1 { return }
            genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].value = GenericVariable.double(doubleValue)
        }
    }
    
    var type: Variable.HolderType {
        return genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].valueType ?? .string
    }
    
    init(editorVariable: EditorVariable<BaseValvola>, agent: GenericAgent) {
        self.variable = editorVariable
        self.genericAgent = agent
        self.value = agent.selectedValvola!.valvolaModel[keyPath: variable.path].value
        
        switch type {
        case .int: intValue = genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].getTypedValue(Int.self) ?? 0
        case .string: stringValue = genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].getTypedValue(String.self) ?? ""
        case .double: doubleValue = genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].getTypedValue(Double.self) ?? 0.0
        default:
            print("Gang SHIIIT")
            fatalError()
        }
    }
    
}
