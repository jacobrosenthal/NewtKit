//
//  CBOR+Foundation.swift
//  SwiftCBOR
//
//  Created by Luís Silva on 13/02/2018.
//  Copyright © 2018 unrelenting.technology. All rights reserved.
//

import Foundation

extension CBOR {
	public init(array elements: [CBOR]) {
		self = .array(elements)
	}
	
	public init(dictionary: [CBOR : CBOR]) {
		self = .map(dictionary)
	}
	
	public init(dictionary elements: [(CBOR, CBOR)]) {
		var result = [CBOR : CBOR]()
		for (key, value) in elements {
			result[key] = value
		}
		self = .map(result)
	}
}

extension CBOR: RawRepresentable {
	public init?(rawValue: Any) {
		var result: CBOR?
		
		switch rawValue {
		case nil:
			result = CBOR(nilLiteral: ())
			
		case let value as Int:
			result = CBOR(integerLiteral: value)
			
		case let value as String:
			result = CBOR(unicodeScalarLiteral: value)
			
		case let value as [Any]:
			let cborConversionArray = value.map({ CBOR(rawValue: $0) })
			let isValid = cborConversionArray.first(where: {$0 == nil}) == nil          // Check if there is any nil values (failed conversion)
			if isValid {
				let cborArray = cborConversionArray.map({$0!})          // Convert from CBOR? to CBOR
				result = CBOR(array: cborArray)
			}
			
		case let value as [String: Any]:
			result = CBOR(dictionary: value)
			
		case let data as Data:
			result = CBOR(data: data)
			
		case let bool as Bool:
			result = CBOR(booleanLiteral: bool)
			
		case is NSNull:
			result = CBOR(nilLiteral:())
			
		default:
			print("CBOR Init: unrecognized type")
			break
		}
		
		if let result = result {
			self = result
		}
		else {
			return nil
		}
	}
	
	
	public var rawValue: Any {
		return self
	}
	
	init?(dictionary: Dictionary<String, Any>) {
		
		var itemsArray: [(CBOR, CBOR)] = []
		for (key, value) in dictionary {
			
			guard let valueCbor = CBOR(rawValue: value) else {
				return nil
			}
			
			let keyCbor = CBOR(unicodeScalarLiteral: key)
			itemsArray.append((keyCbor, valueCbor))
		}
		
		self = CBOR(dictionary: itemsArray)
	}
	
	init(data: Data) {
		let bytes = [UInt8](data)
		self = CBOR(byteString: bytes)
	}
}

// MARK: - CustomStringConvertible

extension CBOR: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .unsignedInt(value): return String(value)
		case let .negativeInt(value): return String(-Int(value+1))
		case let .byteString(bytes): return bytes.map { String(format: "%02x", $0) }.joined()
		case let .utf8String(text): return "\"\(text)\""
		case let .array(array):
			return "[" + array.reduce("", { $0 + "\($1)\($1 != array.last ? ", ":"")" }) + "]"
		case let .map(dictionary):
			let array = dictionary.map({"\($0.key): \($0.value)"})
			return "{\(array.joined(separator: ", "))}"
		case let .tagged(tagId, cbor): return "TAG_\(tagId):\(cbor)"
		case let .simple(value): return String(value)
		case let .boolean(value): return value ? "true":"false"
		case .null: return "null"
		case .undefined: return "undefined"
		case let .half(value): return String(value)
		case let .float(value): return String(value)
		case let .double(value): return String(value)
			
		default:
			return ""
		}
	}
}

// MARK: - Bool

extension CBOR { // : Swift.Bool
	
	//Optional bool
	public var bool: Bool? {
		switch self {
		case let .boolean(value): return value
		default:
			return nil
		}
	}
	
