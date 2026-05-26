# eSIMplified iOS SDK

Swift SDK for integrating the eSIMplified eSIM platform into iOS applications. Provides typed repository interfaces for authentication, eSIM management, package browsing, orders, payments, and more. All networking, authentication, and token management are handled internally — consuming apps interact only with clean Swift protocol interfaces.

**Package:** `https://github.com/eSimplified/esimplified-ios-sdk.git`

## Requirements

- iOS 17.5+
- Swift 5.0+
- Xcode 16+

## Installation

Add via Swift Package Manager in Xcode:

1. **File → Add Package Dependencies**
2. Enter: `https://github.com/eSimplified/esimplified-ios-sdk.git`
3. Select version rule: **Up to Next Major Version** from `1.0.0`

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/eSimplified/esimplified-ios-sdk.git", from: "1.0.0")
]
```

## Quick Start

### 1. Initialize the SDK

Call this once at app launch (e.g. in your `App.init()`):

```swift
import EsimplifiedSDK

let sdk = EsimplifiedSdk.initialize(
    config: SdkConfig(
        environment: .staging,
        clientName: "your-app",
        apiVersion: "v2",
        clientId: "your-client-id",
        clientSecret: "your-client-secret",
        awsWafToken: "your-waf-token",
        enableLogging: true
    ),
    sessionProvider: yourSessionProvider,
    customHeadersProvider: {
        var headers: [String: String] = [:]
        headers["accept-currency"] = "USD"
        headers["accept-language"] = "en"
        return headers
    }
)
```

### 2. Use repositories

```swift
// Fetch countries (unauthenticated)
let countries = await sdk.countriesRepository.fetchAllCountries()

// Fetch packages for a country (unauthenticated)
let packages = await sdk.packagesRepository.fetchPackagesForCountry(
    countryCode: "US",
    countryNameSlug: "united-states"
)

// Login
let response = try await sdk.authRepository.login(
    email: "user@example.com",
    password: "password"
)

// Fetch orders (authenticated)
let orders = await sdk.ordersRepository.fetchOrders(withLoyaltyPoints: false)
```

## SDK Structure

```
Sources/EsimplifiedSDK/
├── EsimplifiedSdk.swift              # SDK entry point (initialize + access repositories)
├── SdkConfig.swift                    # Configuration struct
├── Model/                             # Public domain models + response types
├── Repository/                        # Public protocol interfaces
│   └── Implementation/                # Internal concrete implementations
├── Network/                           # Internal — URLSession client, endpoints, error types
│   ├── HTTPClient.swift
│   ├── HTTPMethod.swift
│   ├── Endpoints.swift
│   ├── NetworkLogger.swift
│   └── SdkCache.swift
└── Auth/                              # Public protocols + internal defaults
    ├── SessionProvider.swift           # Public protocol
    ├── StorageProvider.swift           # Public protocol
    ├── AuthState.swift                 # Public enum
    ├── DefaultSessionProvider.swift    # Internal default
    └── DefaultStorageProvider.swift    # Internal default
```

## SdkConfig

```swift
SdkConfig(
    environment: SdkEnvironment,       // .staging or .production
    clientName: String,                 // Used to construct base URL
    apiVersion: String,                 // API version path segment (default: "v2")
    clientId: String,                   // OAuth2 client ID
    clientSecret: String,              // OAuth2 client secret
    awsWafToken: String,               // AWS WAF validation token (default: "")
    enableLogging: Bool,               // Enable request/response logging (default: false)
    enableCaching: Bool,               // Enable response caching (default: true)
    defaultCacheTTL: TimeInterval,     // Default cache TTL in seconds (default: 3600)
    customHeadersProvider: (() async -> [String: String])?  // Dynamic headers (default: nil)
)
```

**Base URL construction:**
- Staging: `https://{clientName}.stage.esimplified.io`
- Production: `https://api.{clientName}.com`

## All Models

Every model is a `Codable` struct in `EsimplifiedSDK`.

