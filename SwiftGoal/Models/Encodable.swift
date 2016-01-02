//
//  Encodable.swift
//  SwiftGoal
//
//  Created by Martin Richter on 01/01/16.
//  Copyright © 2016 Martin Richter. All rights reserved.
//

import Foundation

protocol Encodable {
    func encode() -> [String: AnyObject]
}