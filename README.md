# AsyncCompatibilityKit

Welcome to **AsyncCompatibilityKit**, a lightweight Swift package that adds iOS 13-compatible backports of commonly used `async/await`-based system APIs that are only available from iOS 15 by default.

It currently includes backward compatible versions of the following APIs:

- `URLSession.data(from: URL)`
- `URLSession.data(for: URLRequest)`
- `Combine.Publisher.values`
- `SwiftUI.View.task`

All of the included backports have signatures matching their respective system APIs, so that once you’re ready to make iOS 15 your minimum deployment target, you should be able to simply unlink AsyncCompatibilityKit from your project without having to make any additional changes to your code base (besides removing all `import AsyncCompatibilityKit` statements).

AsyncCompatibilityKit even marks all of its added APIs as deprecated when integrated into an iOS 15-based project, so that you’ll get a reminder that it’s no longer needed once you’re able to use the matching system APIs directly *(as of Xcode 13.2, no such deprecation warnings seem to show up within SwiftUI views, though)*.

However, it’s important to point out that the implementations provided by AsyncCompatibilityKit might not perfectly match their system equivalents in terms of behavior, since those system implementations are closed-source and private to Apple. No reverse engineering was involved in writing this library. Instead, each of the included APIs are complete reimplementations of the system APIs that they’re intended to match. It’s therefore strongly recommended that you thoroughly test any code that uses these backported versions before deploying that code to production.

To learn more about the techniques used to implement these backports, and Swift Concurrency in general, check out [Discover Concurrency over on Swift by Sundell](https://swiftbysundell.com/discover/concurrency).

## Installation

AsyncCompatibilityKit is distributed using the [Swift Package Manager](https://swift.org/package-manager). To install it, use Xcode’s `File > Add Packages...` menu command to add it to your iOS app project.

Then import AsyncCompatibilityKit wherever you’d like to use it:

```swift
import AsyncCompatibilityKit
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://swift.org/package-manager).

Please note that AsyncCompatibilityKit is not meant to be integrated into targets other than iOS app projects with a minimum deployment target of iOS 13 or above. It also requires Xcode 13.2 or later.

## Support and contributions

AsyncCompatibilityKit has been made freely available to the entire Swift community under the very permissive [MIT license](LICENSE.md), but please note that it doesn’t come with any official support channels, such as GitHub issues, or Twitter/email-based support. So, before you start using AsyncCompatibilityKit within one of your projects, it’s highly recommended that you spend some time familiarizing yourself with its implementation, in case you’ll run into any issues that you’ll need to debug.

If you’ve found a bug, documentation typo, or if you want to propose a performance improvement, then feel free to [open a Pull Request](https://github.com/JohnSundell/AsyncCompatibilityKit/compare) (even if it just contains a unit test that reproduces a given issue). While all sorts of fixes and tweaks are more than welcome, AsyncCompatibilityKit is meant to be a very small, focused library, and should only contain simple backports of async/await-based system APIs. So, if you’d like to add any significant new features to the library, then it’s recommended that you fork it, which will let you extend and customize it to fit your needs.

Hope you’ll enjoy using AsyncCompatibilityKit!