| Model | Description |
|---|---|
| `User` | Authenticated user profile (email, name, phone, referral code, preferences) |
| `SignInCustomerResponse` | Login response (access token, refresh token, expiry, user) |
| `RegisterCustomerRequest` | Registration request (name, email, phone, password, marketing opt-in) |
| `RegisterCustomerResponse` | Registration result (success, email, referral code) |
| `UpdateCustomerRequest` | Profile update request (name, email, phone, password) |
| `UpdateCustomerResponse` | Profile update result (updated flag, customer) |
| `UpdateCustomerPreferencesRequest` | Preference update (language, currency) |
| `ForgotPasswordResponse` | Forgot password result (email, detail, customer ID) |
| `ChangePasswordResponse` | Password change/reset result |
| `VerifyEmailResponse` | Email verification result (email, verified flag) |
| `DeleteAccountResponse` | Account deletion result |
| `Country` | Destination country (name, code, flag, slug, region, pricing) |
| `CountryResponse` | Paginated country list response |
| `Currency` | Currency with symbol and ISO code |
| `SupportedCountry` | Minimal country reference (name + code) within a package |
| `Package` | eSIM data plan (name, price, data, validity, networks, discounts) |
| `PackageResponse` | Paginated package list with optional promo code |
| `CheckStockResponse` | Stock availability check result |
| `Esim` | Full eSIM assigned to a customer (ICCID, packages, balance, settings) |
| `EsimsResponse` | Paginated eSIM list response |
| `EsimProfile` | eSIM profile state from SM-DP+ platform |
| `PackageDetail` | Detailed package info with activation status and expiry |
| `Order` | Order summary (number, UUID, pricing, eSIM, payment method, loyalty) |
| `OrderDetail` | Full order with QR code, activation code, SM-DP+ address, package |
| `OrdersResponse` | Paginated order list response |
| `EsimInfo` | Basic eSIM metadata (ICCID, matching ID, SM-DP+ address) |
| `PurchaseCountry` | Country info on an order (ISO, name, flag, region) |
| `PaymentData` | Payment intent result (URI, order ID, ephemeral key, publishable key) |
| `PaymentResponse` | Payment response wrapper |
| `PaymentRequest` | Payment intent creation payload |
| `PaymentMethod` | Enum: stripeIntent, stripeCheckout, agentPayment, complimentary, voucher, splitPayment, paidWithPoints |
| `TransactionType` | Enum: buy, topUp |
| `CustomerEmail` | Email-only payload for payment requests |
| `PromoCodeResponse` | Promo code result (valid, code, discount percentage, product type) |
| `KredsLoyaltyBalanceResponse` | Loyalty balance (total points + detail) |
| `LoyaltyPointsDetail` | Points detail (amount, currency, local currency, original USD) |
| `KredsQuoteResponse` | Kreds discount quote (pricing, points, notices) |
| `KredsQuoteRequest` | Quote request (package type ID, points amount) |
| `NotificationSettings` | Notification preference (type + enabled flag) |
| `VisaRewardResponse` | Visa rewards iframe URL and token |
| `VisaValidateResponse` | Visa reward eligibility (used count, reward type, remaining) |
| `RedeemVisaResponse` | Visa reward redemption result (redeemed, redirect URL) |
| `VoucherRedeemRequest` | Voucher code redemption request |
| `VoucherRedeemResponse` | Voucher redemption result (redeemed, redirect URL) |
| `StoreReviewResponse` | App store rating data (reviews, stats, average rating) |
| `UserLocationResponse` | User's detected location (country, city, coordinates) |
| `LocationDetails` | Location detail (country, country code, city, lat, lon, timezone) |
| `RestrictedCountry` | Country with purchase restrictions (code, type, restricted for) |
| `ApiErrorResponse` | API error response (error, detail) — used for non-auth endpoints |
| `ServerErrorResponse` | OAuth2 error response (error, error_description) — used for auth endpoint |
| `TrackedOrderResponse` | Order tracking result (conversion tracked) |
| `UpdateEsimResponse` | eSIM update result (message) |

## All Repository Methods

All repositories are accessed as properties on the `EsimplifiedSdk` instance.

### AuthRepository

Authentication, registration, password management, and profile operations.

| Method | Signature | Description |
|---|---|---|
| `login` | `func login(email: String, password: String) async throws -> SignInCustomerResponse` | Authenticate with email/password |
| `loginWithProvider` | `func loginWithProvider(firstName: String, lastName: String, fullName: String, email: String, provider: AuthProvider, providerAccountId: String, idToken: String) async throws -> SignInCustomerResponse` | Authenticate via Apple/Google Sign-In |
| `register` | `func register(request: RegisterCustomerRequest) async throws -> RegisterCustomerResponse` | Create a new customer account |
| `forgotPassword` | `func forgotPassword(email: String) async throws -> ForgotPasswordResponse` | Request a password reset email |
| `changePassword` | `func changePassword(email: String, currentPassword: String, newPassword: String) async throws -> ChangePasswordResponse` | Change password for authenticated user |
| `resetPassword` | `func resetPassword(email: String, token: String, newPassword: String) async throws -> ChangePasswordResponse` | Reset password using email token |
| `verifyEmail` | `func verifyEmail(email: String?, token: String?, orderUUID: String?) async throws -> VerifyEmailResponse` | Verify email address with token |
| `deleteAccount` | `func deleteAccount() async throws -> DeleteAccountResponse` | Delete the authenticated user's account |
| `refreshSession` | `func refreshSession() async throws -> SignInCustomerResponse` | Force a token refresh (e.g. for Face ID login, auth state validation) |
| `logout` | `func logout() throws` | Clear stored session and tokens |

