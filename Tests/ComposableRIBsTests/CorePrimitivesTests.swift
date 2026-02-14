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

  @Test("BaseRouter keeps different children and preserves identity uniqueness")
  func attachMultipleDistinctChildren() {
    let parent = BaseRouter()
    let first = BaseRouter()
    let second = BaseRouter()

    parent.attachChild(first)
    parent.attachChild(second)
    parent.attachChild(first)

    #expect(parent.children.count == 2)
    #expect(parent.children.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(first) }))
    #expect(parent.children.contains(where: { ObjectIdentifier($0) == ObjectIdentifier(second) }))
  }

  @Test("BaseRouter ignores detach when child was never attached")
  func detachNonExistentChildIsNoOp() {
    let parent = BaseRouter()
    let existing = BaseRouter()
    let nonExistent = BaseRouter()

    parent.attachChild(existing)
    parent.detachChild(nonExistent)

    #expect(parent.children.count == 1)
    #expect(ObjectIdentifier(parent.children[0]) == ObjectIdentifier(existing))
  }
}
