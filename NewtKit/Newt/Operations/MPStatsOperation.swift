//
//  MPStatsOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CBOR
import Result

public typealias MPStatsResultClosure = ((Result<[MPStat], NewtError>) -> Void)

class MPStatsOperation: NewtOperation {
    
    private var resultClosure: MPStatsResultClosure?
    
    init(newtService: NewtService, result: MPStatsResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.default, seq: 0, id: NMGRCommand.mpStats.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData(), let mpStatsDict = cbor["mpools"]?.dictionaryValue {
            let mpStats: [MPStat] = mpStatsDict.compactMap {
                let key = $0.key
                let value = $0.value
                
                if  let name = key.string,
                    let blksz = value["blksiz"]?.intValue,
                    let cnt = value["nblks"]?.intValue,
                    let min = value["min"]?.intValue,
                    let free = value["nfree"]?.intValue {
                    
                    return MPStat(name: name, blksz: blksz, cnt: cnt, free: free, min: min)
                }
                return nil
            }
            resultClosure?(.success(mpStats))
        } else {
            resultClosure?(.failure(.parseError))
        }
        
        executing(false)
        finish(true)
    }
}
