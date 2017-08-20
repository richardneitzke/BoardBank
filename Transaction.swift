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
    var payee = String()
    var payeeIndex = 0
    var payer = String()
    var payerIndex = 0
    
    init(amount: Int, payee: String, payeeIndex: Int, payer: String, payerIndex: Int) {
        
        self.amount = amount
        self.payee = payee
        self.payeeIndex = payeeIndex
        self.payer = payer
        self.payerIndex = payerIndex
    }

}
