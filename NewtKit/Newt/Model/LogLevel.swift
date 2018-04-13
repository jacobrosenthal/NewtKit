//
//  LogLevel.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation

public enum LogLevel: Int, Codable {
    case debug = 0
    case info = 1
    case warn = 2
    case error = 3
    case critical = 4
}
