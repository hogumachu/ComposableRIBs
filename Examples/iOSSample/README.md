# iOSSample

This sample demonstrates ComposableRIBs with a Parent -> Child -> Grandchild tree on iOS.

## What it shows
- UIKit app entrypoint (`AppDelegate`/`SceneDelegate`)
- SwiftUI feature rendering hosted from UIKit (`UIHostingController`)
- TCA reducers for each module
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
1. Parent screen appears from UIKit root host.
2. Tap **Attach Child** to attach and activate child module.
3. In child, tap **Attach Grandchild** to attach and activate grandchild module.
4. Tap detach actions to observe lifecycle state switching and cancellation.
