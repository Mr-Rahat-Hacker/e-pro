package com.eprocurement.erp.repository;

import com.eprocurement.erp.domain.entity.PurchaseRequisition;
import com.eprocurement.erp.domain.enums.DocumentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PurchaseRequisitionRepository extends JpaRepository<PurchaseRequisition, UUID> {
    boolean existsByPrNumberIgnoreCase(String prNumber);
    List<PurchaseRequisition> findByStatusOrderByCreatedAtDesc(DocumentStatus status);
}
