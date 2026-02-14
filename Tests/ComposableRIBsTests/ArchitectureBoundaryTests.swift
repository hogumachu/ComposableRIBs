import ComposableRIBs
import Foundation
import Testing

@Suite("Architecture Boundary")
@MainActor
struct ArchitectureBoundaryTests {
  protocol ParentContract: RIBDependency {
    var initialValue: Int { get }
  }

  protocol ChildContract: RIBDependency {
    var childSeed: Int { get }
  }

  struct ParentConcreteDependency: ParentContract {
    let initialValue: Int
    let parentInternalToken: String
  }

  struct ParentComponent: ChildContract {
    let dependency: any ParentContract
    var childSeed: Int { dependency.initialValue * 2 }
  }

  struct ContractOnlyChildBuilder: Buildable {
    func build(with dependency: any ChildContract) -> BaseRouter {
      let router = BaseRouter()
      if dependency.childSeed > 0 {
        router.load()
      }
      return router
    }
  }

  @Test("Child builder wiring remains protocol-first")
  func childBuilderWiringUsesProtocolContracts() {
    let parent = ParentConcreteDependency(initialValue: 2, parentInternalToken: "private")
    let component = ParentComponent(dependency: parent)

    let router = ContractOnlyChildBuilder().build(with: component)

    #expect(type(of: router) == BaseRouter.self)
  }

  @Test("Sample views do not reference router objects directly")
  func sampleViewsDoNotReferenceRouters() throws {
    let root = try repositoryRoot()
    let featuresPath = root.appendingPathComponent("Examples/iOSSample/SampleApp/Features")
    let viewFiles = try swiftUIViewFiles(in: featuresPath.path)

    #expect(!viewFiles.isEmpty)

    let disallowedTokens = [
      "@ObservedObject var router",
      "let router:",
      "var router:"
    ]

    for filePath in viewFiles {
      let contents = try String(contentsOfFile: filePath, encoding: .utf8)
      for token in disallowedTokens {
        #expect(!contents.contains(token), "Found disallowed token '\(token)' in \(filePath)")
      }
    }
  }

  @Test("Sample module wiring avoids concrete child router leakage across boundaries")
  func sampleBuildersUseRoutingContractsAcrossBoundaries() throws {
    let root = try repositoryRoot()
    let parentBuilder = root.appendingPathComponent(
      "Examples/iOSSample/SampleApp/Features/Parent/ParentBuilder.swift"
    )
    let childBuilder = root.appendingPathComponent(
      "Examples/iOSSample/SampleApp/Features/Child/ChildBuilder.swift"
    )

    let parentContents = try String(contentsOf: parentBuilder, encoding: .utf8)
    let childContents = try String(contentsOf: childBuilder, encoding: .utf8)

    #expect(parentContents.contains("any ChildBuildable"))
    #expect(parentContents.contains("any ParentRouting"))
    #expect(!parentContents.contains("ChildRouter"))

    #expect(childContents.contains("any GrandchildBuildable"))
    #expect(childContents.contains("any ChildRouting"))
    #expect(!childContents.contains("GrandchildRouter"))
  }

  @Test("Sample routers avoid state-flag polling for upstream navigation intents")
  func sampleRoutersPreferDelegateEventFlow() throws {
    let root = try repositoryRoot()
    let parentRouter = root.appendingPathComponent(
      "Examples/iOSSample/SampleApp/Features/Parent/ParentRouter.swift"
    )
    let childRouter = root.appendingPathComponent(
      "Examples/iOSSample/SampleApp/Features/Child/ChildRouter.swift"
    )
    let grandchildRouter = root.appendingPathComponent(
      "Examples/iOSSample/SampleApp/Features/Grandchild/GrandchildRouter.swift"
    )

    let parentContents = try String(contentsOf: parentRouter, encoding: .utf8)
    let childContents = try String(contentsOf: childRouter, encoding: .utf8)
    let grandchildContents = try String(contentsOf: grandchildRouter, encoding: .utf8)

    #expect(parentContents.contains("observeDelegateEvents"))
    #expect(childContents.contains("observeDelegateEvents"))
    #expect(grandchildContents.contains("observeDelegateEvents"))
    #expect(parentContents.contains("for: \\.delegate"))
    #expect(childContents.contains("for: \\.delegate"))
    #expect(grandchildContents.contains("for: \\.delegate"))

    let disallowedTokens = [
      "viewStore.publisher.showChild",
      "viewStore.publisher.showGrandchild",
      "viewStore.publisher.shouldClose"
    ]

    for token in disallowedTokens {
      #expect(!parentContents.contains(token))
      #expect(!childContents.contains(token))
      #expect(!grandchildContents.contains(token))
    }
  }

  private func repositoryRoot() throws -> URL {
    let fileURL = URL(fileURLWithPath: #filePath)
    // Tests/ComposableRIBsTests/<file>.swift -> repository root
    return fileURL
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .deletingLastPathComponent()
  }

  private func swiftUIViewFiles(in featuresPath: String) throws -> [String] {
    let enumerator = FileManager.default.enumerator(atPath: featuresPath)
    var files: [String] = []

    while let entry = enumerator?.nextObject() as? String {
      guard entry.hasSuffix("View.swift") else { continue }
      files.append((featuresPath as NSString).appendingPathComponent(entry))
    }

    return files
  }
}
