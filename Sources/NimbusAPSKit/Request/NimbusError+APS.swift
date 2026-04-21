//
//  NimbusError+APS.swift
//  NimbusAPSKit
//
//  Created on 2/23/26.
//  Copyright © 2026 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit

extension NimbusError.Domain {
    static let aps = Self(rawValue: "aps")
}

extension NimbusError {
    static func aps(reason: Reason = .failure, stage: Stage, detail: String? = nil) -> NimbusError {
        NimbusError(reason: reason, domain: .aps, stage: stage, detail: detail)
    }
}
