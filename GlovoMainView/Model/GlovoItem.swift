//
//  GlovoItem.swift
//  GlovoMainView
//
//  Created by Akyl Temirgaliyev on 09.03.2024.
//

import Foundation
import UIKit

struct GlovoItem {
	var image: UIImage
	var text: String
	var subItems: [GlovoItem]?
	var controller: UIViewController.Type?
}
