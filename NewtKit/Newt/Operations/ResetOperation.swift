//
//  ResetOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 13/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias ResetResultClosure = ((Result<Void, NewtError>) -> Void)

class ResetOperation: NewtOperation {
	private var resultClosure: ResetResultClosure?
	
	init(newtService: NewtService, result: ResetResultClosure?) {
        print("ResetOperation.init")
		self.resultClosure = result
		
		super.init(newtService: newtService)
		
		self.packet = Packet(op: .write, flags: 0, length: 0, group: NMGRGroup.default, seq: 0, id: NMGRCommand.reset.rawValue, data: Data())
	}
	
	override func main() {
		super.main()
        
        print("ResetOperation.main")
		
		sendPacket()
	}
	
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			if let responseCode = responseCode(inCBOR: cbor) {
				if responseCode == .ok {
					resultClosure?(.success(()))
				} else {
					resultClosure?(.failure(responseCode))
				}
			}
		} else {
			resultClosure?(.failure(.invalidCbor))
		}
		
		executing(false)
		finish(true)
	}
}
