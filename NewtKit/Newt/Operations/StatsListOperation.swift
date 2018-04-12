//
//  StatsListOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 12/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CBOR
import Result

public typealias StatsListResultClosure = ((Result<[String], NewtError>) -> Void)

class StatsListOperation: NewtOperation {
    
    private var resultClosure: StatsListResultClosure?
    
    init(newtService: NewtService, result: StatsListResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.stats, seq: 0, id: NMGRStatsCommand.list.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
//        if let cbor = packet.cborFromData(), let statsArray = cbor["stat_list"]?.arrayValue {
//            let stats = statsArray.compactMap { $0.string }
//            resultClosure?(.success(stats))
//        } else {
//            resultClosure?(.failure(.invalidCbor))
//        }
        
        if let cbor = packet.cborFromData(), case let CBOR.array(statsArray)? = cbor["stat_list"] {
            let stats: [String] = statsArray.compactMap {
                if case let CBOR.utf8String(stat) = $0 {
                    return stat
                }
                return nil
            }
            resultClosure?(.success(stats))
        } else {
            resultClosure?(.failure(.invalidCbor))
        }
        
        executing(false)
        finish(true)
    }
}
