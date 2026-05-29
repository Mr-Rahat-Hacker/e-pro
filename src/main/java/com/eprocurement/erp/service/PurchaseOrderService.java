package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.PurchaseOrder;
import com.eprocurement.erp.dto.PurchaseOrderResponse;
import com.eprocurement.erp.exception.ResourceNotFoundException;
import com.eprocurement.erp.repository.PurchaseOrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PurchaseOrderService {
    private final PurchaseOrderRepository purchaseOrderRepository;

    @Transactional(readOnly = true)
    public PurchaseOrderResponse get(UUID id) {
        return purchaseOrderRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Purchase order not found: " + id));
    }

    @Transactional(readOnly = true)
    public Page<PurchaseOrderResponse> list(Pageable pageable) {
        return purchaseOrderRepository.findAll(pageable).map(this::toResponse);
    }

    private PurchaseOrderResponse toResponse(PurchaseOrder purchaseOrder) {
        return new PurchaseOrderResponse(
            purchaseOrder.getId(),
            purchaseOrder.getPoNumber(),
            purchaseOrder.getVendor().getId(),
            purchaseOrder.getBuyer().getId(),
            purchaseOrder.getStatus(),
            purchaseOrder.getOrderDate(),
            purchaseOrder.getTotalAmount()
        );
    }
}
