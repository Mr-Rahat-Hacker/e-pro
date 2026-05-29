package com.eprocurement.erp.dto;

import com.eprocurement.erp.domain.enums.DocumentStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record PurchaseOrderResponse(
    UUID id,
    String poNumber,
    UUID vendorId,
    UUID buyerUserId,
    DocumentStatus status,
    LocalDate orderDate,
    BigDecimal totalAmount
) {
}
