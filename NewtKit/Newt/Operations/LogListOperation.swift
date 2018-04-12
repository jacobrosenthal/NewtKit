//
//  LogListOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CBOR
import Result

public typealias LogListResultClosure = ((Result<[String], NewtError>) -> Void)

class LogListOperation: NewtOperation {
    private var resultClosure: LogListResultClosure?
    
    init(newtService: NewtService, result: LogListResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.logs, seq: 0, id: NMGRLogsCommand.logsList.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
//        if let cbor = packet.cborFromData(), let logsArray = cbor["log_list"]?.arrayValue {
//            let logs: [String] = logsArray.compactMap { return $0.string }
//            resultClosure?(.success(logs))
//        } else {
//            resultClosure?(.failure(.invalidCbor))
//        }
        
        if let cbor = packet.cborFromData(), case let CBOR.array(logsArray)? = cbor["log_list"] {
            let logs: [String] = logsArray.compactMap {
                if case let CBOR.utf8String(name) = $0 {
                    return name
                }
                return nil
            }
            resultClosure?(.success(logs))
        } else {
            resultClosure?(.failure(.invalidCbor))
        }
        
        executing(false)
        finish(true)
    }
}

