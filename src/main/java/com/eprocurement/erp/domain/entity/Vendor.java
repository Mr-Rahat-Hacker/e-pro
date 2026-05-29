package com.eprocurement.erp.domain.entity;

import com.eprocurement.erp.domain.enums.RiskRating;
import com.eprocurement.erp.domain.enums.VendorStatus;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "vendors", schema = "eproc")
public class Vendor extends BaseAuditableEntity {
    @Id
    @GeneratedValue
    @Column(name = "vendor_id")
    private UUID id;

    @Column(name = "vendor_code", nullable = false, unique = true)
    private String vendorCode;

    @Column(name = "legal_name", nullable = false)
    private String legalName;

    @Column(name = "tax_identifier")
    private String taxIdentifier;

    @Column(name = "vendor_type", nullable = false)
    private String vendorType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private VendorStatus status = VendorStatus.DRAFT;

    @Enumerated(EnumType.STRING)
    @Column(name = "risk_rating", nullable = false)
    private RiskRating riskRating = RiskRating.LOW;

    @Column(name = "payment_terms", nullable = false)
    private String paymentTerms = "NET30";

    @Column(name = "currency_code", nullable = false, length = 3)
    private String currencyCode = "USD";

    @Column(name = "country_code", length = 2)
    private String countryCode;
}
