package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.Vendor;
import com.eprocurement.erp.dto.VendorCreateRequest;
import com.eprocurement.erp.dto.VendorResponse;
import com.eprocurement.erp.exception.BusinessRuleException;
import com.eprocurement.erp.repository.VendorRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.ArgumentMatchers.isNull;

@ExtendWith(MockitoExtension.class)
class VendorServiceTest {
    @Mock
    private VendorRepository vendorRepository;

    @Mock
    private AuditService auditService;

    @InjectMocks
    private VendorService vendorService;

    @Test
    void createPersistsVendorAndWritesAuditLog() {
        VendorCreateRequest request = new VendorCreateRequest(
            "VEND-001",
            "Acme Industrial Supplies LLC",
            "TAX-123",
            "DISTRIBUTOR",
            "USD",
            "US"
        );
        when(vendorRepository.existsByVendorCodeIgnoreCase("VEND-001")).thenReturn(false);
        when(vendorRepository.save(any(Vendor.class))).thenAnswer(invocation -> {
            Vendor vendor = invocation.getArgument(0);
            vendor.setId(UUID.randomUUID());
            return vendor;
        });

        VendorResponse response = vendorService.create(request);

        assertThat(response.vendorCode()).isEqualTo("VEND-001");
        assertThat(response.legalName()).isEqualTo("Acme Industrial Supplies LLC");
        ArgumentCaptor<Vendor> captor = ArgumentCaptor.forClass(Vendor.class);
        verify(vendorRepository).save(captor.capture());
        assertThat(captor.getValue().getCurrencyCode()).isEqualTo("USD");
        verify(auditService).record(eq("VENDOR"), eq(response.id()), eq("CREATED"), isNull(), any());
    }

    @Test
    void createRejectsDuplicateVendorCode() {
        VendorCreateRequest request = new VendorCreateRequest("VEND-001", "Acme", null, "DISTRIBUTOR", "USD", "US");
        when(vendorRepository.existsByVendorCodeIgnoreCase("VEND-001")).thenReturn(true);

        assertThatThrownBy(() -> vendorService.create(request))
            .isInstanceOf(BusinessRuleException.class)
            .hasMessageContaining("Vendor code already exists");
    }

    @Test
    void getReturnsVendorById() {
        UUID id = UUID.randomUUID();
        Vendor vendor = new Vendor();
        vendor.setId(id);
        vendor.setVendorCode("VEND-002");
        vendor.setLegalName("Global Services Inc");
        vendor.setVendorType("SERVICE_PROVIDER");
        vendor.setCurrencyCode("USD");
        when(vendorRepository.findById(id)).thenReturn(Optional.of(vendor));

        VendorResponse response = vendorService.get(id);

        assertThat(response.id()).isEqualTo(id);
        assertThat(response.vendorCode()).isEqualTo("VEND-002");
    }
}
