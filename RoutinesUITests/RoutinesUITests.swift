//
//  RoutinesUITests.swift
//  RoutinesUITests
//
//  Created by Donavon Buchanan on 5/9/19.
//  Copyright © 2019 Donavon Buchanan. All rights reserved.
//

import XCTest
import UIKit

class RoutinesUITests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        let app = XCUIApplication()
        setupSnapshot(app, waitForAnimations: false)
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        if ProcessInfo().arguments.contains("SKIP_ANIMATIONS") {
            UIView.setAnimationsEnabled(false)
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // Would be nice if somewhere here it mentioned that the naming convention of testFuncName is required
    func testGenerateScreenshots() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let morningNavigationBar = app.navigationBars["Morning"]
        morningNavigationBar.buttons["Options"].tap()
        snapshot("Options")
        app.navigationBars["Settings"].buttons["Done"].tap()
        snapshot("Morning")
        morningNavigationBar.children(matching: .button).element(boundBy: 2).tap()
        snapshot("All-Day")
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Plan dad's birthday party"]/*[[".cells.staticTexts[\"Plan dad's birthday party\"]",".staticTexts[\"Plan dad's birthday party\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("Afternoon-detail")
        if app.staticTexts["Continue"].exists {
            app/*@START_MENU_TOKEN@*/.staticTexts["Continue"]/*[[".otherElements[\"UIContinuousPathIntroductionView\"]",".buttons[\"Continue\"].staticTexts[\"Continue\"]",".staticTexts[\"Continue\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.tap()
        }
        app.navigationBars["Editing Task"].buttons["Cancel"].tap()
        app.navigationBars["All Day"].children(matching: .button).element(boundBy: 2).tap()
        let tabBarsQuery = app.tabBars
        tabBarsQuery.buttons["Afternoon"].tap()
        snapshot("Afternoon")
        tabBarsQuery.buttons["Evening"].tap()
        snapshot("Evening")
        tabBarsQuery.buttons["Night"].tap()
        snapshot("Night")
        tabBarsQuery.buttons["Morning"].tap()
        
        
        

//        let app = XCUIApplication()
//        snapshot("Morning-Light")
//        let tabBarsQuery = app.tabBars
//        let afternoonButton = tabBarsQuery.buttons["Afternoon"]
//        afternoonButton.tap()
//        snapshot("Afternoon-Light")
//        
//        //All Day Light snapshot
//        let button = app.navigationBars["Afternoon"].children(matching: .button).element(boundBy: 2)
//        button.tap()
//        let tablesQuery = app.tables
//        #if targetEnvironment(simulator)
//        let figureOutDinnerPlans = tablesQuery.staticTexts["Figure out dinner plans"]
//        figureOutDinnerPlans.swipeLeft()
//        #endif
//        snapshot("AllDay-Light")
//        let button2 = app.navigationBars["All Day"].children(matching: .button).element(boundBy: 2)
//        button2.tap()
//        //end
//        
//        let eveningButton = tabBarsQuery.buttons["Evening"]
//        eveningButton.tap()
//        snapshot("Evening-Light")
//        tabBarsQuery.buttons["Night"].tap()
//        snapshot("Night-Light")
//        app.navigationBars["Night"].buttons["Options"].tap()
//        tablesQuery.children(matching: .other)["STYLE"].children(matching: .other)["STYLE"].swipeUp()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Dark Mode"]/*[[".cells.staticTexts[\"Dark Mode\"]",".staticTexts[\"Dark Mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        snapshot("Settings-Dark")
//        app.navigationBars["Settings"].buttons["Done"].tap()
//        snapshot("Night-Dark")
//        eveningButton.tap()
//        snapshot("Evening-Dark")
//        afternoonButton.tap()
//        snapshot("Afternoon-Dark")
//        
//        //All Day Dark snapshot
//        button.tap()
//        #if targetEnvironment(simulator)
//        figureOutDinnerPlans.swipeLeft()
//        #endif
//        snapshot("AllDay-Dark")
//        button2.tap()
//        //end
//        
//
//        tabBarsQuery.buttons["Morning"].tap()
//        snapshot("Morning-Dark")
//        app.navigationBars["Morning"].buttons["Options"].tap()
//        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["Dark Mode"]/*[[".cells.staticTexts[\"Dark Mode\"]",".staticTexts[\"Dark Mode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
//        tablesQuery.children(matching: .other)["STYLE"].children(matching: .other)["STYLE"].swipeUp()
//        snapshot("Settings-Light")
//        app.navigationBars["Settings"].buttons["Done"].tap()
    }
}
