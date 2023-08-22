//
//  ConsoleLoggerPerformanceTests.swift
//  
//
//  Created by Cole Kurkowski on 8/19/23.
//

import ConsoleKit
import Logging
import XCTest

final class TestConsole: Console {
	var lastOutput: String? = nil
	var userInfo = [AnyHashable: any Sendable]()
	
	func input(isSecure: Bool) -> String {
		""
	}

	func output(_ text: ConsoleText, newLine: Bool) {
		
	}

	func report(error: String, newLine: Bool) {
		//
	}

	func clear(_ type: ConsoleClear) {
		//
	}

	var size: (width: Int, height: Int) { return (0, 0) }
}

class ConsoleLoggerPerformanceTests: XCTestCase {
	func testLoggingPerformance() throws  {
		try performance(expected: 0.489) // average from main branch on my machine
		
		let console = TestConsole()
		LoggingSystem.bootstrap({ label, provider in
			ConsoleLogger(label: label, console: console)
		}, metadataProvider: .init({
			["provided1": "from metadata provider", "provided2": "another metadata provider"]
		}))
		
		self.measure {
			var logger1 = Logger(label: "codes.vapor.console.1")
			
			for _ in 0..<100_000 {
				logger1.logLevel = .trace
				logger1[metadataKey: "value"] = "one"
				logger1.info(
					"Info",
					metadata: ["from-log": "value", "also-from-log": "other"]
				)
			}
		}
	}
}

func performance(expected seconds: Double, name: String = #function, file: StaticString = #filePath, line: UInt = #line) throws {
	try XCTSkipUnless(!_isDebugAssertConfiguration(), "[PERFORMANCE] Skipping \(name) in debug build mode", file: file, line: line)
	print("[PERFORMANCE] \(name) expected: \(seconds) seconds")
}
