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
	var userInfo = [AnyHashable: Any]()
	
	func input(isSecure: Bool) -> String {
		""
	}

	func output(_ text: ConsoleText, newLine: Bool) {
		self.lastOutput = text.description + (newLine ? "\n" : "")
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
		// averages from logger-fragment branch on my machine 0.547 0.551
		try performance(expected: 1.066) // average from main branch on my machine
		self.measure {
			let console = TestConsole()
			var logger1 = Logger(label: "codes.vapor.console.1") { label in
				ConsoleLogger(label: label, console: console)
			}
			
			for _ in 0..<100_000 {
				logger1.logLevel = .trace
				logger1[metadataKey: "value"] = "one"
				logger1.info("Info")
			}
		}
	}
}

func performance(expected seconds: Double, name: String = #function, file: StaticString = #filePath, line: UInt = #line) throws {
	try XCTSkipUnless(!_isDebugAssertConfiguration(), "[PERFORMANCE] Skipping \(name) in debug build mode", file: file, line: line)
	print("[PERFORMANCE] \(name) expected: \(seconds) seconds")
}
