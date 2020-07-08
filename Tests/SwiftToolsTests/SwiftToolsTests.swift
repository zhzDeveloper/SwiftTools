import XCTest
@testable import SwiftTools

final class SwiftToolsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let content = [
            "msgtype": "link",
            "link": [
                    "text": "今天这个即将发布的新版本，创始人xx称它为红树林。而在此之前，每当面临重大升级，产品经理们都会取一个应景的代号，这一次，为什么是红树林",
                    "title": "时代的火车向前开",
                    "picUrl": "",
                    "messageUrl": "https://www.baidu.com"
                ]
        ] as [String : Any]
        let res = sendDingDingMsg(token: "dd207283de26beea832e4a936fe31bdf7fdcaa0f87d039d66db70f91b9bf0c47", content: content)
        print(res)
        XCTAssert(res)
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
