//
//  NewtKitTests.swift
//  NewtKitTests
//
//  Created by Luís Silva on 11/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import XCTest
import SwiftCBOR
@testable import NewtKit

class NewtKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
	
	func testSerialization() {
		let newtService = NewtService()
		
		let hash = Data([0x41, 0x17, 0xdf, 0x7c, 0x1d, 0xc4, 0x0f, 0x54, 0xf3, 0xee, 0xbf, 0x85, 0x11, 0x73, 0xf9, 0x11, 0x41, 0xce, 0x6f, 0x92, 0x20, 0xfa, 0x1e, 0x83, 0xe2, 0x93, 0x62, 0x34, 0xd3, 0xa0, 0x5a, 0xca])
		
		let op = TestOperation(newtService: newtService, hash: hash) { (result) in
			switch result {
			case .success(_): XCTAssert(true)
			case .failure(_): XCTAssert(false)
			}
		}
		
		let expectedBytes: [UInt8] = [2, 0, 0, 49, 0, 1, 0, 0, 162, 100, 104, 97, 115, 104, 88, 32, 65, 23, 223, 124, 29, 196, 15, 84, 243, 238, 191, 133, 17, 115, 249, 17, 65, 206, 111, 146, 32, 250, 30, 131, 226, 147, 98, 52, 211, 160, 90, 202, 103, 99, 111, 110, 102, 105, 114, 109, 244]
		let actualBytes: [UInt8] = Array<UInt8>(op.packet.serialized())
		
		XCTAssert(expectedBytes == actualBytes)
	}
	
	func testSuccessfulResetOperation() {
		let newtService = NewtService()
		
		let cbor = CBOR(dictionaryLiteral: ("rc", 0))
		let cborData = Data(cbor.encode())
		let packet = Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.default, seq: 0, id: NMGRCommand.reset.rawValue, data: cborData)
		
		let op = ResetOperation(newtService: newtService) { (result) in
			switch result {
			case .success(_): XCTAssert(true)
			case .failure(_): XCTAssert(false)
			}
		}
		op.didReceive(packet: packet)
	}
	
	func testFailedResetOperation() {
		let newtService = NewtService()
		
		let cbor = CBOR(dictionaryLiteral: ("rc", 1))
		let cborData = Data(cbor.encode())
		let packet = Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.default, seq: 0, id: NMGRCommand.reset.rawValue, data: cborData)
		
		let op = ResetOperation(newtService: newtService) { (result) in
			switch result {
			case .success(_): XCTAssert(false)
			case .failure(_): XCTAssert(true)
			}
		}
		op.didReceive(packet: packet)
	}
	
	func testTestOperation() {
		let newtService = NewtService()
		
		let cbor = CBOR(dictionaryLiteral: ("rc", 0))
		let cborData = Data(cbor.encode())
		let packet = Packet(op: .write, flags: 0, length: cborData.count, group: NMGRGroup.image, seq: 0, id: NMGRImagesCommand.state.rawValue, data: cborData)
		
		let op = TestOperation(newtService: newtService, hash: nil) { (result) in
			switch result {
			case .success(_): XCTAssert(true)
			case .failure(_): XCTAssert(false)
			}
		}
		op.didReceive(packet: packet)
	}
	
}
