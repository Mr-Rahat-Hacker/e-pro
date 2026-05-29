package com.eprocurement.erp.domain.entity;

import com.eprocurement.erp.domain.enums.DocumentStatus;
import com.eprocurement.erp.domain.enums.InvoiceMatchStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "invoices", schema = "eproc")
public class Invoice extends BaseAuditableEntity {
    @Id
    @GeneratedValue
    @Column(name = "invoice_id")
    private UUID id;

    @Column(name = "invoice_number", nullable = false)
    private String invoiceNumber;

    @ManyToOne(optional = false)
    @JoinColumn(name = "vendor_id")
    private Vendor vendor;

    @ManyToOne
    @JoinColumn(name = "po_id")
    private PurchaseOrder purchaseOrder;

    @Column(name = "invoice_date", nullable = false)
    private LocalDate invoiceDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private DocumentStatus status = DocumentStatus.RECEIVED;

    @Enumerated(EnumType.STRING)
    @Column(name = "match_status", nullable = false)
    private InvoiceMatchStatus matchStatus = InvoiceMatchStatus.NOT_MATCHED;

    @Column(name = "total_amount", nullable = false, precision = 19, scale = 4)
    private BigDecimal totalAmount = BigDecimal.ZERO;
}
