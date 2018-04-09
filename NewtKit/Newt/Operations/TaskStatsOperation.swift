//
//  TaskStatsOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias TastStatsResultClosure = ((Result<[TaskStat], NewtError>) -> Void)

class TaskStatsOperation: NewtOperation {
    
    private var resultClosure: TastStatsResultClosure?
    
    init(newtService: NewtService, result: TastStatsResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.default, seq: 0, id: NMGRCommand.taskStats.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData(), let taskStatsDict = cbor["tasks"]?.dictionaryValue {
            let taskStats: [TaskStat] = taskStatsDict.compactMap {
                let key = $0.key
                let value = $0.value
                
                if  let name = key.string,
                    let state = value["state"]?.uIntValue,
                    let runTime = value["runtime"]?.uIntValue,
                    let priority = value["prio"]?.uIntValue,
                    let taskId = value["tid"]?.uIntValue,
                    let contextSwichCount = value["cswcnt"]?.uIntValue,
                    let stackUsed = value["stkuse"]?.uIntValue,
                    let stackSize = value["stksiz"]?.uIntValue,
                    let lastSanityCheckin = value["last_checkin"]?.uIntValue,
                    let nextSanityCheckin = value["next_checkin"]?.uIntValue {
                    
                    return TaskStat(taskId: taskId, name: name, priority: priority, state: state, runTime: runTime, contextSwichCount: contextSwichCount, stackSize: stackSize, stackUsed: stackUsed, lastSanityCheckin: lastSanityCheckin, nextSanityCheckin: nextSanityCheckin)
                    
                }
                return nil
            }
            resultClosure?(.success(taskStats))
        } else {
            resultClosure?(.failure(.parseError))
        }
        
        executing(false)
        finish(true)
    }
}

