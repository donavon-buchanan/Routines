//
//  RoutinesUITests.swift
//  RoutinesUITests
//
//  Created by Donavon Buchanan on 5/9/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import XCTest

class RoutinesUITests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        snapshot("0Launch")
        let tabBarsQuery = app.tabBars
        let afternoonButton = tabBarsQuery.buttons["Afternoon"]
        afternoonButton.tap()
        snapshot("0Afternoon")
        let button = app.navigationBars["Afternoon"].children(matching: .button).element(boundBy: 2)
        button.tap()
        snapshot("0AllDay")
        let tablesQuery = app.tables
        let askJenniferWhereSheDLikeToHaveDinnerStaticText = tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Ask Jennifer where she’d like to have dinner"]/*[[".cells.staticTexts[\"Ask Jennifer where she’d like to have dinner\"]",".staticTexts[\"Ask Jennifer where she’d like to have dinner\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        askJenniferWhereSheDLikeToHaveDinnerStaticText.swipeLeft()
        snapshot("1AllDay")
        let button2 = app.navigationBars["All Day"].children(matching: .button).element(boundBy: 2)
        button2.tap()
        let eveningButton = tabBarsQuery.buttons["Evening"]
        eveningButton.tap()
        snapshot("0Evening")
        tabBarsQuery.buttons["Night"].tap()
        snapshot("0Night")
        app.navigationBars["Night"].buttons["Options"].tap()
        snapshot("0Settings")
        app/*@START_MENU_TOKEN@*/.tables.containing(.other, identifier:"START TIMES").element/*[[".tables.containing(.other, identifier:\"ROUTINES+\").element",".tables.containing(.other, identifier:\"STYLE\").element",".tables.containing(.other, identifier:\"Enable to receive notifications at the start of each period\").element",".tables.containing(.other, identifier:\"NOTIFICATIONS\").element",".tables.containing(.other, identifier:\"Set when each time period should begin\").element",".tables.containing(.other, identifier:\"START TIMES\").element"],[[[-1,5],[-1,4],[-1,3],[-1,2],[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeUp()
        snapshot("1Settings")
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Dark Mode"]/*[[".cells.staticTexts[\"Dark Mode\"]",".staticTexts[\"Dark Mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("2Settings")
        app.navigationBars["Settings"].buttons["Done"].tap()
        snapshot("1Night")
        eveningButton.tap()
        snapshot("1Evening")
        afternoonButton.tap()
        snapshot("1Afternoon")
        button.tap()
        snapshot("2AllDay")
        askJenniferWhereSheDLikeToHaveDinnerStaticText.swipeLeft()
        snapshot("3AllDay")
        button2.tap()
        tabBarsQuery.buttons["Morning"].tap()
        snapshot("1Launch")
        
    }
}
