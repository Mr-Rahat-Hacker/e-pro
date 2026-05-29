package com.eprocurement.erp.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record VendorCreateRequest(
    @NotBlank @Size(max = 50) String vendorCode,
    @NotBlank @Size(max = 255) String legalName,
    @Size(max = 100) String taxIdentifier,
    @NotBlank @Size(max = 50) String vendorType,
    @NotBlank @Pattern(regexp = "[A-Z]{3}") String currencyCode,
    @Pattern(regexp = "[A-Z]{2}") String countryCode
) {
}
