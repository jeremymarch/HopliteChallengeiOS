//
//  PlayTest.swift
//  HopliteChallenge
//
//  Created by jeremy on 1/19/26.
//  Copyright © 2026 Jeremy March. All rights reserved.
//

import XCTest

class PlayButtonFlowUITest: XCTestCase {

    func testPlayButtonShowsHopliteChallenge() {
        let app = XCUIApplication()
        app.launch()
        
        let playButton = app.buttons["PlayButton"]
        XCTAssertTrue(playButton.waitForExistence(timeout: 5), "Play button does not exist")
        playButton.tap()
        
        let hopliteChallengeView = app.otherElements["HopliteChallengeView"]
        XCTAssertTrue(hopliteChallengeView.waitForExistence(timeout: 5), "HopliteChallengeView did not appear")
    }
}

