package com.eprocurement.erp.dto;

import java.math.BigDecimal;
import java.util.UUID;

public record PurchaseRequisitionLineResponse(
    UUID id,
    Integer lineNumber,
    UUID itemId,
    String description,
    BigDecimal quantity,
    String uom,
    BigDecimal estimatedUnitPrice,
    BigDecimal estimatedLineAmount
) {
}
