//
//  CreationObjectDataSource.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Dani Tox on 16/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import UIKit
import SpriteKit

class ObjectCreationDataSource : NSObject, UITableViewDataSource {
    
    var types: [ValvolaConformance.Type] = [
        ValvolaAnd.self,
        ValvolaOR.self,
        GruppoFRL.self,
        CilindroDoppioEffetto.self,
        TreDueMonostabileNC.self,
        SpriteTimer.self,
        CinqueDueBistabile.self,
        Pulsante.self,
        Finecorsa.self
    ]
    
    func createInstanceOf(index: Int) -> SKNode {
        let type = types[index]
        return type.init(size: type.preferredSize)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return types.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoldCell") as! BoldCell
        cell.mainLabel.text = types[indexPath.row].keyStringClass
        return cell
    }
    
}
