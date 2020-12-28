//
//  CustomizeProfileTests.swift
//  XY_APP
//
//  Created by Maxime Franchot on 26/12/2020.
//

import XCTest

@testable import XY_APP


class CustomizeProfileTests: XCTestCase {
    
    var viewController: CustomizeProfileViewController?

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewController = CustomizeProfileViewController()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        // Supply data to view controller, then execute customize profile API
        
        //viewController.setLocation("Test")
        //let location = viewController.profileData.location
        //XCTAssertEqual(location, "Test", "Failed to set profile location")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
