package com.eprocurement.erp.controller;

import com.eprocurement.erp.dto.ApiResponse;
import com.eprocurement.erp.dto.VendorCreateRequest;
import com.eprocurement.erp.dto.VendorResponse;
import com.eprocurement.erp.service.VendorService;
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

@Tag(name = "Vendors", description = "Vendor master data APIs")
@RestController
@RequestMapping("/api/v1/vendors")
@RequiredArgsConstructor
public class VendorController {
    private final VendorService vendorService;

    @Operation(summary = "Create vendor")
    @PostMapping
    @PreAuthorize("hasAnyAuthority('VENDOR_CREATE', 'ROLE_PROC_ADMIN')")
    public ResponseEntity<ApiResponse<VendorResponse>> create(@Valid @RequestBody VendorCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(ApiResponse.created(vendorService.create(request), "Vendor created"));
    }

    @Operation(summary = "Get vendor by id")
    @GetMapping("/{id}")
    @PreAuthorize("hasAnyAuthority('VENDOR_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER')")
    public ResponseEntity<ApiResponse<VendorResponse>> get(@PathVariable UUID id) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.get(id)));
    }

    @Operation(summary = "List vendors")
    @GetMapping
    @PreAuthorize("hasAnyAuthority('VENDOR_READ', 'ROLE_PROC_ADMIN', 'ROLE_BUYER')")
    public ResponseEntity<ApiResponse<Page<VendorResponse>>> list(Pageable pageable) {
        return ResponseEntity.ok(ApiResponse.ok(vendorService.list(pageable)));
    }
}
