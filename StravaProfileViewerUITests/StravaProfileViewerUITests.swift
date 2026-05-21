//
//  StravaProfileViewerUITests.swift
//  StravaProfileViewerUITests
//
//  Created by Yuchen Nie on 2/27/26.
//

import XCTest

final class StravaProfileViewerUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()
    }
}
