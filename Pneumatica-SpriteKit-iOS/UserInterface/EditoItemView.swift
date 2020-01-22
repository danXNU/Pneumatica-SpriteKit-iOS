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
    var editorVariable: EditorVariable<BaseValvola>
    @EnvironmentObject var genericAgent: GenericAgent
    
    var body: some View {
        VStack {
            Text("\(editorVariable.headerName)")
            
            
        }
    }
}


class EditorItemManager<T>: ObservableObject {
    var genericAgent: GenericAgent
    var variable: EditorVariable<BaseValvola>
    
    @Published var value: GenericVariable {
        didSet {
            genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].value = value
        }
    }
    
    var type: Variable.HolderType {
        return genericAgent.selectedValvola?.valvolaModel[keyPath: variable.path].valueType ?? .string
    }
    
    init(editorVariable: EditorVariable<BaseValvola>, agent: GenericAgent) {
        self.variable = editorVariable
        self.genericAgent = agent
        self.value = agent.selectedValvola!.valvolaModel[keyPath: variable.path].value
    }
    
}
