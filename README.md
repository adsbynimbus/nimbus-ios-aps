# NimbusAPSKit

A Nimbus SDK extension for **Amazon Publisher Services bidding**. It enriches Nimbus ad requests with APS demand and renders through the Nimbus SDK if it wins the auction.

## Versioning
 
`NimbusAPSKit` **major versions are kept in sync** with the `AmazonPublisherServices SDK`. For example, NimbusAPSKit `5.x.x` depends on AmazonPublisherServices SDK `5.x.x`.
 
Minor and patch versions are independent — a NimbusAPSKit patch release does not necessarily correspond to an AmazonPublisherServices SDK patch release, and vice versa.
 
| NimbusAPSKit | AmazonPublisherServices SDK |
|---|---|
| 5.x.x | 5.x.x |

## Installation

### Swift Package Manager

#### Xcode Project

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL:
   ```
   https://github.com/adsbynimbus/nimbus-ios-aps
   ```
3. Set the dependency rule to **Up to Next Major Version** and enter `5.0.0` as the minimum.
4. Click **Add Package** and select the **NimbusAPSKit** library when prompted.

#### Package.swift

If you're managing dependencies through a `Package.swift` file, add the following:

```swift
dependencies: [
    .package(url: "https://github.com/adsbynimbus/nimbus-ios-aps", from: "5.0.0")
]
```

Then add the product to your target:

```swift
.product(name: "NimbusAPSKit", package: "nimbus-ios-aps")
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'NimbusAPSKit'
```

Then run:

```sh
pod install
```

## Usage

### Fetch an APS Ad

APS requires that the publisher fetches the initial bid directly. Nimbus will handle all subsequent refreshes automatically. See the example below:
 
```swift
@preconcurrency import DTBiOSSDK
import NimbusAPSKit

func showAd() async {
    let bannerAdRequest = APSAdRequest(
        slotUUID: "<slotUUID>",
        adNetworkInfo: .init(networkName: .nimbus)
    )
    bannerAdRequest.setAdFormat(.banner)
        
    let apsAd = try await bannerAdRequest.loadAd()
    
    self.bannerAd = try await Nimbus.bannerAd(position: "banner", size: .banner, refreshInterval: 30) {
        demand {
            aps(ads: [apsAd])
        }
    }
}
```

That's it — APS demand is now included in this banner request, and Nimbus will handle refreshes automatically.

## Documentation

- [Nimbus iOS SDK Documentation](https://docs.adsbynimbus.com/docs/sdk/ios) — integration guides, configuration, and API reference.
- [DocC API Reference](https://iosdocs.adsbynimbus.com) — auto-generated documentation for the latest release.

## Sample App

See NimbusAPSKit in action in our public [sample app repository](https://github.com/adsbynimbus/nimbus-ios-sample), which demonstrates end-to-end integration including setup, bid requests, and ad rendering.
