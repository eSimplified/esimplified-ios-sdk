# eSimplified iOS SDK — API Reference

For client teams integrating the SDK into an iOS app. Covers installation, configuration, every repository method available to you, and the full shape of every model the API returns.

Current version: **1.5.1**. The reference sections below are generated from the SDK source, so they match the code exactly.

For a shorter tour with worked examples, see [README.md](README.md). This document is the complete reference.

---

## Contents

1. [Requirements](#1-requirements)
2. [What you need from eSimplified](#2-what-you-need-from-esimplified)
3. [Installing the SDK](#3-installing-the-sdk)
4. [Configuring and creating the SDK](#4-configuring-and-creating-the-sdk)
5. [Keeping the customer signed in](#5-keeping-the-customer-signed-in)
6. [Making your first call](#6-making-your-first-call)
6b. [The full purchase journey](#6b-the-full-purchase-journey)
6c. [Installing the eSIM](#6c-installing-the-esim)
6d. [Signing out](#6d-signing-out)
7. [Error handling](#7-error-handling)
8. [Caching](#8-caching)
9. [Repository reference](#9-repository-reference)
9b. [Supporting types](#9b-supporting-types)
10. [Model reference](#10-model-reference)

---

## 1. Requirements

| | |
|---|---|
| Platforms | iOS 17.0+ |
| Swift | 5.9+ |
| Xcode | 15.0+ |
| Dependencies | None. The SDK is pure Swift with no third-party packages |

## 2. What you need from eSimplified

Before you write any code, ask your eSimplified contact for:

| Value | Used for |
|---|---|
| **Client name** | Identifies your tenant. Becomes part of the API host, e.g. `acme` → `https://acme.live.esimplified.io` |
| **Client ID** and **Client secret** | Basic auth for unauthenticated calls, and the OAuth exchange when a customer signs in |
| **AWS WAF token** | Sent as `x-auth-validation`. Optional in some environments, required in others — ask |
| **Environment** | `.staging`, `.testing` or `.production` |

Treat the client secret as a secret. Do not commit it; inject it at build time or fetch it from your own remote config at launch.

## 3. Installing the SDK

### Xcode

1. **File → Add Package Dependencies…**
2. Enter `https://github.com/eSimplified/esimplified-ios-sdk.git`
3. Dependency Rule: **Up to Next Major Version** from `1.5.1`
4. Add the `EsimplifiedSDK` library to your app target

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/eSimplified/esimplified-ios-sdk.git", from: "1.5.1")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [.product(name: "EsimplifiedSDK", package: "esimplified-ios-sdk")]
    )
]
```

Then `import EsimplifiedSDK` wherever you use it.

## 4. Configuring and creating the SDK

Create one `EsimplifiedSdk` at launch and share it. Every repository hangs off that instance.

```swift
import EsimplifiedSDK

let sdk = EsimplifiedSdk(
    config: SdkConfig(
        environment: .production,
        clientName: "acme",
        clientId: clientId,
        clientSecret: clientSecret,
        awsWafToken: wafToken,
        enableLogging: false
    )
)
```

### SdkConfig parameters

| Parameter | Type | Default | Meaning |
|---|---|---|---|
| `environment` | `SdkEnvironment` | — | `.staging`, `.testing` or `.production`. Selects the API host |
| `clientName` | `String` | — | Your tenant name, the first label of the API host |
| `apiVersion` | `String` | `"v2"` | API version segment. Leave as the default unless told otherwise |
| `clientId` | `String` | — | Basic-auth user and OAuth client id |
| `clientSecret` | `String` | — | Basic-auth password and OAuth client secret |
| `awsWafToken` | `String` | `""` | Sent as the `x-auth-validation` header when non-empty |
| `enableLogging` | `Bool` | `false` | Logs every request and response. Debug builds only |
| `enableCaching` | `Bool` | `true` | Turns the in-memory response cache on or off |
| `defaultCacheTTL` | `TimeInterval` | `3600` | Default cache lifetime in seconds |
| `customHeadersProvider` | `(() async -> [String: String])?` | `nil` | Extra headers added to every request. This is where `accept-language` and `accept-currency` belong |

### Language and currency

The API localises and prices responses from request headers, not from a parameter. Supply them through `customHeadersProvider` so every call picks up the customer's current choice:

```swift
customHeadersProvider: {
    [
        "accept-language": Settings.languageCode,
        "accept-currency": Settings.currencyCode
    ]
}
```

## 5. Keeping the customer signed in

The SDK holds tokens in memory for the lifetime of the process. To keep a customer signed in across launches, give it somewhere durable to read and write:

- **`SessionProvider`** — your app already owns the session and hands tokens to the SDK.
- **`StorageProvider`** — the SDK owns the session but persists it wherever you say, normally the Keychain. This is the simpler of the two and what most integrations want.

`StorageProvider` is four methods over a string store:

```swift
public protocol StorageProvider {
    func save(_ value: String, forKey key: String) throws
    func retrieve(forKey key: String) -> String?
    func delete(forKey key: String) throws
    func clear() throws
}
```

`SessionProvider` is the fuller contract, for when the session already lives in your app:

```swift
public protocol SessionProvider {
    func saveAuthState(_ state: AuthState) throws
    func getAuthState() -> AuthState
    func getAccessToken() -> String?
    func getRefreshToken() -> String?
    func clearSession() throws
    func getUserEmail() -> String?
    func onTokenRefreshed(response: SignInCustomerResponse)
    func onAuthenticationFailed()
}
```

Pass either to the `EsimplifiedSdk` initialiser. If you supply neither, the customer is signed out on every cold launch.

Token refresh is automatic: an expiring access token is refreshed before the request goes out, and a 401 triggers one refresh-and-retry. Concurrent calls share a single refresh rather than racing. A rejected refresh token ends the session; a network failure during refresh does not.

## 6. Making your first call

```swift
// Browse, no sign-in needed
let countries = await sdk.countriesRepository.fetchAllCountries()
let packages = await sdk.packagesRepository.fetchPackagesForCountry(
    countryCode: "ZA",
    countryNameSlug: "south-africa"
)

// Sign in, then read the customer's eSIMs
_ = try await sdk.authRepository.login(email: email, password: password)
let esims = await sdk.esimsRepository.fetchEsims(archivedEsims: false, showLegacy: false)
```

## 6b. The full purchase journey

The SDK gets you an order. It does **not** take the payment and it does **not** install the eSIM — both of those happen in your app. This is the whole journey, with the handoffs marked.

```swift
// 1. Browse, no sign-in needed
let countries = await sdk.countriesRepository.fetchAllCountries()
let response  = await sdk.packagesRepository.fetchPackagesForCountry(
    countryCode: "ZA",
    countryNameSlug: "south-africa"
)
let packages = response?.packages ?? []

// 2. The customer must be signed in to buy
_ = try await sdk.authRepository.login(email: email, password: password)

// 3. Ask the API to create a payment
let payment = try await sdk.paymentsRepository.fetchPayment(
    transactionType: .buy,
    packageTypeId: packages[0].packageTypeID,
    iccid: nil,                 // nil to buy a new eSIM; an ICCID to top an existing one up
    autoTopUp: false,
    savePaymentDetail: true,
    loyaltyPointsAmount: nil
)

// 4. YOUR APP takes the payment — the SDK stops here
//    payment.zeroCharge != nil  → nothing to pay, skip straight to step 5
//    otherwise hand these to the Stripe iOS SDK:
//      payment.publishableKey, payment.uri (the client secret),
//      payment.ephemeralKey, payment.customerRef

// 5. Once Stripe reports success, read the order
let order = try await sdk.ordersRepository.fetchOrder(orderUUID: payment.orderID!)

// 6. YOUR APP installs the eSIM — see "Installing the eSIM" below
//    order.smDpAddress, order.activationCode

// 7. Tell the API the conversion is recorded, so it is not counted twice
await sdk.ordersRepository.trackedOrder(orderUUID: payment.orderID!)
```

### An order is not ready the instant it is paid

Provisioning is asynchronous. Immediately after payment the order comes back with `orderStatus` `"pending"` and **no** `qrCode`, `smDpAddress`, `activationCode` or `profile` — every one of those is optional for exactly this reason. Poll `fetchOrder(orderUUID:forceRefresh: true)` until `smDpAddress` and `activationCode` are both present, and give the wait a deadline. If it expires, tell the customer the order has not completed rather than sending them into an install that cannot succeed. Their payment is safe and the order completes server-side.

## 6c. Installing the eSIM

The SDK hands you the credentials; iOS does the install. You need three things.

**1. The entitlement.** eSIM installation requires `com.apple.CommCenter.fine-grained` with the `public-cellular-plan` value, which Apple grants on request for your app's bundle ID. Without it the API below does nothing. Request it early — it is not instant.

```xml
<key>com.apple.CommCenter.fine-grained</key>
<array>
    <string>public-cellular-plan</string>
</array>
```

**2. A compatibility check**, so you do not offer installation on a device that cannot do it:

```swift
import CoreTelephony

let canInstall = CTCellularPlanProvisioning().supportsEmbeddedSIM
```

**3. The install itself**, using the order's credentials:

```swift
let request = CTCellularPlanProvisioningRequest()
request.address = order.smDpAddress ?? ""
request.matchingID = order.activationCode
CTCellularPlanProvisioning().addPlan(with: request) { result in
    // .success, .fail, .unknown — iOS shows its own system UI during this
}
```

Always offer a manual fallback as well. Render `order.qrCode` as a QR image for scanning on another device, and show `smDpAddress` and `activationCode` as text so the customer can type them into Settings. Some customers install on a second phone, and some devices refuse the direct install.

## 6d. Signing out

```swift
try await sdk.authRepository.logout()
await sdk.clearAllCaches()
```

Clear the caches as well as the session. Cached responses are keyed by endpoint, not by customer, so skipping this leaves one customer's eSIMs and orders readable by the next person to sign in on that device.

## 7. Error handling

Most read methods swallow failures and return an empty or `nil` value, so a list screen degrades quietly. Where you need the reason, use the variants:

| Variant | Behaviour |
|---|---|
| `fetchX(...)` | Returns the value, or empty/`nil` on failure. No reason given |
| `fetchXResult(...)` | Returns `RepositoryResult<T>` — the value, whether it came from a stale cache, and the `SdkError` that caused that. Lets you show data and an error together |
| `updateX(...)` | Returns `Bool`. Tells you it failed, not why |
| `updateXOrThrow(...)` | Throws the `SdkError` instead, so you can show the reason |

`SdkError` cases: `networkError(statusCode:message:)`, `decodingError`, `authenticationRequired`, `noInternetConnection`, `serverError`, `missingCredentials`, `invalidURL`, `unknown`.

Two descriptions, and the difference matters: **`errorDescription`** is safe to show a customer, **`debugDescription`** carries the technical detail — for a decoding failure it names the field and its coding path. Log the second, display the first.

## 8. Caching

Reads are cached in memory with a default TTL of one hour. Pass `forceRefresh: true` to bypass the cache for one call. Writes invalidate what they affect — changing an eSIM's primary flag clears every cached eSIM list, for example. `sdk.clearAllCaches()` empties everything, which is what you want on sign-out.

## 9. Repository reference

Every method below is reachable as `sdk.<repository>.<method>`. 106 signatures across 15 repositories. Where a method is listed more than once these are real overloads — the shortest form is the one to reach for, the longer ones let you override the cache lifetime or ask for extra data.

### AuthRepository

Sign in, sign up, tokens, password reset, email verification and account deletion.  
Access: `sdk.authRepository`

| Method | Signature |
|---|---|
| `changePassword` | `func changePassword(email: String, currentPassword: String, newPassword: String) async throws -> ChangePasswordResponse` |
| `deleteAccount` | `func deleteAccount() async throws -> DeleteAccountResponse` |
| `forgotPassword` | `func forgotPassword(email: String) async throws -> ForgotPasswordResponse` |
| `login` | `func login(email: String, password: String) async throws -> SignInCustomerResponse` |
| `loginWithProvider` | `func loginWithProvider(firstName: String, lastName: String, fullName: String, email: String, provider: AuthProvider, providerAccountId: String, idToken: String) async throws -> SignInCustomerResponse` |
| `logout` | `func logout() throws` |
| `refreshSession` | `func refreshSession() async throws -> SignInCustomerResponse` |
| `register` | `func register(request: RegisterCustomerRequest) async throws -> RegisterCustomerResponse` |
| `resetPassword` | `func resetPassword(email: String, token: String, newPassword: String) async throws -> ChangePasswordResponse` |
| `verifyEmail` | `func verifyEmail(email: String?, token: String?, orderUUID: String?) async throws -> VerifyEmailResponse` |

### UserRepository

The customer's profile and preferences.  
Access: `sdk.userRepository`

| Method | Signature |
|---|---|
| `fetchProfile` | `func fetchProfile() async throws -> User` |
| `fetchUserLocation` | `func fetchUserLocation() async throws -> UserLocationResponse` |
| `updatePreferences` | `func updatePreferences(_ request: UpdateCustomerPreferencesRequest) async throws -> User` |
| `updateProfile` | `func updateProfile(_ request: UpdateCustomerRequest) async throws -> UpdateCustomerResponse` |

### CountriesRepository

Destination browsing and search.  
Access: `sdk.countriesRepository`

| Method | Signature |
|---|---|
| `fetchAllCountries` | `func fetchAllCountries(forceRefresh: Bool = false) async -> [Country]` |
| `fetchAllCountries` | `func fetchAllCountries(forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Country]` |
| `fetchAllCountriesResult` | `func fetchAllCountriesResult(forceRefresh: Bool = false) async -> RepositoryResult<[Country]>` |
| `fetchAllCountriesResult` | `func fetchAllCountriesResult(forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Country]>` |
| `invalidateCache` | `func invalidateCache() async` |
| `searchCountries` | `func searchCountries(searchTerm: String) async -> [Country]` |

### PackagesRepository

Data packages for a destination, top-up packages for an existing eSIM, and stock checks.  
Access: `sdk.packagesRepository`

| Method | Signature |
|---|---|
| `fetchCheckStockForPackage` | `func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool = false) async -> CheckStockResponse?` |
| `fetchCheckStockForPackage` | `func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool, cacheTTL: TimeInterval) async -> CheckStockResponse?` |
| `fetchPackagesForCountry` | `func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async -> PackageResponse?` |
| `fetchPackagesForCountry` | `func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> PackageResponse?` |
| `fetchPackagesForCountryResult` | `func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<PackageResponse?>` |
| `fetchPackagesForCountryResult` | `func fetchPackagesForCountryResult(countryCode: String?, countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<PackageResponse?>` |
| `fetchPackagesForTopUpEsim` | `func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false) async -> [Package]` |
| `fetchPackagesForTopUpEsim` | `func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Package]` |
| `fetchPackagesForTopUpEsimResult` | `func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool = false) async -> RepositoryResult<[Package]>` |
| `fetchPackagesForTopUpEsimResult` | `func fetchPackagesForTopUpEsimResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Package]>` |
| `invalidateCache` | `func invalidateCache() async` |

### EsimsRepository

The customer's eSIMs and everything you can change about one.  
Access: `sdk.esimsRepository`

| Method | Signature |
|---|---|
| `fetchEsimDetails` | `func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async -> Esim?` |
| `fetchEsimDetails` | `func fetchEsimDetails(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> Esim?` |
| `fetchEsimDetails` | `func fetchEsimDetails(iccid: String, includeBase64QrCode: Bool, forceRefresh: Bool = false, cacheTTL: TimeInterval = 300) async -> Esim?` |
| `fetchEsimDetailsResult` | `func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool = false) async -> RepositoryResult<Esim?>` |
| `fetchEsimDetailsResult` | `func fetchEsimDetailsResult(iccid: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?>` |
| `fetchEsimDetailsResult` | `func fetchEsimDetailsResult(iccid: String, includeBase64QrCode: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<Esim?>` |
| `fetchEsims` | `func fetchEsims(archivedEsims: Bool, showLegacy: Bool? = nil, isPrimary: Bool? = nil, forceRefresh: Bool = false) async -> [Esim]` |
| `fetchEsims` | `func fetchEsims(archivedEsims: Bool, showLegacy: Bool?, isPrimary: Bool?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Esim]` |
| `fetchEsims` | `func fetchEsims(archivedEsims: Bool, showLegacy: Bool? = nil, isPrimary: Bool? = nil, includeBase64QrCode: Bool, forceRefresh: Bool = false, cacheTTL: TimeInterval = 86400) async -> [Esim]` |
| `fetchEsimsResult` | `func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool? = nil, isPrimary: Bool? = nil, forceRefresh: Bool = false) async -> RepositoryResult<[Esim]>` |
| `fetchEsimsResult` | `func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool?, isPrimary: Bool?, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]>` |
| `fetchEsimsResult` | `func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool? = nil, isPrimary: Bool? = nil, includeBase64QrCode: Bool, forceRefresh: Bool = false) async -> RepositoryResult<[Esim]>` |
| `fetchEsimsResult` | `func fetchEsimsResult(archivedEsims: Bool, showLegacy: Bool?, isPrimary: Bool?, includeBase64QrCode: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Esim]>` |
| `invalidateCache` | `func invalidateCache() async` |
| `updateEsimArchivedStatus` | `func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool` |
| `updateEsimArchivedStatusOrThrow` | `func updateEsimArchivedStatusOrThrow(status: Bool, iccid: String) async throws` |
| `updateEsimAutoTopUpStatus` | `func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool` |
| `updateEsimAutoTopUpStatusOrThrow` | `func updateEsimAutoTopUpStatusOrThrow(status: Bool, iccid: String) async throws` |
| `updateEsimName` | `func updateEsimName(customName: String, iccid: String) async -> Bool` |
| `updateEsimNameOrThrow` | `func updateEsimNameOrThrow(customName: String, iccid: String) async throws` |
| `updateEsimPrimaryStatus` | `func updateEsimPrimaryStatus(status: Bool, iccid: String) async -> Bool` |
| `updateEsimPrimaryStatusOrThrow` | `func updateEsimPrimaryStatusOrThrow(status: Bool, iccid: String) async throws` |

### OrdersRepository

Order history, a single order's full detail, and conversion tracking.  
Access: `sdk.ordersRepository`

| Method | Signature |
|---|---|
| `fetchInvoice` | `func fetchInvoice(orderUUID: String) async throws -> Data` |
| `fetchOrder` | `func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail` |
| `fetchOrder` | `func fetchOrder(orderUUID: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> OrderDetail` |
| `fetchOrders` | `func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order]` |
| `fetchOrders` | `func fetchOrders(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> [Order]` |
| `fetchOrdersPageResult` | `func fetchOrdersPageResult(limit: Int = 100, offset: Int = 0, withLoyaltyPoints: Bool) async -> RepositoryResult<OrdersPage>` |
| `fetchOrdersPageResult` | `func fetchOrdersPageResult(limit: Int, offset: Int, withLoyaltyPoints: Bool, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<OrdersPage>` |
| `fetchOrdersResult` | `func fetchOrdersResult(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> RepositoryResult<[Order]>` |
| `fetchOrdersResult` | `func fetchOrdersResult(forceRefresh: Bool, withLoyaltyPoints: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Order]>` |
| `invalidateCache` | `func invalidateCache() async` |
| `trackedOrder` | `func trackedOrder(orderUUID: String) async` |

### PaymentsRepository

Creating a payment and quoting a loyalty-point spend.  
Access: `sdk.paymentsRepository`

| Method | Signature |
|---|---|
| `fetchPayment` | `func fetchPayment(transactionType: TransactionType, packageTypeId: Int, iccid: String?, autoTopUp: Bool, savePaymentDetail: Bool, loyaltyPointsAmount: Double?) async throws -> PaymentData` |
| `sendKredsQuote` | `func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse` |

### PromoCodeRepository

Applying and releasing a promotional code.  
Access: `sdk.promoCodeRepository`

| Method | Signature |
|---|---|
| `applyPromocode` | `func applyPromocode(code: String) async throws -> PromoCodeResponse` |
| `deletePromocode` | `func deletePromocode(code: String) async throws -> PromoCodeResponse` |
| `fetchPromocode` | `func fetchPromocode() async throws -> PromoCodeResponse` |

### VouchersRepository

Redeeming a voucher code.  
Access: `sdk.vouchersRepository`

| Method | Signature |
|---|---|
| `redeemVoucher` | `func redeemVoucher(code: String) async throws -> VoucherRedeemResponse` |

### LoyaltyRepository

Kreds and Mokafaa balances and transactions.  
Access: `sdk.loyaltyRepository`

| Method | Signature |
|---|---|
| `fetchKredsBalance` | `func fetchKredsBalance(forceRefresh: Bool = true) async throws -> KredsLoyaltyBalanceResponse` |
| `fetchKredsBalance` | `func fetchKredsBalance(forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> KredsLoyaltyBalanceResponse` |
| `initiateOtp` | `func initiateOtp(purpose: MokafaaOtpPurpose) async throws -> MokafaaOtpInitiateResponse` |
| `invalidateCache` | `func invalidateCache() async` |
| `validateOtp` | `func validateOtp(sessionId: String, otp: String, points: Int? = nil) async throws -> MokafaaOtpValidateResponse` |
| `validateOtp` | `func validateOtp(sessionId: String, otp: String, points: Int?, packageTypeId: Int?) async throws -> MokafaaOtpValidateResponse` |

### NotificationRepository

Push and email notification settings.  
Access: `sdk.notificationRepository`

| Method | Signature |
|---|---|
| `fetchNotificationSettings` | `func fetchNotificationSettings() async -> [NotificationSettings]` |
| `updateNotificationSettings` | `func updateNotificationSettings(settings: [NotificationSettings]) async throws` |

### ThemeRepository

Server-driven imagery and colour for a page or destination.  
Access: `sdk.themeRepository`

| Method | Signature |
|---|---|
| `fetchDestinationTheme` | `func fetchDestinationTheme(countryCode: String, forceRefresh: Bool = false) async throws -> ThemeDestination?` |
| `fetchDestinationTheme` | `func fetchDestinationTheme(countryCode: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemeDestination?` |
| `fetchPageTheme` | `func fetchPageTheme(page: String, forceRefresh: Bool = false) async throws -> ThemePage?` |
| `fetchPageTheme` | `func fetchPageTheme(page: String, forceRefresh: Bool, cacheTTL: TimeInterval) async throws -> ThemePage?` |
| `invalidateCache` | `func invalidateCache() async` |

### FaqAndSupportRepository

Destination FAQs, plus the localised terms, privacy and help-centre documents.  
Access: `sdk.faqAndSupportRepository`

| Method | Signature |
|---|---|
| `fetchDestinationFaqs` | `func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool = false) async -> [Faq]` |
| `fetchDestinationFaqs` | `func fetchDestinationFaqs(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> [Faq]` |
| `fetchDestinationFaqsResult` | `func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool = false) async -> RepositoryResult<[Faq]>` |
| `fetchDestinationFaqsResult` | `func fetchDestinationFaqsResult(countryNameSlug: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<[Faq]>` |
| `fetchFaqs` | `func fetchFaqs(language: String, forceRefresh: Bool = false) async -> ContentDocument?` |
| `fetchFaqs` | `func fetchFaqs(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?` |
| `fetchFaqsResult` | `func fetchFaqsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?>` |
| `fetchFaqsResult` | `func fetchFaqsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>` |
| `fetchPrivacy` | `func fetchPrivacy(language: String, forceRefresh: Bool = false) async -> ContentDocument?` |
| `fetchPrivacy` | `func fetchPrivacy(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?` |
| `fetchPrivacyResult` | `func fetchPrivacyResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?>` |
| `fetchPrivacyResult` | `func fetchPrivacyResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>` |
| `fetchTerms` | `func fetchTerms(language: String, forceRefresh: Bool = false) async -> ContentDocument?` |
| `fetchTerms` | `func fetchTerms(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> ContentDocument?` |
| `fetchTermsResult` | `func fetchTermsResult(language: String, forceRefresh: Bool = false) async -> RepositoryResult<ContentDocument?>` |
| `fetchTermsResult` | `func fetchTermsResult(language: String, forceRefresh: Bool, cacheTTL: TimeInterval) async -> RepositoryResult<ContentDocument?>` |
| `invalidateCache` | `func invalidateCache() async` |

### VisaRewardsRepository

Visa cardholder reward validation and redemption.  
Access: `sdk.visaRewardsRepository`

| Method | Signature |
|---|---|
| `fetchVisaReward` | `func fetchVisaReward(isEU: Bool) async -> VisaRewardResponse?` |
| `fetchVisaValidation` | `func fetchVisaValidation(token: String) async -> VisaValidateResponse?` |
| `redeemVisaReward` | `func redeemVisaReward(token: String, body: [String: String]) async throws -> RedeemVisaResponse` |

### StoreReviewRepository

Whether to ask this customer for an App Store review.  
Access: `sdk.storeReviewRepository`

| Method | Signature |
|---|---|
| `fetchStoreReview` | `func fetchStoreReview() async throws -> StoreReviewResponse` |
| `fetchStoreReview` | `func fetchStoreReview(cacheTTL: TimeInterval) async throws -> StoreReviewResponse` |
| `invalidateCache` | `func invalidateCache() async` |

## 9b. Supporting types

These are declared outside the model layer but you will meet them in signatures.

### `RepositoryResult<Value>`

What every `…Result` method returns.

| Property | Type | Meaning |
|---|---|---|
| `value` | `Value` | The data. Present even when the call failed, if a stale cache could serve it |
| `isStale` | `Bool` | `true` when `value` came from an expired cache rather than the network |
| `failure` | `SdkError?` | Why the network call failed, or `nil` if it did not |

### `SdkEnvironment`

Enum: `staging`, `testing`, `production`. Selects the API host together with `clientName`.

### `AuthState`

Enum describing the session: `authenticated(accessToken:refreshToken:expiresAt:)` or `unauthenticated`. Exposes `isAuthenticated`, `accessToken`, `refreshToken` and `isExpired`.

### `AuthProvider`

Enum: `apple`, `google`. Used by `loginWithProvider` and `registerWithProvider`.

### `OrdersPage`

Returned by `fetchOrdersPage` and `fetchOrdersPageResult`.

| Property | Type | Meaning |
|---|---|---|
| `orders` | `[Order]` | This page of orders |
| `totalCount` | `Int` | Total across all pages, for a count or a progress indicator |
| `hasMore` | `Bool` | Whether another page exists — use it to decide whether to fetch the next offset |

### `EsimplifiedSDKVersion`

`EsimplifiedSDKVersion.version` is the SDK version string. Useful in bug reports and diagnostics.

## 10. Model reference

Every type the SDK returns or accepts, with its Swift properties and the JSON keys they map to. A `?` means the field can be absent or null.

### `ApiErrorResponse`

| Property | Type | JSON key |
|---|---|---|
| `error` | `String?` | `error` |
| `detail` | `String?` | `detail` |
| `message` | `String?` | `message` |

### `ApiInvalid`

| Property | Type | JSON key |
|---|---|---|
| `message` | `String?` | `message` |

### `Author`

| Property | Type | JSON key |
|---|---|---|
| `name` | `String?` | `name` |
| `location` | `String?` | `location` |

### `ChangePasswordResponse`

| Property | Type | JSON key |
|---|---|---|
| `password_reset` | `Bool` | `password_reset` |

### `CheckStockResponse`

| Property | Type | JSON key |
|---|---|---|
| `stock` | `Bool` | `stock` |
| `package` | `Package` | `package` |
| `promoCode` | `PromoCodeResponse?` | `promo_code` |

### `CompanyStats`

| Property | Type | JSON key |
|---|---|---|
| `reviewCount` | `Int` | `review_count` |
| `averageRating` | `String` | `average_rating` |

### `ContentBlock`

Enum.

| Case | JSON value |
|---|---|
| `heading` | `heading` |
| `paragraph` | `paragraph` |
| `list` | `list` |
| `unknown` | `unknown` |

### `ContentDocument`

| Property | Type | JSON key |
|---|---|---|
| `language` | `String` | `language` |
| `id` | `String?` | `id` |
| `title` | `String?` | `title` |
| `description` | `String?` | `description` |
| `updatedAt` | `String?` | `updatedAt` |
| `blocks` | `[ContentBlock]` | `blocks` |
| `children` | `[ContentNode]` | `children` |

### `ContentList`

| Property | Type | JSON key |
|---|---|---|
| `ordered` | `Bool` | `ordered` |
| `marker` | `ContentListMarker` | `marker` |
| `items` | `[ContentListItem]` | `items` |

### `ContentListItem`

| Property | Type | JSON key |
|---|---|---|
| `text` | `String` | `text` |
| `items` | `[ContentListItem]` | `items` |
| `ordered` | `Bool?` | `ordered` |
| `marker` | `ContentListMarker?` | `marker` |

### `ContentListMarker`

Enum.

| Case | JSON value |
|---|---|
| `decimal` | `decimal` |
| `alpha` | `alpha` |
| `bullet` | `bullet` |

### `ContentNode`

| Property | Type | JSON key |
|---|---|---|
| `id` | `String?` | `id` |
| `title` | `String?` | `title` |
| `description` | `String?` | `description` |
| `updatedAt` | `String?` | `updatedAt` |
| `blocks` | `[ContentBlock]` | `blocks` |
| `children` | `[ContentNode]` | `children` |

### `Country`

| Property | Type | JSON key |
|---|---|---|
| `countryName` | `String` | `country_name` |
| `countryNameSlug` | `String` | `country_name_slug` |
| `countryCode` | `String` | `country_code` |
| `countryFlag` | `String` | `country_flag` |
| `countryFlagCss` | `String` | `country_flag_css` |
| `isRegion` | `Bool` | `is_region` |
| `fromPrice` | `String?` | `from_price` |
| `currency` | `String?` | `currency` |
| `currencyObject` | `Currency?` | `currency_obj` |

### `CountryResponse`

| Property | Type | JSON key |
|---|---|---|
| `count` | `Int` | `count` |
| `next` | `String?` | `next` |
| `previous` | `String?` | `previous` |
| `countries` | `[Country]` | `results` |

### `Currency`

| Property | Type | JSON key |
|---|---|---|
| `symbol` | `String` | `symbol` |
| `iso` | `String` | `iso` |

### `CustomerEmail`

| Property | Type | JSON key |
|---|---|---|
| `email` | `String` | `email` |

### `DefaultFalse`

| Property | Type | JSON key |
|---|---|---|
| `wrappedValue` | `Bool` | `wrappedValue` |

### `DeleteAccountResponse`

| Property | Type | JSON key |
|---|---|---|
| `deleted` | `Bool` | `deleted` |

### `DestinationFaqResponse`

| Property | Type | JSON key |
|---|---|---|
| `slug` | `String` | `slug` |
| `name` | `String` | `name` |
| `language` | `String` | `language` |
| `faqs` | `[Faq]` | `faqs` |

### `Esim`

| Property | Type | JSON key |
|---|---|---|
| `iccid` | `String` | `iccid` |
| `country` | `Country?` | `country` |
| `orderUUID` | `String?` | `order_uuid` |
| `androidSha` | `Bool` | `android_sha` |
| `archived` | `Bool` | `archived` |
| `orderNumber` | `String?` | `order_number` |
| `assignedDate` | `String` | `assigned_date` |
| `packageDetails` | `[PackageDetail]?` | `package_details` |
| `dataUsageRemainingBytes` | `Int` | `data_usage_remaining_bytes` |
| `dataUsageRemainingGigabytes` | `Double` | `data_usage_remaining_gigabytes` |
| `dateActivatedEpoch` | `Int?` | `date_activated_epoch` |
| `dateExpiryEpoch` | `Int?` | `date_expiry_epoch` |
| `daysLeftToExpiry` | `Int?` | `days_left_to_expiry` |
| `profile` | `EsimProfile?` | `profile` |
| `esimName` | `String?` | `esim_name` |
| `autoTopUp` | `Bool` | `auto_top_up` |
| `isPrimary` | `Bool` | `is_primary` |
| `isUniversal` | `Bool` | `is_universal` |
| `smDpAddress` | `String?` | `sm_dp_address` |
| `activationCode` | `String?` | `activation_code` |
| `qrCodeImageBase64` | `String?` | `qr_code_image_base64` |
| `esimProvider` | `String?` | `esim_provider` |

### `EsimInfo`

| Property | Type | JSON key |
|---|---|---|
| `iccid` | `String` | `iccid` |
| `country` | `String` | `country` |
| `matchingID` | `String` | `matching_id` |
| `androidSha` | `Bool` | `android_sha` |
| `smDpAddress` | `String` | `sm_dp_address` |
| `assignedDate` | `String` | `assigned_date` |
| `premium` | `Bool` | `premium` |
| `esimName` | `String?` | `esim_name` |
| `isUniversal` | `Bool` | `is_universal` |

### `EsimOrderState`

Enum.

| Case | JSON value |
|---|---|
| `buy` | `BUY` |
| `topUP` | `TOP UP` |
| `autoTopUp` | `AUTO TOP UP` |
| `complimentary` | `Complimentary` |

### `EsimProfile`

| Property | Type | JSON key |
|---|---|---|
| `state` | `String` | `state` |
| `lastOperationDate` | `Int` | `last_operation_date` |
| `activationCode` | `String?` | `activation_code` |
| `reuseRemainingCount` | `Int` | `reuse_remaining_count` |
| `reuseEnabled` | `Bool` | `reuse_enabled` |
| `ccRequired` | `Bool` | `cc_required` |
| `releaseDate` | `Int` | `release_date` |
| `stateMessage` | `String` | `state_message` |
| `lastOperationDateUTC` | `String` | `last_operation_date_utc` |
| `releaseDateUTC` | `String` | `release_date_utc` |

### `EsimStatus`

Enum.

| Case | JSON value |
|---|---|
| `enabled` | `ENABLED` |
| `installed` | `INSTALLED` |
| `downloaded` | `DOWNLOADED` |
| `released` | `RELEASED` |
| `disabled` | `DISABLED` |
| `error` | `ERROR` |
| `deleted` | `DELETED` |

### `EsimsResponse`

| Property | Type | JSON key |
|---|---|---|
| `count` | `Int` | `count` |
| `next` | `String?` | `next` |
| `previous` | `String?` | `previous` |
| `esims` | `[Esim]` | `results` |

### `Faq`

| Property | Type | JSON key |
|---|---|---|
| `question` | `String` | `question` |
| `answer` | `String` | `answer` |

### `ForgotPasswordResponse`

| Property | Type | JSON key |
|---|---|---|
| `email` | `String` | `email` |
| `detail` | `String` | `detail` |
| `customerID` | `String?` | `customer_id` |

### `KredsLoyaltyBalanceResponse`

| Property | Type | JSON key |
|---|---|---|
| `totalLoyaltyPoints` | `Int` | `total_loyalty_points` |
| `totalLoyaltyPointsDetail` | `LoyaltyPointsDetail` | `total_loyalty_points_detail` |

### `KredsQuoteNotice`

| Property | Type | JSON key |
|---|---|---|
| `code` | `String` | `code` |
| `message` | `String` | `message` |

### `KredsQuoteOrderCurrency`

| Property | Type | JSON key |
|---|---|---|
| `exchangeRateToUsd` | `String?` | `exchange_rate_to_usd` |
| `subtotal` | `String?` | `subtotal` |
| `packageDiscount` | `String?` | `package_discount` |
| `promoDiscount` | `String?` | `promo_discount` |
| `pointsApplied` | `String?` | `points_applied` |
| `total` | `String` | `total` |
| `currency` | `Currency?` | `currency` |

### `KredsQuotePoints`

| Property | Type | JSON key |
|---|---|---|
| `requestedCents` | `Int?` | `requested_cents` |
| `appliedCents` | `Int?` | `applied_cents` |
| `appliedValue` | `KredsQuoteValue?` | `applied_value` |
| `appliedValueUsd` | `KredsQuoteValue?` | `applied_value_usd` |
| `appliedValuePreferred` | `KredsQuoteValue?` | `applied_value_preferred` |

### `KredsQuotePreferredPricing`

| Property | Type | JSON key |
|---|---|---|
| `total` | `String` | `total` |
| `currency` | `Currency` | `currency` |

### `KredsQuotePricing`

| Property | Type | JSON key |
|---|---|---|
| `orderCurrency` | `KredsQuoteOrderCurrency` | `order_currency` |
| `usd` | `KredsQuoteUsdPricing` | `usd` |
| `preferredCurrency` | `KredsQuotePreferredPricing` | `preferred_currency` |

### `KredsQuoteRequest`

| Property | Type | JSON key |
|---|---|---|
| `package_type_id` | `Int` | `package_type_id` |
| `loyalty_points_amount` | `Double` | `loyalty_points_amount` |

### `KredsQuoteResponse`

| Property | Type | JSON key |
|---|---|---|
| `packageTypeID` | `Int?` | `package_type_id` |
| `currency` | `Currency?` | `currency` |
| `preferredCurrency` | `Currency?` | `preferred_currency` |
| `pricing` | `KredsQuotePricing` | `pricing` |
| `points` | `KredsQuotePoints` | `points` |
| `notices` | `[KredsQuoteNotice]?` | `notices` |

### `KredsQuoteUsdPricing`

| Property | Type | JSON key |
|---|---|---|
| `subtotal` | `String?` | `subtotal` |
| `packageDiscount` | `String?` | `package_discount` |
| `promoDiscount` | `String?` | `promo_discount` |
| `pointsApplied` | `String?` | `points_applied` |
| `total` | `String` | `total` |
| `currency` | `Currency` | `currency` |

### `KredsQuoteValue`

| Property | Type | JSON key |
|---|---|---|
| `amount` | `String` | `amount` |
| `currency` | `Currency` | `currency` |

### `LocationDetails`

| Property | Type | JSON key |
|---|---|---|
| `country` | `String?` | `country` |
| `countryCode` | `String?` | `countryCode` |
| `city` | `String?` | `city` |
| `lat` | `Double?` | `lat` |
| `lon` | `Double?` | `lon` |
| `timezone` | `String?` | `timezone` |

### `LoyaltyPointsDetail`

| Property | Type | JSON key |
|---|---|---|
| `amount` | `String` | `amount` |
| `amountLocalCurrency` | `String?` | `amount_local_currency` |
| `amountLocalCurrencyCents` | `Int?` | `amount_local_currency_cents` |
| `currency` | `Currency` | `currency` |
| `original` | `LoyaltyPointsOriginal?` | `original` |

### `LoyaltyPointsOriginal`

| Property | Type | JSON key |
|---|---|---|
| `amountUSD` | `String` | `amount_usd` |
| `currency` | `Currency` | `currency` |

### `LoyaltyProvider`

Enum.

| Case | JSON value |
|---|---|
| `kreds` | `kreds` |
| `mokafaa` | `mokafaa` |

### `MokafaaElection`

| Property | Type | JSON key |
|---|---|---|
| `elected` | `Bool` | `elected` |

### `MokafaaEnrollment`

| Property | Type | JSON key |
|---|---|---|
| `state` | `MokafaaEnrollmentState` | `state` |
| `sessionExpiresAt` | `String?` | `session_expires_at` |

### `MokafaaEnrollmentState`

Enum.

| Case | JSON value |
|---|---|
| `completed` | `completed` |
| `pending` | `pending` |
| `expired` | `expired` |
| `elected` | `elected` |
| `notElected` | `not_elected` |

### `MokafaaOtpInitiateRequest`

| Property | Type | JSON key |
|---|---|---|
| `purpose` | `MokafaaOtpPurpose` | `purpose` |
| `platform` | `String` | `platform` |

### `MokafaaOtpInitiateResponse`

| Property | Type | JSON key |
|---|---|---|
| `sessionId` | `String` | `session_id` |
| `expiresAt` | `String` | `expires_at` |
| `maskedPhoneNumber` | `String?` | `masked_phone_number` |

### `MokafaaOtpPurpose`

Enum.

| Case | JSON value |
|---|---|
| `enrollment` | `enrollment` |
| `checkout` | `checkout` |

### `MokafaaOtpStatus`

Enum.

| Case | JSON value |
|---|---|
| `confirmed` | `confirmed` |
| `reversed` | `reversed` |
| `failed` | `failed` |

### `MokafaaOtpValidateRequest`

| Property | Type | JSON key |
|---|---|---|
| `sessionId` | `String` | `session_id` |
| `otp` | `String` | `otp` |
| `points` | `Int?` | `points` |
| `packageTypeId` | `Int?` | `package_type_id` |

### `MokafaaOtpValidateResponse`

| Property | Type | JSON key |
|---|---|---|
| `status` | `MokafaaOtpStatus` | `status` |
| `pointsRedeemed` | `Int?` | `points_redeemed` |
| `pointsBalance` | `Int?` | `points_balance` |

### `NotificationSettings`

| Property | Type | JSON key |
|---|---|---|
| `type` | `String` | `type` |
| `enabled` | `Bool` | `enabled` |

### `Order`

| Property | Type | JSON key |
|---|---|---|
| `user` | `String` | `user` |
| `esim` | `EsimInfo` | `esim` |
| `orderNumber` | `Int` | `order_number` |
| `orderUUID` | `String` | `order_uuid` |
| `orderType` | `String` | `order_type` |
| `packageID` | `String` | `package_id` |
| `finalPrice` | `String` | `final_price` |
| `conversionTracked` | `Bool` | `conversion_tracked` |
| `packageName` | `String` | `package_name` |
| `purchaseDate` | `String` | `purchase_date` |
| `purchasePrice` | `String` | `purchase_price` |
| `discountCode` | `String` | `discount_code` |
| `discountAmount` | `String` | `discount_amount` |
| `purchaseCurrency` | `String` | `purchase_currency` |
| `purchaseCurrencyObject` | `Currency` | `purchase_currency_obj` |
| `paymentMethod` | `PaymentMethod` | `payment_method` |
| `purchaseCountry` | `PurchaseCountry?` | `purchase_country` |
| `packageTypeID` | `Int` | `package_type_id` |
| `paymentStatus` | `String` | `payment_status` |
| `country` | `Country?` | `country` |
| `loyaltyPointsEarned` | `LoyaltyPointsDetail?` | `points_earned` |
| `loyaltyPointsSpent` | `LoyaltyPointsDetail?` | `points_spent` |

### `OrderDetail`

| Property | Type | JSON key |
|---|---|---|
| `iccid` | `String?` | `iccid` |
| `qrCode` | `String?` | `qr_code` |
| `smDpAddress` | `String?` | `sm_dp_address` |
| `activationCode` | `String?` | `activation_code` |
| `countryName` | `String?` | `country_name` |
| `countryCode` | `String?` | `country_code` |
| `country` | `Country?` | `country` |
| `orderNumber` | `Int` | `order_number` |
| `orderType` | `String` | `order_type` |
| `orderDate` | `String` | `order_date` |
| `orderStatus` | `String` | `order_status` |
| `purchasePrice` | `String` | `purchase_price` |
| `transactionId` | `String?` | `transaction_id` |
| `purchaseCurrency` | `String` | `purchase_currency` |
| `purchaseCurrencyObject` | `Currency` | `purchase_currency_obj` |
| `packageName` | `String` | `package_name` |
| `packageTypeId` | `Int` | `package_type_id` |
| `packageDataSize` | `Double` | `package_data_size` |
| `packageValidity` | `Int` | `package_validity` |
| `discountAmount` | `String` | `discount_amount` |
| `finalPrice` | `String` | `final_price` |
| `discountCode` | `String` | `discount_code` |
| `customerId` | `String` | `customer_id` |
| `conversionTracked` | `Bool` | `conversion_tracked` |
| `passwordResetEncoded` | `String?` | `password_reset_encoded` |
| `paymentMethod` | `PaymentMethod` | `payment_method` |
| `package` | `Package` | `package` |
| `qrCodeImageBase64` | `String?` | `qr_code_image_base64` |
| `profile` | `EsimProfile?` | `profile` |
| `loyaltyPointsEarned` | `LoyaltyPointsDetail?` | `points_earned` |
| `loyaltyPointsSpent` | `LoyaltyPointsDetail?` | `points_spent` |

### `OrdersResponse`

| Property | Type | JSON key |
|---|---|---|
| `count` | `Int` | `count` |
| `next` | `String?` | `next` |
| `previous` | `String?` | `previous` |
| `orders` | `[Order]` | `results` |

### `Package`

| Property | Type | JSON key |
|---|---|---|
| `name` | `String` | `name` |
| `price` | `String` | `price` |
| `convertedPrice` | `Double?` | `converted_price` |
| `dataGB` | `String` | `data_GB` |
| `country` | `Country` | `country` |
| `network` | `[String]?` | `network` |
| `currency` | `String` | `currency` |
| `currencyObject` | `Currency` | `currency_obj` |
| `planType` | `String` | `plan_type` |
| `kycDisplay` | `String` | `kyc_display` |
| `packageSlug` | `String` | `package_slug` |
| `validityDays` | `Int` | `validity_days` |
| `validityDaysDisplay` | `String` | `validity_days_display` |
| `packageTypeID` | `Int` | `package_type_id` |
| `bestConnectivity` | `String` | `best_connectivity` |
| `activationPolicy` | `String` | `activation_policy` |
| `supportedCountries` | `[SupportedCountry]?` | `supported_countries` |
| `nameAdditionalText` | `String` | `name_additional_text` |
| `discountLabel` | `String` | `discount_label` |
| `discountedPrice` | `String?` | `discounted_price` |
| `discountPercentage` | `String?` | `discount_percentage` |
| `earnPercentage` | `Double?` | `earn_percentage` |
| `promoCode` | `PromoCodeResponse?` | `promo_code` |
| `dataCap` | `String?` | `data_cap` |
| `throttleSpeed` | `String?` | `throttle_speed` |

### `PackageDetail`

| Property | Type | JSON key |
|---|---|---|
| `status` | `String` | `status` |
| `dateCreatedEpoch` | `Int` | `date_created_epoch` |
| `windowActivationStartEpoch` | `Int` | `window_activation_start_epoch` |
| `windowActivationEndEpoch` | `Int` | `window_activation_end_epoch` |
| `voiceUsageRemainingSeconds` | `Int` | `voice_usage_remaining_seconds` |
| `smsUsageRemainingNums` | `Int` | `sms_usage_remaining_nums` |
| `timeAllowanceSeconds` | `Int` | `time_allowance_seconds` |
| `timeAllowanceDays` | `Int` | `time_allowance_days` |
| `packageCountryName` | `String?` | `package_country_name` |
| `packageCountryCode` | `String?` | `package_country_code` |
| `packageTypeID` | `Int` | `package_type_id` |
| `dateExpiryEpoch` | `Int?` | `date_expiry_epoch` |
| `dateTerminatedEpoch` | `Int?` | `date_terminated_epoch` |
| `dateActivatedEpoch` | `Int?` | `date_activated_epoch` |
| `dataAllowanceBytes` | `Int` | `data_allowance_bytes` |
| `dataUsageRemainingBytes` | `Int` | `data_usage_remaining_bytes` |
| `dataAllowanceGigabytes` | `Int` | `data_allowance_gigabytes` |
| `dataUsedBytes` | `Int?` | `data_usage_bytes` |
| `statusMessage` | `String` | `status_message` |

### `PackageResponse`

| Property | Type | JSON key |
|---|---|---|
| `count` | `Int` | `count` |
| `next` | `String?` | `next` |
| `previous` | `String?` | `previous` |
| `promoCode` | `PromoCodeResponse?` | `promo_code` |
| `packages` | `[Package]` | `results` |

### `PaymentData`

| Property | Type | JSON key |
|---|---|---|
| `uri` | `String?` | `uri` |
| `orderID` | `String?` | `order_id` |
| `isIntent` | `Bool?` | `is_intent` |
| `customerRef` | `String?` | `customer_ref` |
| `ephemeralKey` | `String?` | `ephemeral_key` |
| `publishableKey` | `String?` | `publishable_key` |
| `zeroCharge` | `Bool?` | `zero_charge` |

### `PaymentMethod`

Enum.

| Case | JSON value |
|---|---|
| `stripeIntent` | `stripe_intent` |
| `stripeCheckout` | `stripe_checkout` |
| `agentPayment` | `agent_payment` |
| `complimentary` | `complimentary` |
| `voucher` | `voucher` |
| `splitPayment` | `split_payment` |
| `paidWithPoints` | `pay_with_points` |
| `unknown` | `unknown` |

### `PaymentRequest`

| Property | Type | JSON key |
|---|---|---|
| `type` | `TransactionType` | `type` |
| `payment_method` | `PaymentMethod` | `payment_method` |
| `package_type_id` | `String` | `package_type_id` |
| `iccid` | `String?` | `iccid` |
| `coupon_id` | `String?` | `coupon_id` |
| `customer` | `CustomerEmail` | `customer` |
| `auto_top_up` | `Bool?` | `auto_top_up` |
| `save_payment_method` | `Bool?` | `save_payment_method` |
| `loyalty_points_amount` | `Double?` | `loyalty_points_amount` |

### `PaymentResponse`

| Property | Type | JSON key |
|---|---|---|
| `detail` | `String` | `detail` |
| `paymentData` | `PaymentData` | `data` |

### `PromoCodeResponse`

| Property | Type | JSON key |
|---|---|---|
| `isValid` | `Bool` | `valid` |
| `discountCode` | `String` | `discount_code` |
| `discountPercentage` | `Double` | `discount_percentage` |
| `detail` | `String` | `detail` |
| `productType` | `String?` | `product_type` |

### `PurchaseCountry`

| Property | Type | JSON key |
|---|---|---|
| `iso` | `String` | `iso` |
| `name` | `String` | `name` |
| `iso3` | `String` | `iso3` |
| `flag` | `String` | `flag` |
| `isRegion` | `Bool` | `is_region` |

### `Ratings`

| Property | Type | JSON key |
|---|---|---|
| `four` | `Int?` | `4` |
| `five` | `Int?` | `5` |

### `RedeemVisaResponse`

| Property | Type | JSON key |
|---|---|---|
| `redeemed` | `Bool?` | `redeemed` |
| `detail` | `String?` | `detail` |
| `redirectURL` | `String?` | `redirect_url` |

### `RegisterCustomerRequest`

| Property | Type | JSON key |
|---|---|---|
| `firstName` | `String` | `first_name` |
| `lastName` | `String` | `last_name` |
| `email` | `String` | `email` |
| `mobileNumber` | `String` | `phone_number` |
| `referredBy` | `String?` | `referred_by` |
| `password` | `String` | `password` |
| `marketingOptIn` | `Bool?` | `marketing_opt_in` |
| `loyaltyElection` | `LoyaltyProvider?` | `loyalty_election` |

### `RegisterCustomerResponse`

| Property | Type | JSON key |
|---|---|---|
| `message` | `String?` | `message` |
| `success` | `Bool` | `success` |
| `email` | `String` | `email` |
| `referralCode` | `String?` | `referral_code` |
| `mokafaa` | `MokafaaElection?` | `mokafaa` |

### `RestrictedCountry`

| Property | Type | JSON key |
|---|---|---|
| `countryCode` | `String` | `country_code` |
| `restrictionType` | `RestrictionType` | `restriction_type` |
| `restrictedFor` | `[RestrictedFor]?` | `restricted_for` |

### `RestrictedFor`

| Property | Type | JSON key |
|---|---|---|
| `countryCode` | `String` | `country_code` |
| `countryName` | `String` | `country_name` |

### `RestrictionType`

Enum.

| Case | JSON value |
|---|---|
| `global` | `global` |
| `local` | `local` |

### `Review`

| Property | Type | JSON key |
|---|---|---|
| `type` | `String?` | `type` |
| `typeLabel` | `String?` | `type_label` |
| `rating` | `Int?` | `rating` |
| `title` | `String?` | `title` |
| `comments` | `String?` | `comments` |
| `author` | `Author?` | `author` |
| `dateCreated` | `String?` | `date_created` |
| `timeAgo` | `String?` | `time_ago` |
| `sku` | `String?` | `sku` |

### `RewardType`

Enum.

| Case | JSON value |
|---|---|
| `unknown` | `unknown` |
| `discount` | `DISCOUNT` |
| `global` | `GLOBAL_ESIM` |

### `ServerErrorResponse`

| Property | Type | JSON key |
|---|---|---|
| `error` | `String?` | `error` |
| `errorDescription` | `String?` | `error_description` |

### `SignInCustomerResponse`

| Property | Type | JSON key |
|---|---|---|
| `accessToken` | `String` | `access_token` |
| `tokenExpiresIn` | `Int` | `expires_in` |
| `tokenType` | `String` | `token_type` |
| `scope` | `String` | `scope` |
| `refreshToken` | `String?` | `refresh_token` |
| `user` | `User?` | `user` |

### `Stats`

| Property | Type | JSON key |
|---|---|---|
| `company` | `CompanyStats?` | `company` |
| `ratings` | `Ratings?` | `ratings` |

### `StoreReviewResponse`

| Property | Type | JSON key |
|---|---|---|
| `reviews` | `[Review]?` | `reviews` |
| `stats` | `Stats?` | `stats` |
| `storeName` | `String?` | `store_name` |
| `verdict` | `String?` | `verdict` |
| `reviewCount` | `Int?` | `review_count` |
| `resultsCount` | `Int?` | `results_count` |
| `averageRating` | `String?` | `average_rating` |

### `SupportedCountry`

| Property | Type | JSON key |
|---|---|---|
| `countryName` | `String` | `country_name` |
| `countryCode` | `String` | `country_code` |

### `ThemeDestination`

| Property | Type | JSON key |
|---|---|---|
| `image` | `ThemeImage?` | `image` |
| `gallery` | `[String]?` | `gallery` |
| `countryCode` | `String?` | `countryCode` |

### `ThemeImage`

| Property | Type | JSON key |
|---|---|---|
| `url` | `String` | `url` |
| `accent` | `String?` | `accent` |

### `ThemePage`

| Property | Type | JSON key |
|---|---|---|
| `urlPath` | `String?` | `urlPath` |
| `featuredImage` | `ThemeImage?` | `featuredImage` |
| `color` | `String?` | `color` |

### `TrackedOrderResponse`

| Property | Type | JSON key |
|---|---|---|
| `detail` | `String` | `detail` |
| `conversionTracked` | `Bool` | `conversion_tracked` |

### `TransactionType`

Enum.

| Case | JSON value |
|---|---|
| `buy` | `buy` |
| `topUp` | `top-up` |

### `UpdateCustomerPreferencesRequest`

| Property | Type | JSON key |
|---|---|---|
| `preferredLanguage` | `String?` | `preferred_language` |
| `preferredCurrency` | `String?` | `preferred_currency` |

### `UpdateCustomerRequest`

| Property | Type | JSON key |
|---|---|---|
| `firstName` | `String?` | `first_name` |
| `lastName` | `String?` | `last_name` |
| `email` | `String?` | `new_email` |
| `phoneNumber` | `String?` | `phone_number` |
| `password` | `String?` | `password` |

### `UpdateCustomerResponse`

| Property | Type | JSON key |
|---|---|---|
| `updated` | `Bool` | `updated` |
| `customer` | `User?` | `customer` |

### `UpdateEsimResponse`

| Property | Type | JSON key |
|---|---|---|
| `message` | `String?` | `message` |

### `User`

| Property | Type | JSON key |
|---|---|---|
| `email` | `String?` | `email` |
| `phoneNumber` | `String?` | `phone_number` |
| `firstName` | `String?` | `first_name` |
| `lastName` | `String?` | `last_name` |
| `fullName` | `String?` | `full_name` |
| `referralCode` | `String?` | `referral_code` |
| `externalReference` | `String?` | `external_reference` |
| `acquisitionSource` | `String?` | `acquisition_source` |
| `customerId` | `String?` | `customer_id` |
| `receiveMarketingEmail` | `Bool?` | `receive_marketing_email` |
| `receiveMarketingPush` | `Bool?` | `receive_marketing_push` |
| `receiveAccountEmail` | `Bool?` | `receive_account_email` |
| `receiveAccountSms` | `Bool?` | `receive_account_sms` |
| `receiveAccountPush` | `Bool?` | `receive_account_push` |
| `receivePurchaseEmail` | `Bool?` | `receive_purchase_email` |
| `receivePurchasePush` | `Bool?` | `receive_purchase_push` |
| `receiveViberMessages` | `Bool?` | `receive_viber_messages` |
| `preferredLanguage` | `String?` | `preferred_language` |
| `preferredCurrency` | `String?` | `preferred_currency` |
| `signedInWithProvider` | `Bool?` | `signed_in_with_provider` |
| `loyaltyProvider` | `LoyaltyProvider?` | `loyalty_provider` |
| `mokafaaEnrollment` | `MokafaaEnrollment?` | `mokafaa_enrollment` |

### `UserLocationResponse`

| Property | Type | JSON key |
|---|---|---|
| `location` | `LocationDetails?` | `location` |

### `UserRegistrationRequest`

| Property | Type | JSON key |
|---|---|---|
| `firstName` | `String` | `firstName` |
| `lastName` | `String` | `lastName` |
| `email` | `String` | `email` |
| `mobileNumber` | `String` | `mobileNumber` |
| `password` | `String` | `password` |
| `marketingOptIn` | `Bool` | `marketingOptIn` |

### `VerifyEmailResponse`

| Property | Type | JSON key |
|---|---|---|
| `email` | `String` | `email` |
| `email_verified` | `Bool` | `email_verified` |

### `VisaRewardResponse`

| Property | Type | JSON key |
|---|---|---|
| `created` | `Bool?` | `created` |
| `token` | `String` | `token` |
| `iframeURL` | `String?` | `iframe_url` |
| `correlationId` | `String?` | `correlation_id` |
| `aliasId` | `String?` | `alias_id` |
| `eligible` | `Bool?` | `eligible` |
| `status` | `Int?` | `status` |

### `VisaValidateResponse`

| Property | Type | JSON key |
|---|---|---|
| `eligible` | `Bool` | `eligible` |
| `usedCount` | `Int?` | `used_count` |
| `rewardType` | `RewardType?` | `reward_type` |
| `allowedCount` | `Int?` | `allowed_count` |
| `remainingCount` | `Int?` | `remaining_count` |
| `redeemed` | `Bool?` | `redeemed` |
| `detail` | `String?` | `detail` |
| `validityDays` | `Int?` | `validity_days` |
| `dataGB` | `Int?` | `data_GB` |

### `VoucherRedeemRequest`

| Property | Type | JSON key |
|---|---|---|
| `voucherCode` | `String` | `voucher_code` |

### `VoucherRedeemResponse`

| Property | Type | JSON key |
|---|---|---|
| `redeemed` | `Bool` | `redeemed` |
| `redirectUrl` | `String?` | `redirect_url` |

---

## Support

Questions, credentials and environment access: your eSimplified contact. Bugs in the SDK itself: open an issue on the repository, and include the `debugDescription` of any `SdkError` you hit — for decoding failures it names the field that broke.

