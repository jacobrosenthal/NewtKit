//
//  Command.swift
//  NewtKit
//
//  Created by Luís Silva on 11/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR

struct Command {
	
	static func imageList() -> Packet {
		return Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.coreList.rawValue, data: Data())
	}

	static func upload(data: Data, offset: Int) -> Packet {
		let cbor: CBOR
		if offset == 0 {
			cbor = CBOR(dictionaryLiteral: ("off", 0),
						("len", CBOR(integerLiteral: data.count)),
						("data", CBOR.array(Array<UInt8>(data).map { CBOR(integerLiteral: Int($0)) }))
			)
		} else {
			cbor = CBOR(dictionaryLiteral: ("off", 0),
						("data", CBOR.array(Array<UInt8>(data).map { CBOR(integerLiteral: Int($0)) }))
			)
		}
		
		let encodedData = Data(cbor.encode())
		
		return Packet(op: .write, flags: 0, length: encodedData.count, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.upload.rawValue, data: encodedData)
	}
	
}
