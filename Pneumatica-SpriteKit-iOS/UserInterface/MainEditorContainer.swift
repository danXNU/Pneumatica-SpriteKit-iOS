//
//  MainEditorContainer.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/01/2020.
//  Copyright © 2020 Dani Tox. All rights reserved.
//

import SwiftUI

struct MainEditorContainer: View {
    
    @ObservedObject var genericAgent: GenericAgent = GenericAgent()
    
    var body: some View {
        GeometryReader { geo in
            HStack {
                if self.genericAgent.isShowingValvoleList {
                    List(ValvoleTypes.allCases, id: \.self) { type in
                        Text(type.description)
                            .onTapGesture {
                                self.genericAgent.createInstanceOf(type: type)
                            }
                    }
                    .frame(width: geo.size.width / 4)
                    
                }
                
                VStack {
                    ZStack {
                        Rectangle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(height: geo.size.height * 0.075)
                        .onTapGesture {
                            self.genericAgent.isShowingValvoleList.toggle()
                        }
                        
                        Text("Test")
                    }
                    
                    SceneViewUI(genericAgent: self.genericAgent)
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
