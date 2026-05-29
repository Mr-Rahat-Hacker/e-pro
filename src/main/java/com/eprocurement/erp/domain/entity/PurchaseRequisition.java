package com.eprocurement.erp.domain.entity;

import com.eprocurement.erp.domain.enums.DocumentStatus;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "purchase_requisitions", schema = "eproc")
public class PurchaseRequisition extends BaseAuditableEntity {
    @Id
    @GeneratedValue
    @Column(name = "pr_id")
    private UUID id;

    @Column(name = "pr_number", nullable = false, unique = true)
    private String prNumber;

    @ManyToOne(optional = false)
    @JoinColumn(name = "requester_user_id")
    private UserEntity requester;

    @Column(name = "department")
    private String department;

    @Column(name = "cost_center")
    private String costCenter;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private DocumentStatus status = DocumentStatus.DRAFT;

    @Column(name = "required_by_date")
    private LocalDate requiredByDate;

    @Column(name = "currency_code", nullable = false, length = 3)
    private String currencyCode = "USD";

    @Column(name = "total_amount", nullable = false, precision = 19, scale = 4)
    private BigDecimal totalAmount = BigDecimal.ZERO;

    @Column(name = "business_justification")
    private String businessJustification;

    @OneToMany(mappedBy = "purchaseRequisition", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PurchaseRequisitionLine> lines = new ArrayList<>();

    public void addLine(PurchaseRequisitionLine line) {
        line.setPurchaseRequisition(this);
        lines.add(line);
    }
}
