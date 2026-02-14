/// Optional contract for features that expose upstream delegate events from actions.
///
/// Types that do not need delegate-style upstream communication should not conform.
/// For new code, prefer case-path extraction with `TCAInteractor.observeDelegateEvents(for:_:)`.
///
/// Stability: evolving-v0x
public protocol DelegateActionExtractable {
  associatedtype Delegate
  var delegateEvent: Delegate? { get }
}
