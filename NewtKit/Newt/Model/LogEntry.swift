//
//  LogEntry.swift
//  NewtKit
//
//  Created by Luís Silva on 17/04/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation

public struct LogEntry: Codable {
    public let index: UInt
    public let timestamp: UInt
    public let module: UInt
    public let level: LogLevel
    public let message: String
}
