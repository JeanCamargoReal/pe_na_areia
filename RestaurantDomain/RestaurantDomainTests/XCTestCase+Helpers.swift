//
//  XCTestCase+Helpers.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 21/04/23.
//

import XCTest
import RestaurantDomain

extension XCTestCase {

	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "A instância deveria ter sido desalocada, possível vazamento de memória.", file: file, line: line)
		}
	}

	func makeItem() -> RestaurantItem {
		return RestaurantItem(id: UUID(), name: "name", location: "location", distance: 5.5, ratings: 0, parasols: 0)
	}
}



extension Date {
	func addind(days: Int) -> Date {
		return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
	}

	func addind(seconds: TimeInterval) -> Date {
		return self + seconds
	}
}

