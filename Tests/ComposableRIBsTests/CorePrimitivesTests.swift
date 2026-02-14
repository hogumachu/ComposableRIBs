import ComposableRIBs
import Testing

@Suite("Core Primitives")
struct CorePrimitivesTests {
  @Test("BaseRouter prevents duplicate child attachments")
  func attachChildDeduplicates() {
    let parent = BaseRouter()
    let child = BaseRouter()

    parent.attachChild(child)
    parent.attachChild(child)

    #expect(parent.children.count == 1)
  }

  @Test("BaseRouter detaches an existing child")
  func detachChildRemovesChild() {
    let parent = BaseRouter()
    let child = BaseRouter()

    parent.attachChild(child)
    parent.detachChild(child)

    #expect(parent.children.isEmpty)
  }
}
