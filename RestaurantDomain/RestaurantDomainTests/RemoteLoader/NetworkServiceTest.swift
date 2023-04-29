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
		let (sut, session) = makeSUT()
		let url = URL(string: "https://globo.com")!
		let task = URLSessionDataTaskSpy()
		
		session.stub(url: url, task: task)
		
		sut.request(from: url) { _ in }
		
		XCTAssertEqual(task.resumeCount, 1)
	}
	
	func test_loadRequest_and_completion_with_error_for_invalidCases() {
		let url = URL(string: "https://globo.com")!
		let anyError = NSError(domain: "any error", code: -1)
		let data = Data()
		let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
		let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)

		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: nil, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: nil, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: nil))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: urlResponse, error: anyError))
		XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: httpResponse, error: anyError))

		let result = resultErrorForInvalidCases(data: data, response: httpResponse, error: anyError)

		XCTAssertEqual(result as? NSError, anyError)
	}
	
	func test_loadRequest_and_completion_with_success_for_validCases() {
		let url = URL(string: "https://globo.com")!
		let data = Data()
		let okResponse = 200
		let httpResponse = HTTPURLResponse(url: url, statusCode: okResponse, httpVersion: nil, headerFields: nil)!

		let result = resultSuccessForValidCases(data: data, response: httpResponse, error: nil)

		XCTAssertEqual(result?.data, data)
		XCTAssertEqual(result?.response?.url, url)
		XCTAssertEqual(result?.response?.statusCode, okResponse)
	}
	
	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NetworkClient, session: URLSessionSpy) {
		let session = URLSessionSpy()
		let sut = NetworkService(session: session)
		
		trackForMemoryLeaks(session)
		trackForMemoryLeaks(sut)
		
		return (sut, session)
	}

	private func resultErrorForInvalidCases(data: Data?,
											response: URLResponse?,
											error: Error?,
											file: StaticString = #file,
											line: UInt = #line) -> Error? {

		let result = assert(data: data, response: response, error: error)

		switch result {
			case let .failure(error):
				return error
			default:
				XCTFail("Esperando erro, porem retornou \(String(describing: result))", file: file, line: line)
		}
		return nil
	}

	private func resultSuccessForValidCases(data: Data?,
											response: URLResponse?,
											error: Error?,
											file: StaticString = #file,
											line: UInt = #line) -> (data: Data?, response: HTTPURLResponse?)? {

		let result = assert(data: data, response: response, error: error)

		switch result {
			case let .success((returnedData, returnedResponse)):
				return (returnedData, returnedResponse)
			default:
				XCTFail("Esperando sucess, porem retornou \(String(describing: result))", file: file, line: line)
		}
		return nil
	}

	private func assert(data: Data?,
						response: URLResponse?,
						error: Error?,
						file: StaticString = #file,
						line: UInt = #line) -> NetworkService.NetworkResult? {

		let (sut, session) = makeSUT()
		let url = URL(string: "https://globo.com.br")!
		let task = URLSessionDataTaskSpy()

		session.stub(url: url, task: task, error: error, data: data, response: response)

		let exp = expectation(description: "aguardando retorno da closure")
		var returnedResult: NetworkService.NetworkResult?

		sut.request(from: url) { result in
			returnedResult = result
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1.0)

		return returnedResult
	}
}
