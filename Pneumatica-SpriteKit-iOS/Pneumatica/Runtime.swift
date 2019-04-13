//
//  Runtime.swift
//  Pneumatica
//
//  Created by Dani Tox on 02/04/2019.
//

import Foundation

class PneumaticaRuntime {
    
    private init() {}
    static let shared = PneumaticaRuntime()
    
//    func sendAria(to inputs: Set<InputOutput>, from output: InputOutput) {
//        output.fillColor = .green
//        inputs.forEach { $0.receive(from: output) }
//        //updateStates(of: inputs) non utilizzare perchè si userà spritekit update() method
//    }
//
//    func stopSendingAria(to inputs: Set<InputOutput>, from output: InputOutput) {
//        output.fillColor = output.idleColor
//        inputs.forEach { $0.stopReceiving(from: output) }
//        //updateStates(of: inputs) non utilizzare perchè si userà spritekit update() method
//    }
    
//    func updateStates(of inputs: Set<InputOutput>) {
//        inputs.forEach { $0.parentValvola?.update() }
//    }
    
    func start() {
        
    }
}
