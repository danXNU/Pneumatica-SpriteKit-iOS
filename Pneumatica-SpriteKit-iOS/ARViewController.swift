//
//  ARViewController.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 29/05/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import UIKit
import ARKit
import SpriteKit

class ARViewController : UIViewController {
    
    var scnView: ARSCNView!
    var skScene: SKScene
    var isPositioningScene: Bool = true
    
    init(scene: SKScene) {
        self.skScene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene(named: "emptyScene.scn")!
        
        let scnView = ARSCNView(frame: view.frame)
        scnView.scene = scene
        scnView.isPlaying = true
        self.scnView = scnView
        
        view.addSubview(scnView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        scnView.session.run(configuration)
        
        scnView.session.delegate = self
        scnView.delegate = self
        
        UIApplication.shared.isIdleTimerDisabled = true
        scnView.showsStatistics = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scnView.session.pause()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isPositioningScene {
            
            guard let currentFrame = scnView.session.currentFrame else { return }
            
            let plane = SCNPlane(width: 3, height: 3)
            plane.firstMaterial?.diffuse.contents = self.skScene
            plane.firstMaterial?.lightingModel = .constant
            plane.firstMaterial?.isDoubleSided = true
            
            let planeNode = SCNNode(geometry: plane)
            scnView.scene.rootNode.addChildNode(planeNode)
            
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -1
            planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
            planeNode.eulerAngles.y = Float(180).degreesToRadians
            planeNode.eulerAngles.z = Float(180).degreesToRadians
            
            isPositioningScene = false
        }
    }
}

extension ARViewController: ARSessionDelegate, ARSCNViewDelegate {
    
}
