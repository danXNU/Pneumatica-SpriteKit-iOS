//
//  SceneViewUI.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 18/01/2020.
//  Copyright © 2020 Dani Tox. All rights reserved.
//

import SwiftUI

struct SceneViewUI: View, UIViewControllerRepresentable {
    
    var genericAgent: GenericAgent
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SceneViewUI>) -> GameViewController {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(identifier: "gameVC") as? GameViewController else { fatalError() }
        let vc = GameViewController()
        vc.genericAgent = genericAgent
        return vc
    }
    
    func updateUIViewController(_ uiViewController: GameViewController, context: UIViewControllerRepresentableContext<SceneViewUI>) {
        
    }
}

struct SceneViewUI_Previews: PreviewProvider {
    static var previews: some View {
        SceneViewUI(genericAgent: GenericAgent())
    }
}
