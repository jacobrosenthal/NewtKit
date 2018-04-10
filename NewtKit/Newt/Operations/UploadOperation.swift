//
//  UploadOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 14/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR
import Result

public typealias UploadProgressClosure = ((_ progress: Double) -> Bool)
public typealias UploadResultClosure = ((Result<Void, NewtError>) -> Void)

class UploadOperation: NewtOperation {
	private var progressClosure: UploadProgressClosure?
	private var resultClosure: UploadResultClosure?
	
	var data: Data
	
	init(newtService: NewtService, data: Data, progress: UploadProgressClosure?, result: UploadResultClosure?) {
        print("UploadOperation.init")
		self.data = data
		self.progressClosure = progress
		self.resultClosure = result
		
		super.init(newtService: newtService)
	}
	
	override func main() {
		super.main()
        
        print("UploadOperation.main")

		// create and send 1st
		if let packet = nextPacket(data: data, offset: 0) {
			print("upload first packet sent")
			newtService?.transport?.newtService(newtService!, write: packet.serialized())
        } else {
            print("UploadOperation can't get 1st packet")
        }
	}
	
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			print(cbor)
			
			if let nextOffset = cbor["off"]?.int {
				print("upload next packet")
				
				let progress = Double(nextOffset) / Double(data.count)
				let shouldContinue = progressClosure?(progress) ?? true
				
				if let packet = nextPacket(data: data, offset: nextOffset), shouldContinue {
					newtService?.transport?.newtService(newtService!, write: packet.serialized())
				} else {
					resultClosure?(.success(()))
					
					finish()
				}
			}
		}
	}
	
	let kFragmentMaxSize = 80
	func nextPacket(data: Data, offset: Int) -> Packet? {
		guard offset < data.count else { return nil }
		
		let upperLimit = min(offset+kFragmentMaxSize, data.count)
		let subData = data.subdata(in: offset..<upperLimit)

		var cbor: CBOR
		if offset == 0 {
			cbor = CBOR(dictionaryLiteral: ("off", CBOR(integerLiteral: offset)),
							("data", CBOR(byteString: Array<UInt8>(subData))),
							("len", CBOR(integerLiteral: data.count))
			)
		} else {
			cbor = CBOR(dictionaryLiteral: ("off", CBOR(integerLiteral: offset)),
							("data", CBOR(byteString: Array<UInt8>(subData)))
			)
		}
		
//		if offset == 0 {
//			cbor["len"] = CBOR(integerLiteral: data.count)
//		}
		
		let cborData = Data(cbor.encode())
		
		return Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.upload.rawValue, data: cborData)
	}
}
