### CountriesRepository

Destination country browsing and search.

| Method | Signature | Description |
|---|---|---|
| `fetchAllCountries` | `func fetchAllCountries(forceRefresh: Bool = false) async -> [Country]` | Fetch all supported destination countries |
| `searchCountries` | `func searchCountries(searchTerm: String) async -> [Country]` | Search countries by name |

### PackagesRepository

eSIM data package browsing and stock checks.

| Method | Signature | Description |
|---|---|---|
| `fetchPackagesForCountry` | `func fetchPackagesForCountry(countryCode: String?, countryNameSlug: String, forceRefresh: Bool = false) async -> PackageResponse?` | Fetch packages for a destination |
| `fetchPackagesForTopUpEsim` | `func fetchPackagesForTopUpEsim(iccid: String, forceRefresh: Bool = false) async -> [Package]` | Fetch top-up packages for an existing eSIM |
| `fetchCheckStockForPackage` | `func fetchCheckStockForPackage(packageTypeId: Int, forceRefresh: Bool = false) async -> CheckStockResponse?` | Check if a specific package is in stock |

### EsimsRepository

eSIM lifecycle management for authenticated users.

| Method | Signature | Description |
|---|---|---|
| `fetchEsims` | `func fetchEsims(archivedEsims: Bool, forceRefresh: Bool = false) async -> [Esim]` | Fetch all eSIMs assigned to the customer |
| `fetchEsimDetails` | `func fetchEsimDetails(iccid: String, forceRefresh: Bool = false) async -> Esim?` | Fetch a specific eSIM by ICCID |
| `updateEsimName` | `func updateEsimName(customName: String, iccid: String) async -> Bool` | Update eSIM display name |
| `updateEsimAutoTopUpStatus` | `func updateEsimAutoTopUpStatus(status: Bool, iccid: String) async -> Bool` | Toggle eSIM auto top-up |
| `updateEsimArchivedStatus` | `func updateEsimArchivedStatus(status: Bool, iccid: String) async -> Bool` | Archive/unarchive an eSIM |

### OrdersRepository

Order history and tracking.

| Method | Signature | Description |
|---|---|---|
| `fetchOrders` | `func fetchOrders(forceRefresh: Bool = false, withLoyaltyPoints: Bool) async -> [Order]` | Fetch all past orders |
| `fetchOrder` | `func fetchOrder(orderUUID: String, forceRefresh: Bool = false) async throws -> OrderDetail` | Fetch full order details (polls pending orders) |
| `trackedOrder` | `func trackedOrder(orderUUID: String) async` | Mark an order's conversion as tracked |

### PaymentsRepository

Payment intent creation for Stripe checkout.

| Method | Signature | Description |
|---|---|---|
| `fetchPayment` | `func fetchPayment(transactionType: TransactionType, packageTypeId: Int, iccid: String?, autoTopUp: Bool, savePaymentDetail: Bool, loyaltyPointsAmount: Double?) async throws -> PaymentData` | Create a payment intent for checkout |
| `sendKredsQuote` | `func sendKredsQuote(packageTypeId: Int, loyaltyPointsAmount: Double) async throws -> KredsQuoteResponse` | Get a discount quote for applying Kreds to a package |

### PromoCodeRepository

Promotional code management.

| Method | Signature | Description |
|---|---|---|
| `fetchPromocode` | `func fetchPromocode() async throws -> PromoCodeResponse` | Retrieve the currently applied promo code |
| `applyPromocode` | `func applyPromocode(code: String) async throws -> PromoCodeResponse` | Apply a promo code to the customer's account |
| `deletePromocode` | `func deletePromocode(code: String) async throws -> PromoCodeResponse` | Remove the applied promo code |

### LoyaltyRepository

Kreds loyalty program balance.

| Method | Signature | Description |
|---|---|---|
| `fetchKredsBalance` | `func fetchKredsBalance(forceRefresh: Bool) async throws -> KredsLoyaltyBalanceResponse` | Fetch the customer's current Kreds balance |

