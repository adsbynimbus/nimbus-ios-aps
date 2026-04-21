//
//  APSDemand.swift
//  Nimbus
//  Created on 9/4/25
//  Copyright © 2025 Nimbus Advertising Solutions Inc. All rights reserved.
//

import NimbusKit
import DTBiOSSDK

@MainActor
public func aps(ads: [APSAd]) -> DemandComponent {
    APS(ads: ads)
}

@MainActor
private struct APS: DemandComponent {
    let ads: [APSAdData]
    
    init(ads: [APSAd]) {
        self.ads = ads.data
    }
    
    func apply(to adRequest: AdRequest) -> AdRequest {
        var modified = adRequest
        modified.append(interceptor: NimbusAPSOnRequestInterceptor(ads: ads))
        
        return modified
    }
}

// Sendable envelope of APS Ad data to create a new request
struct APSAdData: Sendable {
    let format: APSAdFormat
    let slotUUID: String
    var customTargeting: [String: String]
    
    init(ad: APSAd) {
        self.format = ad.adFormat
        self.slotUUID = ad.slotUUID
        self.customTargeting = ad.customTargeting ?? [:]
    }
    
    // For tests
    init(format: APSAdFormat, slotUUID: String, customTargeting: [String: String]) {
        self.format = format
        self.slotUUID = slotUUID
        self.customTargeting = customTargeting
    }
}

extension Array where Element == APSAd {
    var data: [APSAdData] { map { APSAdData(ad: $0) } }
}

extension Array where Element == APSAdData {
    var customTargeting: [[String: String]] { compactMap { $0.customTargeting.isEmpty ? nil : $0.customTargeting } }
    
    mutating func resetCustomTargeting() {
        for index in indices {
            self[index].customTargeting = [:]
        }
    }
    
    func fetchCustomTargeting() async -> [[String: String]] {
        await withTaskGroup(of: [String: String]?.self) { group in
            for data in self {
                group.addTask {
                    do {
                        let request = APSAdRequest(slotUUID: data.slotUUID, adNetworkInfo: .init(networkName: .nimbus))
                        request.setAdFormat(data.format)
                        return try await request.loadAd().customTargeting
                    } catch {
                        Nimbus.Log.request.debug("Couldn't fetch APS Ad: \(error.localizedDescription)")
                        return nil
                    }
                }
            }

            var result: [[String: String]] = []

            for await targeting in group {
                if let targeting, !targeting.isEmpty {
                    result.append(targeting)
                }
            }

            return result
        }
    }
}
