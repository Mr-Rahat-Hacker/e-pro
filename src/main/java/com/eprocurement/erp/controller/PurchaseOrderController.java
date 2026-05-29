package com.eprocurement.erp.controller;

import com.eprocurement.erp.dto.ApiResponse;
import com.eprocurement.erp.dto.PurchaseOrderResponse;
import com.eprocurement.erp.service.PurchaseOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@Tag(name = "Purchase Orders", description = "Purchase order APIs")
@RestController
@RequestMapping("/api/v1/purchase-orders")
@RequiredArgsConstructor
public class PurchaseOrderController {
    private final PurchaseOrderService purchaseOrderService;

    @Operation(summary = "Get purchase order by id")
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('PO_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<PurchaseOrderResponse>> get(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok(purchaseOrderService.get(id)));
    }

    @Operation(summary = "List purchase orders")
    @GetMapping
    @PreAuthorize("hasAnyAuthority('PO_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<Page<PurchaseOrderResponse>>> list(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(purchaseOrderService.list(pageable)));
    }
}
