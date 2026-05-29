package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.Invoice;
import com.eprocurement.erp.dto.InvoiceResponse;
import com.eprocurement.erp.exception.ResourceNotFoundException;
import com.eprocurement.erp.repository.InvoiceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class InvoiceService {
    private final InvoiceRepository invoiceRepository;

    @Transactional(readOnly = true)
    public InvoiceResponse get(UUID id) {
        return invoiceRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Invoice not found: " + id));
    }

    @Transactional(readOnly = true)
    public Page<InvoiceResponse> list(Pageable pageable) {
        return invoiceRepository.findAll(pageable).map(this::toResponse);
    }

    private InvoiceResponse toResponse(Invoice invoice) {
        return new InvoiceResponse(
            invoice.getId(),
            invoice.getInvoiceNumber(),
            invoice.getVendor().getId(),
            invoice.getPurchaseOrder() == null ? null : invoice.getPurchaseOrder().getId(),
            invoice.getInvoiceDate(),
            invoice.getStatus(),
            invoice.getMatchStatus(),
            invoice.getTotalAmount()
        );
    }
}
