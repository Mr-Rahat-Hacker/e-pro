package com.eprocurement.erp.domain.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.UUID;

@Getter
@Setter
@Entity
@Table(name = "items", schema = "eproc")
public class Item extends BaseAuditableEntity {
    @Id
    @GeneratedValue
    @Column(name = "item_id")
    private UUID id;

    @Column(name = "sku", nullable = false, unique = true)
    private String sku;

    @Column(name = "item_name", nullable = false)
    private String itemName;

    @Column(name = "item_type", nullable = false)
    private String itemType = "MATERIAL";

    @Column(name = "uom", nullable = false)
    private String uom = "EA";

    @Column(name = "standard_cost", nullable = false, precision = 19, scale = 4)
    private BigDecimal standardCost = BigDecimal.ZERO;
}
