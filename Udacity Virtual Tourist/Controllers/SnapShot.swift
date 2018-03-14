//
//  SnapShot.swift
//  Udacity Virtual Tourist
//
//  Created by Filipe Merli on 13/03/2018.
//  Copyright © 2018 Filipe Merli. All rights reserved.
//

import Foundation
import UIKit

class SnapShot {
    
    var snapShot: UIImage?
    var currentPinLat: Double?
    var currentPinLong: Double?
    
    class var shared: SnapShot {
        struct Static {
            static let instance: SnapShot = SnapShot()
        }
        return Static.instance
    }
    
}
