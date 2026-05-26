public enum EsimplifiedSDKVersion {
    public static let version = "1.1.5"
}

public final class EsimplifiedSdk {

    public let authRepository: AuthRepositoryType
    public let countriesRepository: CountriesRepositoryType
    public let packagesRepository: PackagesRepositoryType
    public let esimsRepository: EsimsRepositoryType
    public let ordersRepository: OrdersRepositoryType
    public let paymentsRepository: PaymentsRepositoryType
    public let promoCodeRepository: PromoCodeRepositoryType
    public let loyaltyRepository: LoyaltyRepositoryType
    public let userRepository: UserRepositoryType
    public let notificationRepository: NotificationRepositoryType
    public let visaRewardsRepository: VisaRewardsRepositoryType
    public let vouchersRepository: VouchersRepositoryType
    public let storeReviewRepository: StoreReviewRepositoryType

    public let sessionProvider: SessionProvider
    public let config: SdkConfig

    @discardableResult
    public static func initialize(
        config: SdkConfig,
        storageProvider: StorageProvider? = nil,
        sessionProvider: SessionProvider? = nil,
        customHeadersProvider: (() async -> [String: String])? = nil
    ) -> EsimplifiedSdk {
        let resolvedConfig = SdkConfig(
            environment: config.environment,
            clientName: config.clientName,
            apiVersion: config.apiVersion,
            clientId: config.clientId,
            clientSecret: config.clientSecret,
            awsWafToken: config.awsWafToken,
            enableLogging: config.enableLogging,
            enableCaching: config.enableCaching,
            defaultCacheTTL: config.defaultCacheTTL,
            customHeadersProvider: customHeadersProvider ?? config.customHeadersProvider
        )

        let storage = storageProvider ?? DefaultStorageProvider()
        let session = sessionProvider ?? DefaultSessionProvider(storage: storage)
        let client = HTTPClient(config: resolvedConfig, sessionProvider: session)

        return EsimplifiedSdk(config: resolvedConfig, client: client, sessionProvider: session)
    }

    private init(config: SdkConfig, client: HTTPClient, sessionProvider: SessionProvider) {
        self.config = config
        self.sessionProvider = sessionProvider

        let cache = config.enableCaching ? SdkCache(defaultTTL: config.defaultCacheTTL) : SdkCache(defaultTTL: 0)

        self.authRepository = AuthRepositoryImpl(client: client, sessionProvider: sessionProvider, config: config)
        self.countriesRepository = CountriesRepositoryImpl(client: client, cache: cache)
        self.packagesRepository = PackagesRepositoryImpl(client: client, cache: cache)
        self.esimsRepository = EsimsRepositoryImpl(client: client, cache: cache)
        self.ordersRepository = OrdersRepositoryImpl(client: client, cache: cache)
        self.paymentsRepository = PaymentsRepositoryImpl(client: client, sessionProvider: sessionProvider)
        self.promoCodeRepository = PromoCodeRepositoryImpl(client: client)
        self.loyaltyRepository = LoyaltyRepositoryImpl(client: client, cache: cache)
        self.userRepository = UserRepositoryImpl(client: client)
        self.notificationRepository = NotificationRepositoryImpl(client: client)
        self.visaRewardsRepository = VisaRewardsRepositoryImpl(client: client)
        self.vouchersRepository = VouchersRepositoryImpl(client: client)
        self.storeReviewRepository = StoreReviewRepositoryImpl(client: client, cache: cache)
    }
}
