//
//  LocalRestaurantLoaderForLoadCommandTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 05/05/23.
//

import XCTest
@testable import RestaurantDomain
final class LocalRestaurantLoaderForLoadCommandTests: XCTestCase {

	func test_load_returned_completion_error() {
		let (sut, cache) = makeSUT()

		assert(sut, completion: .failure(.invalidData)) {
			let anyError = NSError(domain: "any error", code: -1)
			cache.completionHandlerForLoad(.failure(anyError))
		}
	}

	func test_load_returned_completion_success_with_empy_data() {
		let (sut, cache) = makeSUT()

		assert(sut, completion: .success([])) {
			cache.completionHandlerForLoad(.empty)
		}
	}

	func test_load_returned_data_with_one_day_less_than_old_cache() {
		let currentDate = Date()
		let oneDayLessThanOldCacheDate = currentDate.addind(days: -1).addind(seconds: 1)
		let (sut, cache) = makeSUT(currentDate: currentDate)
		let items = [makeItem()]

		assert(sut, completion: .success(items)) {
			cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayLessThanOldCacheDate))
		}
	}

	func test_load_returned_data_with_one_day_old_cache() {
		let currentDate = Date()
		let oneDayOldCacheDate = currentDate.addind(days: -1)
		let (sut, cache) = makeSUT(currentDate: currentDate)
		let items = [makeItem()]

		assert(sut, completion: .success([])) {
			cache.completionHandlerForLoad(.success(items: items, timestamp: oneDayOldCacheDate))
		}
	}

	private func makeSUT(currentDate: Date = Date(),
						 file: StaticString = #filePath,
						 line: UInt = #line) -> (sut: LocalRestaurantLoader, cache: CacheClientSpy) {
		let cache = CacheClientSpy()
		let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate } )
		trackForMemoryLeaks(cache)
		trackForMemoryLeaks(sut)
		return (sut, cache)
	}

	private func assert(
		_ sut: LocalRestaurantLoader,
		completion result: (Result<[RestaurantItem], RestaurantResultError>)??,
		when action: () -> Void,
		file: StaticString = #filePath,
		line: UInt = #line
	) {

		var returnedResult: (Result<[RestaurantItem], RestaurantResultError>)?
		sut.load { result in
			returnedResult = result
		}

		action()

		XCTAssertEqual(returnedResult, result)
	}
}
