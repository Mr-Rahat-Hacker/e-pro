package com.eprocurement.erp.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
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
@Table(name = "purchase_requisition_lines", schema = "eproc")
public class PurchaseRequisitionLine extends BaseAuditableEntity {
    @Id
    @GeneratedValue
    @Column(name = "pr_line_id")
    private UUID id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "pr_id")
    private PurchaseRequisition purchaseRequisition;

    @Column(name = "line_number", nullable = false)
    private Integer lineNumber;

    @ManyToOne
    @JoinColumn(name = "item_id")
    private Item item;

    @Column(name = "description", nullable = false)
    private String description;

    @Column(name = "quantity", nullable = false, precision = 19, scale = 4)
    private BigDecimal quantity;

    @Column(name = "uom", nullable = false)
    private String uom = "EA";

    @Column(name = "estimated_unit_price", nullable = false, precision = 19, scale = 4)
    private BigDecimal estimatedUnitPrice;

    @Column(name = "estimated_line_amount", nullable = false, precision = 19, scale = 4)
    private BigDecimal estimatedLineAmount;

    @Column(name = "required_by_date")
    private LocalDate requiredByDate;
}
