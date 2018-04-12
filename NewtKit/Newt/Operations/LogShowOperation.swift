//
//  LogShowOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CBOR
import Result

public typealias LogShowResultClosure = ((Result<Void, NewtError>) -> Void)

class LogShowOperation: NewtOperation {
    private var resultClosure: LogShowResultClosure?
    
    init(newtService: NewtService, logName: String = "", min: Int = 0, timestamp: Int = 0, result: LogShowResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        let cbor = CBOR(dictionaryLiteral: ("log_name", CBOR(stringLiteral: logName)), ("index", CBOR(integerLiteral: min)), ("ts", CBOR(integerLiteral: timestamp)))
        let cborData = Data(cbor.encode())
        
        self.packet = Packet(op: .read, flags: 0, length: cborData.count, group: NMGRGroup.logs, seq: 0, id: NMGRLogsCommand.read.rawValue, data: cborData)
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData() {
            print("_________ log")
            print(cbor)
            print("^^^^^^^^^ log")
        } else {
            resultClosure?(.failure(.invalidCbor))
        }
        
        executing(false)
        finish(true)
    }
}

