//
//  EsimplifiedSdkInitTests.swift
//  EsimplifiedSDK
//  Created by Kieran on 2026/06/04.
//

import Testing
import Foundation
@testable import EsimplifiedSDK

@Suite("EsimplifiedSdk Initialization")
struct EsimplifiedSdkInitTests {

    @Test("Initialize with minimal config uses defaults")
    func minimalInit() {
        let sdk = EsimplifiedSdk.initialize(
            config: SdkConfig(
                environment: .staging,
                clientName: "test",
                clientId: "id",
                clientSecret: "secret"
            )
        )
        #expect(sdk.config.clientName == "test")
        #expect(sdk.config.environment == .staging)
        #expect(sdk.sessionProvider.getAuthState() == .unauthenticated)
    }

    @Test("Initialize with custom storage provider")
    func customStorage() {
        let storage = MockStorageProvider()
        let sdk = EsimplifiedSdk.initialize(
            config: SdkConfig(
                environment: .production,
                clientName: "test",
                clientId: "id",
                clientSecret: "secret"
            ),
            storageProvider: storage
        )
        #expect(sdk.config.environment == .production)
    }

    @Test("Caching is enabled by default")
    func cachingEnabled() {
        let config = SdkConfig(environment: .staging, clientName: "test", clientId: "id", clientSecret: "secret")
        #expect(config.enableCaching)
        #expect(config.defaultCacheTTL == 3600)
    }

    @Test("Caching can be disabled")
    func cachingDisabled() {
        let config = SdkConfig(environment: .staging, clientName: "test", clientId: "id", clientSecret: "secret", enableCaching: false)
        #expect(!config.enableCaching)
    }

    @Test("All 13 repositories are accessible")
    func allRepositories() {
        let sdk = EsimplifiedSdk.initialize(
            config: SdkConfig(
                environment: .staging,
                clientName: "test",
                clientId: "id",
                clientSecret: "secret"
            )
        )
        let _: AuthRepositoryType = sdk.authRepository
        let _: CountriesRepositoryType = sdk.countriesRepository
        let _: PackagesRepositoryType = sdk.packagesRepository
        let _: EsimsRepositoryType = sdk.esimsRepository
        let _: OrdersRepositoryType = sdk.ordersRepository
        let _: PaymentsRepositoryType = sdk.paymentsRepository
        let _: PromoCodeRepositoryType = sdk.promoCodeRepository
        let _: LoyaltyRepositoryType = sdk.loyaltyRepository
        let _: UserRepositoryType = sdk.userRepository
        let _: NotificationRepositoryType = sdk.notificationRepository
        let _: VisaRewardsRepositoryType = sdk.visaRewardsRepository
        let _: VouchersRepositoryType = sdk.vouchersRepository
        let _: StoreReviewRepositoryType = sdk.storeReviewRepository
    }
}
