package com.eprocurement.erp.dto;

import com.eprocurement.erp.domain.enums.DocumentStatus;
import com.eprocurement.erp.domain.enums.InvoiceMatchStatus;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

public record InvoiceResponse(
    UUID id,
    String invoiceNumber,
    UUID vendorId,
    UUID purchaseOrderId,
    LocalDate invoiceDate,
    DocumentStatus status,
    InvoiceMatchStatus matchStatus,
    BigDecimal totalAmount
) {
}
