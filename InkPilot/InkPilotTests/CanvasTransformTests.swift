import XCTest
@testable import InkPilot

final class CanvasTransformTests: XCTestCase {

    func testIdentityTransform() {
        let t = CanvasTransform.identity
        XCTAssertEqual(t.scale, 1.0)
        XCTAssertEqual(t.offset, .zero)
    }

    func testWorldToScreenAtIdentity() {
        let t = CanvasTransform.identity
        let screen = t.worldToScreen(CGPoint(x: 100, y: 200))
        XCTAssertEqual(screen.x, 100)
        XCTAssertEqual(screen.y, 200)
    }

    func testWorldToScreenWithScale() {
        let t = CanvasTransform(scale: 2.0, offset: .zero)
        let screen = t.worldToScreen(CGPoint(x: 100, y: 200))
        XCTAssertEqual(screen.x, 200)
        XCTAssertEqual(screen.y, 400)
    }

    func testWorldToScreenWithOffset() {
        let t = CanvasTransform(scale: 1.0, offset: CGSize(width: 50, height: 30))
        let screen = t.worldToScreen(CGPoint(x: 100, y: 200))
        XCTAssertEqual(screen.x, 150)
        XCTAssertEqual(screen.y, 230)
    }

    func testScreenToWorldRoundtrip() {
        let t = CanvasTransform(scale: 1.5, offset: CGSize(width: 20, height: 10))
        let world = CGPoint(x: 300, y: 400)
        let screen = t.worldToScreen(world)
        let back = t.screenToWorld(screen)
        XCTAssertEqual(back.x, world.x, accuracy: 0.01)
        XCTAssertEqual(back.y, world.y, accuracy: 0.01)
    }

    func testWorldToScreenSize() {
        let t = CanvasTransform(scale: 2.0, offset: .zero)
        let size = t.worldToScreenSize(CGSize(width: 100, height: 50))
        XCTAssertEqual(size.width, 200)
        XCTAssertEqual(size.height, 100)
    }
}