### UserRepository

User profile and location.

| Method | Signature | Description |
|---|---|---|
| `updateProfile` | `func updateProfile(_ request: UpdateCustomerRequest) async throws -> UpdateCustomerResponse` | Update profile fields |
| `updatePreferences` | `func updatePreferences(_ request: UpdateCustomerPreferencesRequest) async throws -> User` | Update language/currency preferences |
| `fetchUserLocation` | `func fetchUserLocation() async throws -> UserLocationResponse` | Detect user's current country via IP |

### NotificationRepository

Push notification settings management.

| Method | Signature | Description |
|---|---|---|
| `fetchNotificationSettings` | `func fetchNotificationSettings() async -> [NotificationSettings]` | Fetch notification preferences |
| `updateNotificationSettings` | `func updateNotificationSettings(settings: [NotificationSettings]) async throws` | Update notification preferences |

### VisaRewardsRepository

Visa rewards verification and activation flow.

| Method | Signature | Description |
|---|---|---|
| `fetchVisaReward` | `func fetchVisaReward(isEU: Bool) async throws -> VisaRewardResponse?` | Get the Visa verification iframe URL |
| `fetchVisaValidation` | `func fetchVisaValidation(token: String) async throws -> VisaValidateResponse?` | Verify a Visa reward token |
| `redeemVisaReward` | `func redeemVisaReward(token: String, body: [String: String]) async throws -> RedeemVisaResponse` | Activate a verified Visa reward |

### StoreReviewRepository

App store review data.

| Method | Signature | Description |
|---|---|---|
| `fetchStoreReview` | `func fetchStoreReview() async throws -> StoreReviewResponse` | Fetch app store rating data |

### VouchersRepository

Voucher code redemption.

| Method | Signature | Description |
|---|---|---|
| `redeemVoucher` | `func redeemVoucher(code: String) async throws -> VoucherRedeemResponse` | Redeem a voucher code |

## Authentication Flow

The SDK handles the complete authentication lifecycle internally.

### Login

```
App calls authRepository.login(email, password)
  → SDK sends POST /auth/token/ (grant_type=password, Basic auth)
  → API returns access_token, refresh_token, expires_in, user
  → SDK saves tokens via SessionProvider.saveAuthState(.authenticated(...))
  → Returns SignInCustomerResponse to the app
```

### Token Storage

The SDK delegates token persistence to the `SessionProvider` protocol. The consuming app implements this protocol to store tokens however it prefers (Keychain, UserDefaults, etc.). A default in-memory implementation is provided if no custom provider is supplied.

### Automatic Token Refresh

The `HTTPClient` handles token refresh transparently:

1. Every authenticated API request includes a `Bearer` token
2. If the API returns `401` or `403`, the SDK automatically:
   - Sends a refresh token request to `POST /auth/token/` (grant_type=refresh_token)
   - Updates the stored tokens via `SessionProvider.saveAuthState()`
   - Retries the original request with the new access token
3. If the refresh also fails, `SdkError.authenticationRequired` is thrown

The SDK also adds:
- `Authorization: Basic {base64(clientId:clientSecret)}` for unauthenticated requests
- `x-auth-validation` header (AWS WAF token)
- Custom headers from `customHeadersProvider` (e.g. currency, language)

### Auth State

```swift
public enum AuthState: Equatable {
    case authenticated(accessToken: String, refreshToken: String, expiresAt: Date)
    case unauthenticated
}
```

Check auth state via:
- `sessionProvider.getAuthState() -> AuthState`
- `sessionProvider.getAccessToken() -> String?`
- `sessionProvider.getRefreshToken() -> String?`

### Logout

```swift
try sdk.authRepository.logout()
```

Clears stored session via `SessionProvider.clearSession()`.

## Custom Session Provider

By default the SDK uses an in-memory session provider. To persist tokens across app launches, implement `SessionProvider` and pass it during initialization:

```swift
class MySessionProvider: SessionProvider {
    func saveAuthState(_ state: AuthState) throws { /* save to Keychain */ }
    func getAuthState() -> AuthState { /* read from Keychain */ }
    func getAccessToken() -> String? { /* ... */ }
    func getRefreshToken() -> String? { /* ... */ }
    func getUserEmail() -> String? { /* ... */ }
    func clearSession() throws { /* clear Keychain */ }

    // Optional callbacks (default no-op implementations provided)
    func onTokenRefreshed(response: SignInCustomerResponse) { /* sync user data after refresh */ }
    func onAuthenticationFailed() { /* handle sign-out / UI update */ }
}

let sdk = EsimplifiedSdk.initialize(
    config: config,
    sessionProvider: MySessionProvider()
)
```

