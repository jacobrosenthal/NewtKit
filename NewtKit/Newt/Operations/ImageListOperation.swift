//
//  ImageListOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 12/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias ImageResultClosure = ((Result<[Image], NewtError>) -> Void)

class ImageListOperation: NewtOperation {
	
	private var resultClosure: ImageResultClosure?
	
	init(newtService: NewtService, result: ImageResultClosure?) {
        print("ImageListOperation.init")
		self.resultClosure = result

		super.init(newtService: newtService)
		
		self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.state.rawValue, data: Data())
	}
	
	override func main() {
		super.main()
        
        print("ImageListOperation.main")
		
		sendPacket()
	}
	
	override func didReceive(packet: Packet) {
		defer {
			executing(false)
			finish(true)
		}
		
		if let cbor = packet.cborFromData() {
			var images: [Image] = []
			if let imagesCbor = cbor["images"]?.arrayValue {
				for imageCbor in imagesCbor {
					if let slot = imageCbor["slot"]?.intValue,
						let version = imageCbor["version"]?.stringValue,
						let confirmed = imageCbor["confirmed"]?.boolValue,
						let pending = imageCbor["pending"]?.boolValue,
						let active = imageCbor["active"]?.boolValue,
						let bootable = imageCbor["bootable"]?.boolValue,
						let hash = imageCbor["hash"]?.dataValue {
						
						let image = Image(slot: slot, version: version, isConfirmed: confirmed, isPending: pending, isActive: active, isBootable: bootable, hash: hash)
						images.append(image)
					}
				}
				
				resultClosure?(.success(images))
			} else {
				resultClosure?(.failure(.parseError))
			}
			print(cbor)
			print(images)
		} else {
			resultClosure?(.failure(.invalidCbor))
		}
	}
}
