//
//  NimbusAPSOnRequestInterceptorTests.swift
//  NimbusRequestAPSKitTests
//
//  Created on 3/27/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK
@testable import NimbusAPSKit
@testable import NimbusKit
import Mockingbird
import Testing

@Suite("Nimbus APS interceptor tests")
struct NimbusAPSOnRequestInterceptorTests {
    @Test("The first request should not be modified")
    func firstRequestIsSkipped() async throws {
        let info = try await NimbusRequest(from: Nimbus.bannerAd(position: "test", size: .banner).adRequest!.request)
        
        let interceptor = NimbusAPSOnRequestInterceptor(ads: [.init(format: .banner, slotUUID: "", customTargeting: [:])])
        
        #expect(await interceptor.getShouldModifyRequest() == false)
        
        let deltas = try await interceptor.modifyRequest(request: info)
        #expect(deltas.isEmpty)
        
        #expect(await interceptor.getShouldModifyRequest() == true)
    }
    
    @Test("Interceptor should return APS token data", arguments: [
        [
            APSAdData(format: .banner, slotUUID: "banner", customTargeting: ["slot": "banner"]),
            APSAdData(format: .MREC, slotUUID: "mrec", customTargeting: ["slot": "mrec"])
        ],
        [
            APSAdData(format: .interstitial, slotUUID: "interstitial", customTargeting: ["slot": "interstitial"]),
            APSAdData(format: .interstitial, slotUUID: "video", customTargeting: ["slot": "video"])
        ]
    ])
    func interceptorShouldReturnAPSTokenData(_ apsData: [APSAdData]) async throws {
        let interceptor = NimbusAPSOnRequestInterceptor(ads: apsData)
        
        let info = try await NimbusRequest(from: Nimbus.bannerAd(position: "test", size: .banner).adRequest!.request)
        let deltas = try await interceptor.modifyRequest(request: info)
        
        #expect(deltas.count == 1)
        #expect(deltas[0].target == .impression)
        #expect(deltas[0].key == "aps")
        
        let data = deltas[0].value as! [[String: String]]
        #expect(data.count == apsData.count)
        
        #expect(data[0] == apsData[0].customTargeting || data[0] == apsData[1].customTargeting)
        #expect(data[1] == apsData[0].customTargeting || data[1] == apsData[1].customTargeting)
    }
    
    @Test("APS data gets inserted into request", arguments: [
        [
            APSAdData(format: .banner, slotUUID: "banner", customTargeting: ["slot": "banner"]),
            APSAdData(format: .MREC, slotUUID: "mrec", customTargeting: ["slot": "mrec"])
        ]
    ])
    func apsDataGetsInsertedIntoRequest(_ expectedAPSData: [APSAdData]) async throws {
        let interceptor = NimbusAPSOnRequestInterceptor(ads: expectedAPSData)
        
        var request = try await Nimbus.rewardedAd(position: "position").adRequest!.request
        request.interceptors = [interceptor]
        
        try await request.modifyRequestWithExtras(
            configuration: Nimbus.configuration,
            vendorId: "",
            appVersion: "1.0.0"
        )
        
        let actualAPSData = request.impressions[0].ext.extras["aps"] as? [[String: String]]
        
        // Order is random as aps loading is async
        #expect(actualAPSData?.count == expectedAPSData.count)
        #expect(actualAPSData?[0] == expectedAPSData[0].customTargeting || actualAPSData?[0] == expectedAPSData[1].customTargeting)
        #expect(actualAPSData?[1] == expectedAPSData[0].customTargeting || actualAPSData?[1] == expectedAPSData[1].customTargeting)
    }
}
