//
//  LogModuleListOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 17/03/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias LogModuleListResultClosure = ((Result<[LogModule], NewtError>) -> Void)

class LogModuleListOperation: NewtOperation {
    private var resultClosure: LogModuleListResultClosure?
    
    init(newtService: NewtService, result: LogModuleListResultClosure?) {
        self.resultClosure = result
        
        super.init(newtService: newtService)
        
        self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.logs, seq: 0, id: NMGRLogsCommand.moduleList.rawValue, data: Data())
    }
    
    override func main() {
        super.main()
        
        sendPacket()
    }
    
    override func didReceive(packet: Packet) {
        if let cbor = packet.cborFromData(), let modulesDict = cbor["module_map"]?.dictionaryValue {
            let modules: [LogModule] = modulesDict.flatMap {
                guard let id = $0.value.int, let name = $0.key.string else { return nil }
                return LogModule(id: id, name: name)
            }
            resultClosure?(.success(modules))
        } else {
            resultClosure?(.failure(.invalidCbor))
        }
        
        executing(false)
        finish(true)
    }
}

