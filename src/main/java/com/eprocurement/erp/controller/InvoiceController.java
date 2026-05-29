package com.eprocurement.erp.controller;

import com.eprocurement.erp.dto.ApiResponse;
import com.eprocurement.erp.dto.InvoiceResponse;
import com.eprocurement.erp.service.InvoiceService;
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

@Tag(name = "Invoices", description = "Invoice processing APIs")
@RestController
@RequestMapping("/api/v1/invoices")
@RequiredArgsConstructor
public class InvoiceController {
    private final InvoiceService invoiceService;

    @Operation(summary = "Get invoice by id")
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('INVOICE_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<InvoiceResponse>> get(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok(invoiceService.get(id)));
    }

    @Operation(summary = "List invoices")
    @GetMapping
    @PreAuthorize("hasAnyAuthority('INVOICE_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER', 'ROLE_APPROVER')")
    public ResponseEntity<ApiResponse<Page<InvoiceResponse>>> list(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(invoiceService.list(pageable)));
    }
}
