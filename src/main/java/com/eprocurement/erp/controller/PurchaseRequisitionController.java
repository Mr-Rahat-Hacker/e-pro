package com.eprocurement.erp.controller;

import com.eprocurement.erp.dto.ApiResponse;
import com.eprocurement.erp.dto.PurchaseRequisitionCreateRequest;
import com.eprocurement.erp.dto.PurchaseRequisitionResponse;
import com.eprocurement.erp.service.PurchaseRequisitionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@Tag(name = "Purchase Requisitions", description = "Purchase requisition lifecycle APIs")
@RestController
@RequestMapping("/api/v1/purchase-requisitions")
@RequiredArgsConstructor
public class PurchaseRequisitionController {
    private final PurchaseRequisitionService purchaseRequisitionService;

    @Operation(summary = "Create purchase requisition")
    @PostMapping
    @PreAuthorize("hasAnyAuthority('PR_CREATE', 'ROLE_PROC_ADMIN', 'ROLE_REQUESTER')")
    public ResponseEntity<ApiResponse<PurchaseRequisitionResponse>> create(@Valid @RequestBody PurchaseRequisitionCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.created(purchaseRequisitionService.create(request), "Purchase requisition created"));
    }

    @Operation(summary = "Submit draft purchase requisition for approval")
    @PostMapping("/{id}/submit")
    @PreAuthorize("hasAnyAuthority('PR_CREATE', 'ROLE_PROC_ADMIN', 'ROLE_REQUESTER')")
    public ResponseEntity<ApiResponse<PurchaseRequisitionResponse>> submit(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok(purchaseRequisitionService.submit(id)));
    }

    @Operation(summary = "Get purchase requisition by id")
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('PR_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_REQUESTER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<PurchaseRequisitionResponse>> get(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok(purchaseRequisitionService.get(id)));
    }

    @Operation(summary = "List purchase requisitions")
    @GetMapping
    @PreAuthorize("hasAnyAuthority('PR_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_REQUESTER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<Page<PurchaseRequisitionResponse>>> list(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(purchaseRequisitionService.list(pageable)));
    }
}
