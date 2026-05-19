//
//  EsimsResponse.swift
//  KnowRoaming
//
//  Created by Kieran on 2025/03/06.
//

import Foundation

// MARK: Esim Response

public struct EsimsResponse: Codable {
    public let count: Int
    public let next: String?
    public let previous: String?
    public let esims: [Esim]

    public init(count: Int, next: String? = nil, previous: String? = nil, esims: [Esim]) {
        self.count = count
        self.next = next
        self.previous = previous
        self.esims = esims
    }

    enum CodingKeys: String, CodingKey {
        case count, next, previous
        case esims = "results"
    }
}

// MARK: Esim Model

public struct Esim: Codable, Identifiable, Hashable {
    public var id: String { iccid }
    public let iccid: String
    public let country: Country?
    public let orderUUID: String?
    public let androidSha: Bool
    public let archived: Bool
    public let orderNumber: String?
    public let assignedDate: String
    public var packageDetails: [PackageDetail]?
    public var dataUsageRemainingBytes: Int
    public var dataUsageRemainingGigabytes: Double
    public let dateActivatedEpoch: Int?
    public let dateExpiryEpoch: Int?
    public let daysLeftToExpiry: Int?
    public var profile: EsimProfile?
    public let esimName: String?
    public let autoTopUp: Bool

    public init(iccid: String, country: Country? = nil, orderUUID: String? = nil, androidSha: Bool, archived: Bool, orderNumber: String? = nil, assignedDate: String, packageDetails: [PackageDetail]? = nil, dataUsageRemainingBytes: Int, dataUsageRemainingGigabytes: Double, dateActivatedEpoch: Int? = nil, dateExpiryEpoch: Int? = nil, daysLeftToExpiry: Int? = nil, profile: EsimProfile? = nil, esimName: String? = nil, autoTopUp: Bool) {
        self.iccid = iccid
        self.country = country
        self.orderUUID = orderUUID
        self.androidSha = androidSha
        self.archived = archived
        self.orderNumber = orderNumber
        self.assignedDate = assignedDate
        self.packageDetails = packageDetails
        self.dataUsageRemainingBytes = dataUsageRemainingBytes
        self.dataUsageRemainingGigabytes = dataUsageRemainingGigabytes
        self.dateActivatedEpoch = dateActivatedEpoch
        self.dateExpiryEpoch = dateExpiryEpoch
        self.daysLeftToExpiry = daysLeftToExpiry
        self.profile = profile
        self.esimName = esimName
        self.autoTopUp = autoTopUp
    }

    public var hasUnlimitedPackage: Bool {
        dataUsageRemainingGigabytes == -1
    }

    enum CodingKeys: String, CodingKey {
        case iccid, country, archived, profile
        case orderUUID = "order_uuid"
        case androidSha = "android_sha"
        case orderNumber = "order_number"
        case assignedDate = "assigned_date"
        case packageDetails = "package_details"
        case dataUsageRemainingBytes = "data_usage_remaining_bytes"
        case dataUsageRemainingGigabytes = "data_usage_remaining_gigabytes"
        case dateActivatedEpoch = "date_activated_epoch"
        case dateExpiryEpoch = "date_expiry_epoch"
        case daysLeftToExpiry = "days_left_to_expiry"
        case esimName = "esim_name"
        case autoTopUp = "auto_top_up"
    }
}

// MARK: Package Detail Model

public struct PackageDetail: Codable, Identifiable, Hashable {
    public var id = UUID()
    public let status: String
    public let dateCreatedEpoch: Int
    public let windowActivationStartEpoch: Int
    public let windowActivationEndEpoch: Int
    public let voiceUsageRemainingSeconds: Int
    public let smsUsageRemainingNums: Int
    public let timeAllowanceSeconds: Int
    public let timeAllowanceDays: Int
    public let packageCountryName: String?
    public let packageTypeID: Int
    public let dateExpiryEpoch: Int?
    public let dateTerminatedEpoch: Int?
    public let dateActivatedEpoch: Int?
    public let dataAllowanceBytes: Int
    public let dataUsageRemainingBytes: Int
    public let dataAllowanceGigabytes: Int
    public var dataUsedBytes: Int?
    public let statusMessage: String

    public init(status: String, dateCreatedEpoch: Int, windowActivationStartEpoch: Int, windowActivationEndEpoch: Int, voiceUsageRemainingSeconds: Int, smsUsageRemainingNums: Int, timeAllowanceSeconds: Int, timeAllowanceDays: Int, packageCountryName: String? = nil, packageTypeID: Int, dateExpiryEpoch: Int? = nil, dateTerminatedEpoch: Int? = nil, dateActivatedEpoch: Int? = nil, dataAllowanceBytes: Int, dataUsageRemainingBytes: Int, dataAllowanceGigabytes: Int, dataUsedBytes: Int? = nil, statusMessage: String) {
        self.status = status
        self.dateCreatedEpoch = dateCreatedEpoch
        self.windowActivationStartEpoch = windowActivationStartEpoch
        self.windowActivationEndEpoch = windowActivationEndEpoch
        self.voiceUsageRemainingSeconds = voiceUsageRemainingSeconds
        self.smsUsageRemainingNums = smsUsageRemainingNums
        self.timeAllowanceSeconds = timeAllowanceSeconds
        self.timeAllowanceDays = timeAllowanceDays
        self.packageCountryName = packageCountryName
        self.packageTypeID = packageTypeID
        self.dateExpiryEpoch = dateExpiryEpoch
        self.dateTerminatedEpoch = dateTerminatedEpoch
        self.dateActivatedEpoch = dateActivatedEpoch
        self.dataAllowanceBytes = dataAllowanceBytes
        self.dataUsageRemainingBytes = dataUsageRemainingBytes
        self.dataAllowanceGigabytes = dataAllowanceGigabytes
        self.dataUsedBytes = dataUsedBytes
        self.statusMessage = statusMessage
    }

