# EsimplifiedSDK

iOS SDK for eSIM API access — packages, orders, payments, eSIM management.

## Installation

Add via Swift Package Manager:

```
https://github.com/eSimplified/esimplified-ios-sdk.git
```

## Quick Start

```swift
import EsimplifiedSDK

let sdk = EsimplifiedSdk.initialize(
    config: SdkConfig(
        environment: .production,
        clientName: "your-app",
        apiVersion: "v2",
        clientId: "your-client-id",
        clientSecret: "your-client-secret"
    )
)

let countries = try await sdk.countriesRepository.fetchAllCountries()
```
