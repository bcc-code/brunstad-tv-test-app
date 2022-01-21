//
//  Stream_TestUITests.swift
//  Stream-TestUITests
//
//  Created by Matjaz Debelak on 07/12/2021.
//

import XCTest

class Stream_TestUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func waitText(app: XCUIApplication, id: String, message: String, t : TimeInterval) {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", message)
        let el = app.staticTexts[id]
        let exp = expectation(for: predicate, evaluatedWith: el, handler: nil)
        self.wait(for: [exp], timeout: t)
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()
            
        waitText(app: app, id: "TimeControlValue", message: "Playing",t: 30)
        waitText(app: app, id: "VideoStatus", message: "1920x1080", t: 60)
        
        waitText(app: app, id: "SubLanguage", message: "Norwegian", t: 60)
        waitText(app: app, id: "AudioLanguage", message: "Norwegian", t: 60)

        XCUIRemote.shared.press(.down)
        sleep(1)
        XCUIRemote.shared.press(.select)
        
        sleep(10)
        
        waitText(app: app, id: "TimeControlValue", message: "Playing",t: 10)
        waitText(app: app, id: "VideoStatus", message: "1920x1080", t: 60)
        waitText(app: app, id: "SubLanguage", message: "Polish", t: 60)
        waitText(app: app, id: "AudioLanguage", message: "German", t: 60)
    }
}