## Custom Storage Provider

For custom data persistence, implement `StorageProvider`:

```swift
class MyStorage: StorageProvider {
    func save(_ value: String, forKey key: String) throws { /* ... */ }
    func retrieve(forKey key: String) -> String? { /* ... */ }
    func delete(forKey key: String) throws { /* ... */ }
    func clear() throws { /* ... */ }
}

let sdk = EsimplifiedSdk.initialize(
    config: config,
    storageProvider: MyStorage()
)
```

## Error Handling

All SDK errors are thrown as `SdkError`:

```swift
public enum SdkError: Error, LocalizedError {
    case networkError(statusCode: Int, message: String)  // HTTP error with backend message
    case decodingError(Error)                             // JSON decode failure
    case authenticationRequired                           // Token refresh failed, user must re-login
    case noInternetConnection                             // No network
    case serverError(String)                              // Generic server error
    case missingCredentials                                // SDK not configured
    case invalidURL                                        // URL construction failed
    case unknown(Error)                                    // Unexpected error
}
```

### Error message extraction

The SDK parses backend error responses differently based on the endpoint:

- **Auth endpoint** (`/auth/token/`): Parses `ServerErrorResponse` with `error` + `error_description` (OAuth2 standard). The `error_description` field contains the user-friendly message (e.g., "Invalid credentials: incorrect email or password").
- **All other endpoints**: Parses `ApiErrorResponse` with `error` + `detail`. The `detail` field contains the user-friendly message.

`SdkError.networkError.message` always contains the best available message — `error_description` for auth errors, `detail` for API errors, falling back to the raw `error` code if neither is present.

### Handling errors in the app

```swift
do {
    let response = try await sdk.authRepository.login(email: email, password: password)
} catch let error as SdkError {
    switch error {
    case .authenticationRequired:
        // Token refresh failed — redirect to login
    case .networkError(let statusCode, let message):
        // Show message to user (already user-friendly from backend)
        showAlert(title: "Error", message: message)
    default:
        showAlert(title: "Error", message: error.localizedDescription)
    }
} catch {
    showAlert(title: "Error", message: "An unexpected error occurred.")
}
```

## Development Workflow

### Making SDK Changes

1. Clone the SDK repository alongside the app:
   ```bash
   git clone git@github.com:eSimplified/esimplified-ios-sdk.git
   ```

2. Make your changes in the SDK source code.

3. Commit, tag, and push:
   ```bash
   git add -A
   git commit -m "feat: add new repository method"
   git tag 1.0.2
   git push origin main --tags
   ```

4. In the consuming app, update the package:
   - Right-click **esimplified-ios-sdk** in Package Dependencies → **Update Package**

### Build Commands

```bash
# Build the SDK (verifies compilation)
swift build

# Run tests
swift test

# Clean build
swift package clean && swift build
```

## Versioning

The SDK follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.x.x) — Breaking API changes (removed/renamed repository methods, model field changes that break decoding)
- **MINOR** (x.1.x) — New features (new repository methods, new model classes, new optional parameters)
- **PATCH** (x.x.1) — Bug fixes, internal improvements, documentation updates

The version is defined in `EsimplifiedSDK.swift`:

```swift
public enum EsimplifiedSDKVersion {
    public static let version = "1.1.5"
}
```

When bumping the version:
1. Update `version` in `EsimplifiedSDK.swift`
2. Commit, tag with the new version, and push
3. Update the package in consuming apps

## Tech Stack

| Library | Purpose |
|---|---|
| Swift 5.0 | Language |
| Foundation | JSON encoding/decoding, URLSession networking |
| Swift Concurrency | async/await for all API calls |
| URLSession | HTTP transport |

## Git Workflow

### Branching Model

```
main (production)
  ├── feature/FeatureNameTicketNumber
  └── bugfix/BugNameTicketNumber
```

### Flow

1. Create `feature/` or `bugfix/` branch from `main`
2. Work on branch, commit changes
3. PR into `main`
4. After merge, bump version in `EsimplifiedSDK.swift`
5. Tag the release (e.g., `1.1.0`)
6. Push with `git push origin main --tags`

### Commit Messages

Use conventional commits: `feat:`, `fix:`, `chore:`, `refactor:`, `test:`, `docs:`, `build:`

## License

Proprietary. All rights reserved.