	//Non-optional bool
	public var boolValue: Bool {
		switch self {
		case let .unsignedInt(value): return value == 1
		case let .negativeInt(value): return -Int(value+1) == 1
		case let .boolean(value): return value
		case let .simple(value): return value == 1
		case let .utf8String(text): return ["true", "y", "t"].contains() { (truthyString) in
			return text.caseInsensitiveCompare(truthyString) == .orderedSame
			}
		case .null: return false
		case .undefined: return false
		case let .half(value): return value == 1
		case let .float(value): return value == 1
		case let .double(value): return value == 1
			
		default:
			return false
		}
	}
}

// MARK: - String

extension CBOR {
	
	//Optional string
	public var string: String? {
		switch self {
		case let .utf8String(value): return value
		default: return nil
		}
	}
	
	//Non-optional string
	public var stringValue: String {
		return string ?? ""
	}
}

// MARK: - ByteString, Data

extension CBOR {
	
	// Optional bytes
	public var byteString: [UInt8]? {
		switch self {
		case let .byteString(value): return value
		default: return nil
		}
	}
	
	// Non-optional bytes
	public var byteStringValue: [UInt8] {
		return byteString ?? [UInt8]()
	}
	
	// Optional data
	public var data: Data? {
		switch self {
		case let .byteString(value): return Data(value)
		default:  return nil
		}
	}
	
	// Non-Optional data
	public var dataValue: Data {
		return data ?? Data()
	}
}


// MARK: - Int, Double, Float, Int8, Int16, Int32, Int64
extension CBOR {
	
	public var int: Int? {
		switch self {
		case let .unsignedInt(value): return Int(value)
		case let .negativeInt(value): return -Int(value+1)
		default:
			return nil
		}
	}
	
	public var intValue: Int {
		return int ?? 0
	}
	
	public var uInt: UInt? {
		switch self {
		case let .unsignedInt(value): return value
		default:
			return nil
		}
	}
	
	public var uIntValue: UInt {
		return uInt ?? 0
	}
	
	public var int8: Int8? {
		return int != nil ? Int8(int!):nil
	}
	
	public var int8Value: Int8 {
		return int8 ?? 0
	}
	
	public var uInt8: UInt8? {
		return int != nil ? UInt8(int!):nil
	}
	
	public var uInt8Value: UInt8 {
		return uInt8 ?? 0
	}
	
	public var int16: Int16? {
		return int != nil ? Int16(int!):nil
	}
	
	public var int16Value: Int16 {
		return int16 ?? 0
	}
	
	public var uInt16: UInt16? {
		return int != nil ? UInt16(int!):nil
	}
	
	public var uInt16Value: UInt16 {
		return uInt16 ?? 0
	}
	
	public var int32: Int32? {
		return int != nil ? Int32(int!):nil
	}
	
	public var int32Value: Int32 {
		return int32 ?? 0
	}
	
	public var uInt32: UInt32? {
		return int != nil ? UInt32(int!):nil
	}
	
	public var uInt32Value: UInt32 {
		return uInt32 ?? 0
	}
}


// MARK: - Array

extension CBOR {
	// Optional [CBOR]
	public var array: [CBOR]? {
		switch self {
		case let .array(rawArray): return rawArray
		default: return nil
		}
	}
	
	// Non-optional [CBOR]
	public var arrayValue: [CBOR] {
		return array ?? []
	}
	
}

// MARK: - Dictionary
extension CBOR {
	
	// Optional [String : CBOR]
	public var dictionary: [CBOR : CBOR]? {
		switch self {
		case let .map(rawDictionary):
			var d = [CBOR : CBOR](minimumCapacity: rawDictionary.count)
			for (key, value) in rawDictionary {
				d[key] = CBOR(cbor: value)
			}
			return d
		default:
			return nil
		}
		
	}
	
	// Non-optional [String : CBOR]
	public var dictionaryValue: [CBOR : CBOR] {
		return dictionary ?? [:]
	}
	
	// Optional [String : Any]
	public var dictionaryObject: [CBOR : CBOR]? {
		get {
			switch self {
			case let .map(rawDictionary):
				return rawDictionary
			default:
				return nil
			}
		}
	}
}
