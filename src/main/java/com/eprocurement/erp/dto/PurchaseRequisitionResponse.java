package com.eprocurement.erp.dto;

import com.eprocurement.erp.domain.enums.DocumentStatus;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

public record PurchaseRequisitionResponse(
    UUID id,
    String prNumber,
    UUID requesterUserId,
    DocumentStatus status,
    String currencyCode,
    BigDecimal totalAmount,
    List<PurchaseRequisitionLineResponse> lines
) {
}
