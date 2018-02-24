//
//  NewtService.swift
//  NewtKit
//
//  Created by Luís Silva on 12/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import CoreBluetooth
import Result

public protocol NewtServiceTransportProtocol: class {
	func newtService(_ newtService: NewtService, write data: Data)
}

public class NewtService {
	public static let NewtServiceUUID = CBUUID(string: "8D53DC1D-1DB7-4CD3-868B-8A527460AA84")
	public static let NewtCharacteristicUUID = CBUUID(string:"DA2E7828-FBCE-4E01-AE9E-261174997C48")
	
	public var operationQueue: OperationQueue
	public var timer: Timer?
	public var receivedData: Data!
	
	public weak var transport: NewtServiceTransportProtocol?
	
	public init() {
		operationQueue = OperationQueue()
		operationQueue.maxConcurrentOperationCount = 1
		operationQueue.name = "com.chippd.NewtKit.NewtService"
	}
	
	public func clearQueue() {
		(operationQueue.operations.first as? NewtOperation)?.finish()
		operationQueue.cancelAllOperations()
	}
	
	public func didReceive(data: Data) {
		guard let newtOperation = operationQueue.operations.first as? NewtOperation else {
			print("didReceive(data): no operation in queue")
			return
		}
		
		if receivedData == nil {
			receivedData = Data()
		}
		receivedData.append(data)
		
		guard let packet = Packet(data: receivedData) else {
			print("didReceive(data): couldn't parse packet")
			return
		}
		
		if receivedData.count == packet.length + Packet.kHeaderSize {
			newtOperation.didReceive(packet: packet)
			receivedData = nil
		}
	}
	
	func willStartOperation(_ operation: NewtOperation) {
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(operationDidTimeout(_:)), userInfo: operation, repeats: false)
	}
	
	func didEndOperation(_ operation: NewtOperation) {
		timer?.invalidate()
		timer = nil
	}
	
	@objc func operationDidTimeout(_ timer: Timer) {
		print("Operation timeout \(timer.userInfo.debugDescription)")
		(operationQueue.operations.first as? NewtOperation)?.didTimeout()
	}
	
	// MARK: - Requests
	
	public func reset(result: ResetResultClosure?) {
		operationQueue.addOperation(ResetOperation(newtService: self, result: result))
	}
	
	public func stats() {
		operationQueue.addOperation(StatsOperation(newtService: self))
	}
	
	public func imageList(result: ImageResultClosure?) {
		operationQueue.addOperation(ImageListOperation(newtService: self, result: result))
	}
	
	public func imageTest(hash: Data?, result: TestResultClosure?) {
		operationQueue.addOperation(TestOperation(newtService: self, hash: hash, result: result))
	}
	
	public func imageConfirm(hash: Data?, result: TestResultClosure?) {
		operationQueue.addOperation(ConfirmOperation(newtService: self, hash: hash, result: result))
	}
	
	public func erase(result: EraseResultClosure?) {
		operationQueue.addOperation(EraseOperation(newtService: self, result: result))
	}
	
	public func upload(data: Data, progress: UploadProgressClosure?, result: UploadResultClosure?) {
		operationQueue.addOperation(UploadOperation(newtService: self, data: data, progress: progress, result: result))
	}
}
