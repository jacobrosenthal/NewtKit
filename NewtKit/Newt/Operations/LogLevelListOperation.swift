//
//  LogLevelListOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias LogLevelListResultClosure = ((Result<[LogLevel], NewtError>) -> Void)

class LogLevelListOperation: NewtOperation {
    private var resultClosure: LogLevelListResultClosure?
    
    init(newtService: NewtService, result: LogLevelListResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.logs, seq: 0, id: NMGRLogsCommand.levelList.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData(), let levelsDict = cbor["level_map"]?.dictionaryValue {
            let logLevels: [LogLevel] = levelsDict.flatMap { return LogLevel(rawValue: $0.value.intValue) }
            resultClosure?(.success(logLevels))
        } else {
            resultClosure?(.failure(.invalidCbor))
        }
        
        executing(false)
        finish(true)
    }
}

