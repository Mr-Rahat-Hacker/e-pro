package com.eprocurement.erp.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record PurchaseRequisitionLineRequest(
    UUID itemId,
    @NotBlank String description,
    @NotNull @Positive BigDecimal quantity,
    @NotBlank String uom,
    @NotNull @DecimalMin("0.0") BigDecimal estimatedUnitPrice,
    LocalDate requiredByDate
) {
}
