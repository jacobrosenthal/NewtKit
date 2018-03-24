//
//  TaskStat.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation

public struct TaskStat {
    public var taskId: UInt
    public var name: String
    public var priority: UInt
    public var state: UInt
    public var runTime: UInt
    public var contextSwichCount: UInt
    public var stackSize: UInt
    public var stackUsed: UInt
    public var lastSanityCheckin: UInt
    public var nextSanityCheckin: UInt
}
