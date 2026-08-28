import Testing
import UIKit
@testable import Paperlane

struct IDCardComposerTests {
    @Test func composesTwoSidesIntoOnePageOfGivenSize() {
        let front = ImageFixtures.page("FRONT", size: CGSize(width: 400, height: 250))
        let back = ImageFixtures.page("BACK", size: CGSize(width: 400, height: 250))
        let page = IDCardComposer().compose(front: front, back: back,
                                            pageSize: CGSize(width: 600, height: 900))
        #expect(page.size == CGSize(width: 600, height: 900))
        #expect(page.cgImage != nil)
    }
}
