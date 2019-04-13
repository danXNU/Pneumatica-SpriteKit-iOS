//
//  ObjectsListDataSource.swift
//  Pneumatica-SpriteKit-iOS
//
//  Created by Daniel Fortesque on 10/04/2019.
//  Copyright © 2019 Dani Tox. All rights reserved.
//

import UIKit
import SpriteKit

class ObjectsListDataSource : NSObject, UITableViewDataSource {
    
    var objects: [Line] = []
    
    init(objects: [Line]) {
        self.objects = objects
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let object = self.objects[indexPath.row]
        cell.textLabel?.text = "\(String(describing: object.fromInput.name)) --> \(String(describing: object.toOutput.name))"
        return cell
    }
    
}
