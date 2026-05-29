package com.eprocurement.erp.dto;

import com.eprocurement.erp.domain.enums.RiskRating;
import com.eprocurement.erp.domain.enums.VendorStatus;

import java.util.UUID;

public record VendorResponse(
    UUID id,
    String vendorCode,
    String legalName,
    String vendorType,
    VendorStatus status,
    RiskRating riskRating,
    String currencyCode,
    String countryCode
) {
}
