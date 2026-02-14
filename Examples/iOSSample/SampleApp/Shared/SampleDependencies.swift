import ComposableRIBs

protocol ParentDependency: RIBDependency {
  var initialCounter: Int { get }
}

protocol ChildDependency: RIBDependency {
  var childSeedValue: Int { get }
}

protocol GrandchildDependency: RIBDependency {
  var grandchildTitle: String { get }
}

struct SampleAppDependency: ParentDependency {
  let initialCounter: Int
}

struct ParentComponent: ChildDependency {
  let dependency: any ParentDependency
  var childSeedValue: Int { dependency.initialCounter * 2 }
}

struct ChildComponent: GrandchildDependency {
  let dependency: any ChildDependency
  var grandchildTitle: String { "Grandchild (seed: \(dependency.childSeedValue))" }
}
