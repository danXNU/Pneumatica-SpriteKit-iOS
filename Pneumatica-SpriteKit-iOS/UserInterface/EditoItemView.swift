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
            Text("\(itemManager.variableName.propertyName)")
            
            if itemManager.type == .string {
                TextField(itemManager.variableName.propertyName, text: $itemManager.stringValue)
            } else if itemManager.type == .int {
                HStack {
                    Stepper("\(itemManager.intValue)", value: $itemManager.intValue)
                }
            } else if itemManager.type == .double {
                HStack {
                    Stepper(onIncrement: { self.itemManager.doubleValue += 0.1 }, onDecrement: { self.itemManager.doubleValue -= 0.1 }) {
                        Text(String(format: "%.1f", Float(itemManager.doubleValue)))
                    }
                }
            } else if itemManager.type == .movableObject {
                VStack(spacing: 20) {
                    Text(String(describing: itemManager.variable.getTypedValue(MovableObject.self)?.name))
                    Button(action: { self.itemManager.genericAgent.hasToSelectMovableObjects.toggle() }, label: {
                        Text(self.itemManager.genericAgent.hasToSelectMovableObjects ? "Annulla" : "Seleziona")
                    })
                }
            }
        }
    }
}


class EditorItemManager: ObservableObject {
    var genericAgent: GenericAgent
    var variableName: VariablesKeys
    var variable: Variable
        
    @Published var stringValue: String = "" {
        didSet {
            if stringValue == "" { return }
            genericAgent.selectedValvola?.valvolaModel.set(value: .string(stringValue), toKey: variableName)
        }
    }
    
    @Published var intValue: Int = -1 {
        didSet {
            if intValue <= -1 { return }
            genericAgent.selectedValvola?.valvolaModel.set(value: .int(intValue), toKey: variableName)
        }
    }
    
    @Published var doubleValue: Double = -1 {
        didSet {
            if doubleValue <= -1 { return }
            genericAgent.selectedValvola?.valvolaModel.set(value: .double(doubleValue), toKey: variableName)
        }
    }
    
    var type: Variable.HolderType {
        return genericAgent.selectedValvola!.valvolaModel.get(variable: variableName).valueType
    }
    
    init(editorVariable: EditorVariable,  agent: GenericAgent) {
        self.variable = editorVariable.propertyValue
        self.genericAgent = agent
        self.variableName = editorVariable.propertyHeader
        
        switch type {
        case .int: intValue = variable.getTypedValue(Int.self) ?? 0
        case .string: stringValue = variable.getTypedValue(String.self) ?? ""
        case .double: doubleValue = variable.getTypedValue(Double.self) ?? 0.0
        default:
            print("Gang SHIIIT")
//            fatalError()
        }
    }
    
}
