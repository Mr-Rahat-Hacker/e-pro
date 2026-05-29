package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.Vendor;
import com.eprocurement.erp.domain.enums.RiskRating;
import com.eprocurement.erp.domain.enums.VendorStatus;
import com.eprocurement.erp.dto.VendorCreateRequest;
import com.eprocurement.erp.dto.VendorResponse;
import com.eprocurement.erp.exception.BusinessRuleException;
import com.eprocurement.erp.exception.ResourceNotFoundException;
import com.eprocurement.erp.repository.VendorRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class VendorService {
    private final VendorRepository vendorRepository;
    private final AuditService auditService;

    @Transactional
    public VendorResponse create(VendorCreateRequest request) {
        if (vendorRepository.existsByVendorCodeIgnoreCase(request.vendorCode())) {
            throw new BusinessRuleException("Vendor code already exists: " + request.vendorCode());
        }

        Vendor vendor = new Vendor();
        vendor.setVendorCode(request.vendorCode());
        vendor.setLegalName(request.legalName());
        vendor.setTaxIdentifier(request.taxIdentifier());
        vendor.setVendorType(request.vendorType());
        vendor.setCurrencyCode(request.currencyCode());
        vendor.setCountryCode(request.countryCode());
        vendor.setStatus(VendorStatus.DRAFT);
        vendor.setRiskRating(RiskRating.LOW);

        Vendor saved = vendorRepository.save(vendor);
        auditService.record("VENDOR", saved.getId(), "CREATED", null, Map.of("vendorCode", saved.getVendorCode()));
        log.info("Created vendor {} ({})", saved.getVendorCode(), saved.getId());
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public VendorResponse get(UUID id) {
        return vendorRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Vendor not found: " + id));
    }

    @Transactional(readOnly = true)
    public Page<VendorResponse> list(Pageable pageable) {
        return vendorRepository.findAll(pageable).map(this::toResponse);
    }

    private VendorResponse toResponse(Vendor vendor) {
        return new VendorResponse(
            vendor.getId(),
            vendor.getVendorCode(),
            vendor.getLegalName(),
            vendor.getVendorType(),
            vendor.getStatus(),
            vendor.getRiskRating(),
            vendor.getCurrencyCode(),
            vendor.getCountryCode()
        );
    }
}
