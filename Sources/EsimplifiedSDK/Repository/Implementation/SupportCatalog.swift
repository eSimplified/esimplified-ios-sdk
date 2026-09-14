//
//  SupportCatalog.swift
//  EsimplifiedSDK
//  Created by Zivaiishe Kanengoni on 2026/09/09.
//

import Foundation

// MARK: Support Catalog Category

struct SupportCatalogCategory: Hashable, Sendable {

    let id: String
    let articles: [String]
}

// MARK: Support Catalog

enum SupportCatalog {

    static let categories: [SupportCatalogCategory] = [
        SupportCatalogCategory(
            id: "about",
            articles: [
                "can-i-make-phone-calls-or-send-text-messages-with-a-knowroaming-esim",
                "can-i-use-an-esim-and-physical-sim-at-the-same-time-dual-sim",
                "how-do-i-download-the-knowroaming-app",
                "how-do-i-receive-calls-and-texts-when-using-a-travel-esim",
                "how-do-i-pay-for-my-esim",
                "what-is-an-esim",
                "what-is-data-roaming",
                "what-is-knowroaming",
                "what-is-the-difference-between-an-esim-and-a-physical-sim-card"
            ]
        ),
        SupportCatalogCategory(
            id: "installation",
            articles: [
                "can-i-install-my-esim-on-multiple-devices",
                "can-i-transfer-my-esim-to-another-device",
                "do-i-need-internet-or-wi-fi-to-activate-an-esim",
                "how-do-i-install-and-activate-an-esim-on-my-android-device",
                "how-do-i-install-and-activate-an-esim-on-my-iphone-device",
                "how-do-i-install-and-activate-an-esim-on-the-web-on-desktop-or-mobile",
                "how-to-label-your-esim",
                "how-to-turn-off-your-esim-when-you-return-home",
                "how-do-i-turn-roaming-on-iphone",
                "what-happens-if-i-delete-my-esim-can-i-reinstall-it"
            ]
        ),
        SupportCatalogCategory(
            id: "general",
            articles: [
                "are-esims-safe-and-secure-to-use",
                "can-i-buy-and-activate-an-esim-while-already-abroad",
                "can-i-use-an-esim-for-multiple-countries-on-one-trip",
                "do-i-need-to-show-id-or-passport-to-buy-an-esim",
                "how-do-esim-providers-ensure-network-uptime-in-all-countries",
                "how-do-i-avoid-roaming-charges-with-an-esim",
                "how-many-esims-can-i-store-on-my-phone",
                "should-i-choose-a-country-regional-or-global-plan",
                "what-is-low-data-mode",
                "what-is-tethering-also-called-hotspotting",
                "what-is-a-subscription-esim-plan",
                "how-does-the-subscription-billing-work",
                "do-i-need-to-install-a-new-esim-each-time-my-plan-renews",
                "can-i-cancel-my-subscription-at-any-time",
                "what-happens-if-i-cancel-my-subscription",
                "how-do-i-manage-my-subscription"
            ]
        ),
        SupportCatalogCategory(
            id: "pricing",
            articles: [
                "are-esim-plans-cheaper-than-traditional-sim-cards",
                "are-there-hidden-fees-with-knowroaming-esims",
                "are-unlimited-plans-truly-uncapped",
                "can-i-top-up-an-esim-or-do-i-need-to-buy-a-new-one",
                "how-do-i-check-my-esim-data-balance",
                "how-do-i-top-up-my-esim",
                "how-fast-is-5g-coverage-on-international-travel-esim-plans",
                "how-much-data-does-youtube-use",
                "what-happens-when-i-run-out-of-data-on-an-esim",
                "why-is-an-esim-better-than-paying-my-phone-provider-s-roaming-rate"
            ]
        ),
        SupportCatalogCategory(
            id: "troubleshooting",
            articles: [
                "can-i-buy-and-activate-an-esim-while-already-abroad-2",
                "how-do-i-find-out-if-my-phone-is-unlocked",
                "top-esim-troubleshooting-steps",
                "what-do-i-do-if-my-device-is-network-locked",
                "why-can-t-i-find-my-esim"
            ]
        ),
        SupportCatalogCategory(
            id: "programs",
            articles: [
                "does-knowroaming-have-an-affiliate-and-partnership-program",
                "how-to-stay-informed-about-upcoming-discounts-and-promotions",
                "how-do-i-enable-push-notifications-to-receive-account-alerts",
                "what-are-kreds",
                "how-do-i-earn-kreds",
                "how-do-i-know-how-many-kreds-i-have",
                "how-do-i-use-my-kreds",
                "do-kreds-expire",
                "how-does-the-referral-program-work",
                "is-there-a-minimum-spend-for-my-friend-to-trigger-my-reward",
                "where-do-i-find-my-referral-code",
                "what-is-mokafaa-and-how-does-it-work"
            ]
        )
    ]
}
