//
//  StatsOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias StatsResultClosure = ((Result<[Stat], NewtError>) -> Void)

class StatsOperation: NewtOperation {
    
    private var resultClosure: StatsResultClosure?
    
    init(newtService: NewtService, name: String, result: StatsResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        let cbor = CBOR(dictionaryLiteral: ("name", CBOR(stringLiteral: name)))
        let cborData = Data(cbor.encode())
        
        self.packet = Packet(op: .read, flags: 0, length: cborData.count, group: NMGRGroup.stats, seq: 0, id: NMGRStatsCommand.read.rawValue, data: cborData)
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData(), let statsDict = cbor["fields"]?.dictionaryValue {
            let stats: [Stat] = statsDict.compactMap {
                if  let name = $0.key.string,
                    let value = $0.value.int {
                    
                    return Stat(name: name, value: value)
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
