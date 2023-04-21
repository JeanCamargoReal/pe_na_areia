//
//  XCTestCase+Helpers.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 21/04/23.
//

import XCTest

extension XCTestCase {

	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "A instância deveria ter sido desalocada, possível vazamento de memória.", file: file, line: line)
		}
	}
}

