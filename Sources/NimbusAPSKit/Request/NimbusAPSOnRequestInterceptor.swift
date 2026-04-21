//
//  NimbusAPSOnRequestInterceptor.swift
//  NimbusRequestAPSKit
//
//  Created on 3/22/23.
//  Copyright © 2023 Nimbus Advertising Solutions Inc. All rights reserved.
//

import DTBiOSSDK
import NimbusKit

actor NimbusAPSOnRequestInterceptor {
    private var shouldModifyRequest = false
    private var ads: [APSAdData]
    
    init(ads: [APSAdData]) {
        self.ads = ads
        
        Nimbus.Log.request.info("APS provider initialized")
    }
    
    // MARK: - Internal just for tests to verify the functionality
    
    func getShouldModifyRequest() async -> Bool {
        shouldModifyRequest
    }
    
    func setShouldModifyRequest(_ value: Bool) async {
        shouldModifyRequest = value
    }
}

// MARK: - NimbusRequest.Interceptor

extension NimbusAPSOnRequestInterceptor: NimbusRequest.Interceptor {
    func modifyRequest(request: NimbusRequest) async throws -> [NimbusRequest.Delta] {
        let customTargeting: [[String: String]]
        
        if !shouldModifyRequest {
            customTargeting = ads.customTargeting
            ads.resetCustomTargeting()
            
            // The interceptor can only fetch subsequent APS ads, not the original one.
            shouldModifyRequest = true
        } else {
            customTargeting = await ads.fetchCustomTargeting()
        }
        
        try Task.checkCancellation()
        return customTargeting.isEmpty ? [] : [.init(target: .impression, key: "aps", value: customTargeting)]
    }
}
