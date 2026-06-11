//
//  RepositoryTests.swift
//  EsimplifiedSDK
//

import Testing
import Foundation
@testable import EsimplifiedSDK

extension NetworkSuite {

    private func makeRepoEnv(
        initial: AuthState = .authenticated(accessToken: "a", refreshToken: "r", expiresAt: Date().addingTimeInterval(3600))
    ) -> (HTTPClient, SdkCache, RecordingSessionProvider, SdkConfig) {
        let config = SdkConfig(
            environment: .staging,
            clientName: "acme",
            clientId: "id",
            clientSecret: "secret"
        )
        let session = RecordingSessionProvider(initial: initial)
        let client = HTTPClient(config: config, sessionProvider: session, session: MockSession.make())
        let cache = SdkCache()
        return (client, cache, session, config)
    }

    // MARK: - Countries

    @Test("Countries: fetchAllCountries hits /countries with limit=1000")
    func countriesFetchAll() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"next":null,"previous":null,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = CountriesRepositoryImpl(client: client, cache: cache)
        let countries = await repo.fetchAllCountries()
        #expect(countries.isEmpty)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/countries") == true)
        let query = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
        #expect(query.contains(where: { $0.name == "limit" && $0.value == "1000" }))
    }

    @Test("Countries: fetchAllCountries returns expired cache on network failure")
    func countriesExpiredCacheFallback() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"server","detail":"down"}"#)

        let (client, cache, _, _) = makeRepoEnv()
        await cache.set("countries_all", value: [Country(countryName: "Cached")], ttl: 0.01)
        try? await Task.sleep(nanoseconds: 50_000_000)

        let repo = CountriesRepositoryImpl(client: client, cache: cache)
        let countries = await repo.fetchAllCountries()
        #expect(countries.count == 1)
        #expect(countries.first?.countryName == "Cached")
    }

    @Test("Countries: searchCountries hits /search with search_term")
    func countriesSearch() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"next":null,"previous":null,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = CountriesRepositoryImpl(client: client, cache: cache)
        _ = await repo.searchCountries(searchTerm: "canada")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/search") == true)
        let query = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
        #expect(query.contains(where: { $0.name == "search_term" && $0.value == "canada" }))
    }

    // MARK: - Packages

    @Test("Packages: fetchPackagesForCountry hits /packages")
    func packagesForCountry() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = PackagesRepositoryImpl(client: client, cache: cache)
        let response = await repo.fetchPackagesForCountry(countryCode: "US", countryNameSlug: "united-states")
        #expect(response != nil)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/packages") == true)
    }

    @Test("Packages: fetchPackagesForTopUpEsim returns empty on error")
    func packagesTopUpErrorEmpty() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = PackagesRepositoryImpl(client: client, cache: cache)
        let result = await repo.fetchPackagesForTopUpEsim(iccid: "1234567890")
        #expect(result.isEmpty)
    }

    // MARK: - Esims

    @Test("Esims: fetchEsims hits /customer/esims with archived param")
    func esimsFetch() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = EsimsRepositoryImpl(client: client, cache: cache)
        _ = await repo.fetchEsims(archivedEsims: true)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/esims") == true)
    }

    @Test("Esims: updateEsimName returns true on success and invalidates cache")
    func esimsUpdateName() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"message":"eSIM updated successfully"}"#)

        let (client, cache, _, _) = makeRepoEnv()
        await cache.set("esim_details_X", value: "stale", ttl: 3600)

        let repo = EsimsRepositoryImpl(client: client, cache: cache)
        let success = await repo.updateEsimName(customName: "My SIM", iccid: "X")
        #expect(success == true)

        let cached: String? = await cache.get("esim_details_X")
        #expect(cached == nil)
    }

    // MARK: - Orders

    @Test("Orders: fetchOrders hits /customer/orders")
    func ordersFetchAll() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)
        let orders = await repo.fetchOrders(withLoyaltyPoints: false)
        #expect(orders.isEmpty)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/orders") == true)
    }

    @Test("Orders: fetchOrders with loyalty points adds used_points=true")
    func ordersWithLoyaltyPoints() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: #"{"count":0,"results":[]}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)
        _ = await repo.fetchOrders(withLoyaltyPoints: true)

        let url = MockURLProtocol.capturedRequests.first?.url
        let query = url.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems } ?? []
        #expect(query.contains(where: { $0.name == "used_points" && $0.value == "true" }))
    }

    @Test("Orders: trackedOrder silently swallows errors")
    func ordersTrackedSilent() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = OrdersRepositoryImpl(client: client, cache: cache)
        await repo.trackedOrder(orderUUID: "uuid-abc")
        // No throw expected — silent failure
    }

    // MARK: - Payments

    @Test("Payments: fetchPayment hits /payments with POST")
    func paymentsCreate() async throws {
        MockURLProtocol.reset()
        let json = #"{"detail":"ok","data":{"uri":"pi_secret","order_id":"o1","is_intent":true}}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, session, _) = makeRepoEnv()
        let repo = PaymentsRepositoryImpl(client: client, sessionProvider: session)
        let data = try await repo.fetchPayment(
            transactionType: .buy,
            packageTypeId: 42,
            iccid: nil,
            autoTopUp: false,
            savePaymentDetail: true,
            loyaltyPointsAmount: nil
        )
        #expect(data.uri == "pi_secret")
        #expect(data.orderID == "o1")

        let captured = MockURLProtocol.capturedRequests.first
        #expect(captured?.httpMethod == "POST")
        #expect(captured?.url?.path.contains("/payments") == true)
    }

    @Test("Payments: sendKredsQuote hits /payments/quote")
    func paymentsKredsQuoteEndpoint() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 400, json: #"{"error":"x","detail":"sentinel"}"#)

        let (client, _, session, _) = makeRepoEnv()
        let repo = PaymentsRepositoryImpl(client: client, sessionProvider: session)

        do {
            _ = try await repo.sendKredsQuote(packageTypeId: 42, loyaltyPointsAmount: 10.0)
            Issue.record("Expected throw")
        } catch let SdkError.networkError(_, message) {
            #expect(message == "sentinel")
        }

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/payments/quote") == true)
    }

    // MARK: - PromoCode

    @Test("PromoCode: applyPromocode hits promo_code endpoint")
    func promoCodeApply() async throws {
        MockURLProtocol.reset()
        let json = #"{"valid":true,"discount_code":"SAVE","discount_percentage":0.1,"detail":"applied"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, _, _) = makeRepoEnv()
        let repo = PromoCodeRepositoryImpl(client: client)
        let response = try await repo.applyPromocode(code: "SAVE")
        #expect(response.isValid == true)
        #expect(response.discountCode == "SAVE")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("promo_code") == true)
    }

    @Test("PromoCode: deletePromocode uses DELETE method")
    func promoCodeDelete() async throws {
        MockURLProtocol.reset()
        let json = #"{"valid":false,"discount_code":"","discount_percentage":0,"detail":"removed"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, _, _) = makeRepoEnv()
        let repo = PromoCodeRepositoryImpl(client: client)
        _ = try await repo.deletePromocode(code: "SAVE")

        let req = MockURLProtocol.capturedRequests.first
        #expect(req?.httpMethod == "DELETE")
    }

    // MARK: - Loyalty / Mokafaa

    @Test("Loyalty: fetchKredsBalance hits /customer/loyalty")
    func loyaltyKredsBalance() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 400, json: #"{"error":"x","detail":"loyalty-hit"}"#)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = LoyaltyRepositoryImpl(client: client, cache: cache)

        do {
            _ = try await repo.fetchKredsBalance(forceRefresh: true, cacheTTL: 3600)
            Issue.record("Expected throw")
        } catch let SdkError.networkError(_, message) {
            #expect(message == "loyalty-hit")
        }

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/loyalty") == true)
    }

    @Test("Loyalty: initiateOtp hits mokafaa initiate endpoint")
    func mokafaaInitiate() async throws {
        MockURLProtocol.reset()
        let json = #"{"session_id":"sess-1","expires_at":"2026-12-31","masked_phone_number":"+966*****1234"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = LoyaltyRepositoryImpl(client: client, cache: cache)
        let response = try await repo.initiateOtp(purpose: .enrollment)
        #expect(response.sessionId == "sess-1")
        #expect(response.maskedPhoneNumber == "+966*****1234")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("loyalty/mokafaa/otp/initiate") == true)
    }

    @Test("Loyalty: validateOtp hits mokafaa validate endpoint and returns status")
    func mokafaaValidate() async throws {
        MockURLProtocol.reset()
        let json = #"{"status":"confirmed","points_redeemed":500,"points_balance":1500}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = LoyaltyRepositoryImpl(client: client, cache: cache)
        let response = try await repo.validateOtp(sessionId: "sess-1", otp: "123456", points: 500)
        #expect(response.status == .confirmed)
        #expect(response.pointsRedeemed == 500)
        #expect(response.pointsBalance == 1500)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("loyalty/mokafaa/otp/validate") == true)
    }

    // MARK: - User

    @Test("User: updatePreferences hits preferences endpoint")
    func userUpdatePreferences() async throws {
        MockURLProtocol.reset()
        let json = #"{"email":"a@b.com","preferred_language":"en","preferred_currency":"USD"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, _, _) = makeRepoEnv()
        let repo = UserRepositoryImpl(client: client)
        let user = try await repo.updatePreferences(
            UpdateCustomerPreferencesRequest(preferredLanguage: "en", preferredCurrency: "USD")
        )
        #expect(user.preferredLanguage == "en")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/preferences") == true)
    }

    @Test("User: fetchUserLocation hits get_country endpoint")
    func userFetchLocation() async throws {
        MockURLProtocol.reset()
        let json = #"{"location":{"country":"United Arab Emirates","countryCode":"AE","city":"Dubai"}}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, _, _) = makeRepoEnv()
        let repo = UserRepositoryImpl(client: client)
        let response = try await repo.fetchUserLocation()
        #expect(response.location?.countryCode == "AE")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/get_country") == true)
    }

    // MARK: - Notification

    @Test("Notification: fetchNotificationSettings returns empty on error")
    func notificationFetchErrorReturnsEmpty() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)

        let (client, _, _, _) = makeRepoEnv()
        let repo = NotificationRepositoryImpl(client: client)
        let settings = await repo.fetchNotificationSettings()
        #expect(settings.isEmpty)
    }

    @Test("Notification: updateNotificationSettings hits notifications endpoint")
    func notificationUpdate() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(json: "[]")

        let (client, _, _, _) = makeRepoEnv()
        let repo = NotificationRepositoryImpl(client: client)
        try await repo.updateNotificationSettings(settings: [NotificationSettings(type: "marketing", enabled: true)])

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/notifications") == true)
    }

    // MARK: - VisaRewards

    @Test("VisaRewards: fetchVisaReward returns nil on error (not throw)")
    func visaRewardReturnsNilOnError() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)

        let (client, _, _, _) = makeRepoEnv()
        let repo = VisaRewardsRepositoryImpl(client: client)
        let response = await repo.fetchVisaReward(isEU: false)
        #expect(response == nil)
    }

    @Test("VisaRewards: fetchVisaValidation returns nil on error (not throw)")
    func visaValidationReturnsNilOnError() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)

        let (client, _, _, _) = makeRepoEnv()
        let repo = VisaRewardsRepositoryImpl(client: client)
        let response = await repo.fetchVisaValidation(token: "abc")
        #expect(response == nil)
    }

    @Test("VisaRewards: redeemVisaReward throws on error (does throw)")
    func visaRedeemThrowsOnError() async throws {
        MockURLProtocol.reset()
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 400, json: #"{"error":"x","detail":"bad"}"#)

        let (client, _, _, _) = makeRepoEnv()
        let repo = VisaRewardsRepositoryImpl(client: client)
        await #expect(throws: SdkError.self) {
            _ = try await repo.redeemVisaReward(token: "tok", body: ["a": "b"])
        }
    }

    // MARK: - Vouchers

    @Test("Vouchers: redeemVoucher hits voucher endpoint and decodes response")
    func voucherRedeem() async throws {
        MockURLProtocol.reset()
        let json = #"{"redeemed":true,"redirect_url":"https://example.com/x"}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, _, _, _) = makeRepoEnv()
        let repo = VouchersRepositoryImpl(client: client)
        let response = try await repo.redeemVoucher(code: "VOUCHER123")
        #expect(response.redeemed == true)
        #expect(response.redirectUrl == "https://example.com/x")

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/customer/promotions/voucher") == true)
    }

    // MARK: - StoreReview

    @Test("StoreReview: fetchStoreReview hits /reviews and decodes")
    func storeReviewFetch() async throws {
        MockURLProtocol.reset()
        let json = #"{"average_rating":"4.5","review_count":1000}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = StoreReviewRepositoryImpl(client: client, cache: cache)
        let response = try await repo.fetchStoreReview(cacheTTL: 60)
        #expect(response.averageRating == "4.5")
        #expect(response.reviewCount == 1000)

        let url = MockURLProtocol.capturedRequests.first?.url
        #expect(url?.path.contains("/reviews") == true)
    }

    @Test("StoreReview: caches result on success")
    func storeReviewCaches() async throws {
        MockURLProtocol.reset()
        let json = #"{"average_rating":"4.5","review_count":1000}"#
        MockURLProtocol.handler = MockSession.jsonResponse(json: json)

        let (client, cache, _, _) = makeRepoEnv()
        let repo = StoreReviewRepositoryImpl(client: client, cache: cache)
        _ = try await repo.fetchStoreReview(cacheTTL: 60)

        // Second fetch should hit cache, not network
        MockURLProtocol.handler = MockSession.jsonResponse(statusCode: 500, json: #"{"error":"x","detail":"y"}"#)
        let cached = try await repo.fetchStoreReview(cacheTTL: 60)
        #expect(cached.averageRating == "4.5")
    }
}
