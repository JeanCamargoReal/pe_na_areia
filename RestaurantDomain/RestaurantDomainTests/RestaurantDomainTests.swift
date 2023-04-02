//
//  RestaurantDomainTests.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 02/04/23.
//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

	func test_initializer_remoteRestauranteLoader_and_validate_urlRequest() throws {
		let anyURL =  try XCTUnwrap(URL(string: "https://www.globo.com"))
		let sut = RemoteRestaurantLoader(url: anyURL)

		sut.load()

		XCTAssertNotNil(NetworkClient.shared.urlRequest)
	}
}
