//
//  CircleView.swift
//  MonoBank
//
//  Created by Richard Neitzke on 03/01/2017.
//  Copyright © 2017 Richard Neitzke. All rights reserved.
//

import UIKit

class CircleView: UIView {

	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.cornerRadius = self.layer.bounds.width/2
	}

}
