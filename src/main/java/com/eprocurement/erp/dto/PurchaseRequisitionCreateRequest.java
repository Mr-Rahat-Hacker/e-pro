package com.eprocurement.erp.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

public record PurchaseRequisitionCreateRequest(
    @NotBlank String prNumber,
    @NotNull UUID requesterUserId,
    String department,
    String costCenter,
    LocalDate requiredByDate,
    @NotBlank @Pattern(regexp = "[A-Z]{3}") String currencyCode,
    String businessJustification,
    @NotEmpty List<@Valid PurchaseRequisitionLineRequest> lines
) {
}
