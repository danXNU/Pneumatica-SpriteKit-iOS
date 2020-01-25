//
//  MainEditorContainer.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/01/2020.
//  Copyright © 2020 Dani Tox. All rights reserved.
//

import SwiftUI
import DXPneumatic

struct MainEditorContainer: View {
    
    @ObservedObject var genericAgent: GenericAgent = GenericAgent()
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(height: geo.size.height * 0.075)
                    
                    
                    HStack {
                        Image(systemName: self.genericAgent.isShowingValvoleList ? "chevron.left.square.fill" : "chevron.right.square.fill")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: 20)
                            .offset(x: 15, y: 0)
                            .onTapGesture {
                                self.genericAgent.isShowingValvoleList.toggle()
                        }
                        Spacer()
                        Text("Test")
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(1.0, contentMode: .fit)
                            .frame(height: 20)
                            .onTapGesture {
                                self.genericAgent.isShowingVariablesEditor.toggle()
                        }
                        .offset(x: -15, y: 0)
                    }
                    
                }
                HStack {
                    if self.genericAgent.isShowingValvoleList {
                        List(ValvoleTypes.allCases, id: \.self) { type in
                            Text(type.description)
                                .onTapGesture {
                                    self.genericAgent.createInstanceOf(type: type)
                            }
                        }
                        .frame(width: geo.size.width / 5)
                        
                    }
                    
                    SceneViewUI(genericAgent: self.genericAgent)
                    
                    if self.genericAgent.isShowingVariablesEditor {
                        if self.genericAgent.selectedValvola != nil {
//                            List(self.genericAgent.selectedValvola!.valvolaModel.editorItems, id: \.id) { item in
////                                VStack(spacing: 10) {
////                                    Text("\(item.headerName)")
////
////                                    Text("\(String(describing: self.genericAgent.selectedValvola!.valvolaModel[keyPath: item.path]))")
////                                }
//
////                                EditoItemView(itemManager: .init(editorVariable: item, agent: self.genericAgent))
//
//                            }
                            Text("Gang shiiit!")
                            .frame(width: geo.size.width / 5)
                        } else {
                            Text("Nessuna valvola selezionata")
                            .frame(width: geo.size.width / 5)
                        }
                    }
                }
                
            }
        }
    }
}

struct MainEditorContainer_Previews: PreviewProvider {
    static var previews: some View {
        MainEditorContainer()
    }
}
