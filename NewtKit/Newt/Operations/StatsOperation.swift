//
//  StatsOperation.swift
//  NewtKit
//
//  Created by Luís Silva on 12/02/2018.
//  Copyright © 2018 Chipp'd. All rights reserved.
//

import Foundation
import SwiftCBOR

class StatsOperation: NewtOperation {
	
	override init(newtService: NewtService) {
		super.init(newtService: newtService)
		
		self.packet = Packet(op: .read, flags: 0, length: 0, group: NMGRGroup.stats, seq: 0, id: NMGRStatsCommand.list.rawValue, data: Data())
	}
	
	override func main() {
		super.main()
		
		sendPacket()
	}
	
	override func didReceive(packet: Packet) {
		if let cbor = packet.cborFromData() {
			
			let stats = cbor["stat_list"]?.arrayValue.map({$0.stringValue})
			
			print(cbor)
			print(stats ?? "")
		}
		
		executing(false)
		finish(true)
	}
}
