//
//  Transaction.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/16/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    
    var amount = 0
    var payee: String
    var payeeIndex = 0
    var payeeId: String
    var payer: String
    var payerIndex = 0
    var payerId: String
    
    init(amount: Int, payee: String, payeeIndex: Int, payeeId: String, payer: String, payerIndex: Int, payerId: String) {
        
        self.amount = amount
        self.payee = payee
        self.payeeIndex = payeeIndex
        self.payeeId = payeeId
        self.payer = payer
        self.payerIndex = payerIndex
        self.payerId = payerId
    }

}
