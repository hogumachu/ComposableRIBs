# iOSSample

This sample demonstrates ComposableRIBs with a Parent -> Child -> Grandchild tree on iOS.

## What it shows
- UIKit app entrypoint (`AppDelegate`/`SceneDelegate`)
- UIKit navigation ownership (`UINavigationController` push/pop)
- SwiftUI feature rendering hosted from UIKit (`UIHostingController`)
- Pure TCA views and reducers (views send actions only)
- Delegate-first upstream intent (`Action.delegate(...)`) for parent-child navigation coordination
- RIB-style Builders/Routers and dependency contracts
- Lifecycle forwarding through `TCAInteractor`
- Nested cancellation behavior (child ticker effect cancelled on deactivate)

## Run
1. Generate project files:
   ```bash
   cd Examples/iOSSample
   xcodegen generate
   ```
2. Open `iOSSample.xcodeproj` in Xcode.
3. Select an iOS simulator (for example: iPhone 16, iOS 18.5).
4. Build and run the `iOSSample` scheme.

## Flow
1. Parent screen appears as the root of a UIKit navigation stack.
2. Tap **Show Child** to push and activate the child module.
3. In child, tap **Show Grandchild** to push and activate the grandchild module.
4. Use **Close Grandchild** and **Close Child** to pop, detach, and deactivate modules.
