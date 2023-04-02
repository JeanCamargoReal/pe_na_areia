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
		let client = NetworkClientSpy()
		let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)

		sut.load()

		XCTAssertEqual(client.urlRequest, anyURL)
	}
}

final class NetworkClientSpy: NetworkClient {
	private(set) var urlRequest: URL?

	func request(from url: URL) {
		urlRequest = url
	}
}