    public var dataUsageRemainingGigabytes: Int {
        dataUsageRemainingBytes / 1073741824
    }

    public var dataUsedGigabytes: Int {
        guard let dataUsedBytes else { return 0 }
            return dataUsedBytes / 1073741824
    }

    public var hasUnlimitedPackage: Bool {
        dataAllowanceGigabytes == -1 || dataUsageRemainingGigabytes == -1
    }

    public var displayStatus: String {
        switch status {
        case "ACTIVE":
            return "Package Activated"
        case "TERMINATED":
            return "Package Expired"
        case "NOT_ACTIVE":
            return "Package Ready"
        default:
            return status
        }
    }

    public var showActivated: Bool {
        status == "ACTIVE"
    }

    public var showExpires: Bool {
        status == "ACTIVE" || status == "TERMINATED"
    }

    public var showExpiredLabel: Bool {
        status == "TERMINATED"
    }

    public var showDataRemaining: Bool {
        status == "ACTIVE" && !hasUnlimitedPackage
    }

    public var showDataUsed: Bool {
        status == "ACTIVE"
    }

    public var showActivationWindowEnds: Bool {
        status == "NOT_ACTIVE"
    }

    enum CodingKeys: String, CodingKey {
        case status
        case dateCreatedEpoch = "date_created_epoch"
        case windowActivationStartEpoch = "window_activation_start_epoch"
        case windowActivationEndEpoch = "window_activation_end_epoch"
        case voiceUsageRemainingSeconds = "voice_usage_remaining_seconds"
        case smsUsageRemainingNums = "sms_usage_remaining_nums"
        case timeAllowanceSeconds = "time_allowance_seconds"
        case timeAllowanceDays = "time_allowance_days"
        case packageCountryName = "package_country_name"
        case packageTypeID = "package_type_id"
        case dateExpiryEpoch = "date_expiry_epoch"
        case dateTerminatedEpoch = "date_terminated_epoch"
        case dateActivatedEpoch = "date_activated_epoch"
        case dataAllowanceBytes = "data_allowance_bytes"
        case dataUsageRemainingBytes = "data_usage_remaining_bytes"
        case dataAllowanceGigabytes = "data_allowance_gigabytes"
        case dataUsedBytes = "data_usage_bytes"
        case statusMessage = "status_message"

    }
}

// MARK: Esim Profile Model

public struct EsimProfile: Codable, Hashable {
    public let state: String
    public let lastOperationDate: Int
    public let activationCode: String?
    public let reuseRemainingCount: Int
    public let reuseEnabled: Bool
    public let ccRequired: Bool
    public let releaseDate: Int
    public let stateMessage: String
    public let lastOperationDateUTC: String
    public let releaseDateUTC: String

    public init(state: String, lastOperationDate: Int, activationCode: String? = nil, reuseRemainingCount: Int, reuseEnabled: Bool, ccRequired: Bool, releaseDate: Int, stateMessage: String, lastOperationDateUTC: String, releaseDateUTC: String) {
        self.state = state
        self.lastOperationDate = lastOperationDate
        self.activationCode = activationCode
        self.reuseRemainingCount = reuseRemainingCount
        self.reuseEnabled = reuseEnabled
        self.ccRequired = ccRequired
        self.releaseDate = releaseDate
        self.stateMessage = stateMessage
        self.lastOperationDateUTC = lastOperationDateUTC
        self.releaseDateUTC = releaseDateUTC
    }

    public var esimStatus: EsimStatus {
        EsimStatus(rawValue: state) ?? .enabled
    }

    enum CodingKeys: String, CodingKey {
        case state
        case lastOperationDate = "last_operation_date"
        case activationCode = "activation_code"
        case reuseRemainingCount = "reuse_remaining_count"
        case reuseEnabled = "reuse_enabled"
        case ccRequired = "cc_required"
        case releaseDate = "release_date"
        case stateMessage = "state_message"
        case lastOperationDateUTC = "last_operation_date_utc"
        case releaseDateUTC = "release_date_utc"
    }
}

// MARK: Esim Status Enum

public enum EsimStatus: String {
    case enabled = "ENABLED"
    case installed = "INSTALLED"
    case downloaded = "DOWNLOADED"
    case released = "RELEASED"
    case disabled = "DISABLED"
    case error = "ERROR"
    case deleted = "DELETED"
}
