//
//  Transaction.swift
//  BoardBank
//
//  Created by Miguel Tepale on 8/16/17.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit

class Transaction: NSObject {
    
    var amount = Int()
    var payee = String()
    var payeeIndex = Int()
    var payer = String()
    var payerIndex = Int()
    
    init(amount: Int, payee: String, payeeIndex: Int, payer: String, payerIndex: Int) {
        
        self.amount = amount
        self.payee = payee
        self.payeeIndex = payeeIndex
        self.payer = payer
        self.payerIndex = payerIndex
    }

}
