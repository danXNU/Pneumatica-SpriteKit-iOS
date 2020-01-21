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


class ObjectCreationDataSource : NSObject, UITableViewDataSource {
        
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ValvoleTypes.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BoldCell") as! BoldCell
        cell.mainLabel.text = "\(ValvoleTypes.type(at: indexPath.row))"
        return cell
    }
    
}
