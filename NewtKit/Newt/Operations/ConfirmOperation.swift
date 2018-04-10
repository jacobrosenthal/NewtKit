//
//  ConfirmOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 14/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias ConfirmResultClosure = ((Result<Void, NewtError>) -> Void)

class ConfirmOperation: NewtOperation {
	private var resultClosure: ConfirmResultClosure?
	
	init(newtService: NewtService, hash: Data? = nil, result: ConfirmResultClosure?) {
        print("ConfirmOperation.init")
		self.resultClosure = result
		
		super.init(newtService: newtService)
		
		let cbor = CBOR(dictionaryLiteral: ("confirm", true),
						("hash", hash != nil ? CBOR(byteString: Array<UInt8>(hash!)) : CBOR(nilLiteral: ()))
		)
		let cborData = Data(cbor.encode())
		self.packet = Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.state.rawValue, data: cborData)
	}
	
	override func main() {
		super.main()
        
        print("ConfirmOperation.main")
		
		sendPacket()
	}
	
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			print("CONFIRM \(cbor)")
			
			resultClosure?(.success(()))
		} else {
			resultClosure?(.failure(NewtError.invalidCbor))
		}
		
		executing(false)
		finish(true)
	}
}
