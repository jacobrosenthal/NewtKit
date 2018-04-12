//
//  UploadOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 14/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CBOR
import Result

public typealias UploadProgressClosure = ((_ progress: Double) -> Bool)
public typealias UploadResultClosure = ((Result<Void, NewtError>) -> Void)

class UploadOperation: NewtOperation {
	private var progressClosure: UploadProgressClosure?
	private var resultClosure: UploadResultClosure?
	
	var data: Data
	
	init(newtService: NewtService, data: Data, progress: UploadProgressClosure?, result: UploadResultClosure?) {
		self.data = data
		self.progressClosure = progress
		self.resultClosure = result
		
		super.init(newtService: newtService)
	}
	
	override func main() {
		super.main()
        
		// create and send 1st
		if let packet = nextPacket(data: data, offset: 0) {
			print("upload first packet sent")
			newtService?.transport?.newtService(newtService!, write: packet.serialized())
        } else {
            print("UploadOperation can't get 1st packet")
        }
	}
	
    var currentOffset: UInt = 0
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			print(cbor)
			
//            if let nextOffset = cbor["off"]?.int {
//                currentOffset = nextOffset
//
//                print("upload next packet")
//
//                sendNextPacket(offset: nextOffset)
//            }

            if case let CBOR.unsignedInt(nextOffset)? = cbor["off"] {
                currentOffset = nextOffset
                
                print("upload next packet")
                
                sendNextPacket(offset: nextOffset)
            }
        }
        
        retries = 3
	}
    
    private func sendNextPacket(offset: UInt) {
        let progress = Double(offset) / Double(data.count)
        let shouldContinue = progressClosure?(progress) ?? true
        
        if let packet = nextPacket(data: data, offset: offset), shouldContinue {
            newtService?.transport?.newtService(newtService!, write: packet.serialized())
        } else {
            resultClosure?(.success(()))
            
            finish()
        }
    }
	
    let kFragmentMaxSize: UInt = 80
	func nextPacket(data: Data, offset: UInt) -> Packet? {
		guard offset < data.count else { return nil }
		
		let upperLimit = min(offset+kFragmentMaxSize, UInt(data.count))
		let subData = data.subdata(in: Int(offset)..<Int(upperLimit))
        
		var cbor: CBOR
		if offset == 0 {
			cbor = CBOR(dictionaryLiteral: ("off", CBOR(integerLiteral: Int(offset))),
							("data", CBOR.byteString(Array<UInt8>(subData))),
							("len", CBOR(integerLiteral: data.count))
			)
		} else {
			cbor = CBOR(dictionaryLiteral: ("off", CBOR(integerLiteral: Int(offset))),
							("data", CBOR.byteString(Array<UInt8>(subData)))
			)
		}
		
//		if offset == 0 {
//			cbor["len"] = CBOR(integerLiteral: data.count)
//		}
		
		let cborData = Data(cbor.encode())
		
		return Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.upload.rawValue, data: cborData)
	}
    
    override func transportDidConnect() {
        sendNextPacket(offset: currentOffset)
    }
    
    var retries = 3
    override func transportDidDisconnect() {
        retries -= 1
        
        if retries <= 0 {
            print("upload failed -> too many disconnects")
            resultClosure?(.failure(.unknown))
            
            finish(true)
        }
    }
}
















