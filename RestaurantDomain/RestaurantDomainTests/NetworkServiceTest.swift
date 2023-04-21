//
//  NetworkServiceTest.swift
//  RestaurantDomainTests
//
//  Created by Jean Camargo on 20/04/23.
//

import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {


	func test_loadRequest_resume_dataTask_with_url() {
		let url = URL(string: "https://globo.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		let sut = NetworkService(session: session)

		session.stub(url: url, task: task)

		sut.request(from: url) { _ in }

		XCTAssertEqual(task.resumeCount, 1)
	}

	func test_loadRequest_and_completion_with_error() {
		let url = URL(string: "https://globo.com")!
		let session = URLSessionSpy()
		let task = URLSessionDataTaskSpy()
		let sut = NetworkService(session: session)
		let anyError = NSError(domain: "any error", code: -1)

		session.stub(url: url, task: task, error: anyError)

		let exp = expectation(description: "aguradando retorno da closure")

		sut.request(from: url) { result in
			switch result {
				case let .failure(returnedError):
					XCTAssertEqual(returnedError as NSError, anyError)

				default:
					XCTFail("Esperado falha, porem retornou \(result)")
			}
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)

	}
}

final class URLSessionSpy: URLSession {

	private(set) var urlRequest: URL?
	private(set) var stubs: [URL: Stub] = [:]

	struct Stub {
		let task: URLSessionDataTask
		let error: Error?
	}

	func stub(url: URL, task: URLSessionDataTask, error: Error? = nil) {
		stubs[url] = Stub(task: task, error: error)
	}

	override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {

		guard let stub = stubs[url] else {
			return FakeURLSessionDataTask()
		}

		completionHandler(nil, nil, stub.error)

		return stub.task
	}
}

final class URLSessionDataTaskSpy: URLSessionDataTask {
	private(set) var resumeCount = 0

	override func resume() {
		 resumeCount += 1
	}
}

final class FakeURLSessionDataTask: URLSessionDataTask {
	override func resume() {}
}

