package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.PurchaseRequisition;
import com.eprocurement.erp.domain.entity.UserEntity;
import com.eprocurement.erp.dto.PurchaseRequisitionCreateRequest;
import com.eprocurement.erp.dto.PurchaseRequisitionLineRequest;
import com.eprocurement.erp.dto.PurchaseRequisitionResponse;
import com.eprocurement.erp.repository.ItemRepository;
import com.eprocurement.erp.repository.PurchaseRequisitionRepository;
import com.eprocurement.erp.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class PurchaseRequisitionServiceTest {
    @Mock
    private PurchaseRequisitionRepository purchaseRequisitionRepository;

    @Mock
    private UserRepository userRepository;

    @Mock
    private ItemRepository itemRepository;

    @Mock
    private AuditService auditService;

    @InjectMocks
    private PurchaseRequisitionService purchaseRequisitionService;

    @Test
    void createCalculatesLineAmountsAndTotal() {
        UUID requesterId = UUID.randomUUID();
        UserEntity requester = new UserEntity();
        requester.setId(requesterId);
        requester.setUsername("requester01");
        when(purchaseRequisitionRepository.existsByPrNumberIgnoreCase("PR-001")).thenReturn(false);
        when(userRepository.findById(requesterId)).thenReturn(Optional.of(requester));
        when(purchaseRequisitionRepository.save(any(PurchaseRequisition.class))).thenAnswer(invocation -> {
            PurchaseRequisition pr = invocation.getArgument(0);
            pr.setId(UUID.randomUUID());
            pr.getLines().forEach(line -> line.setId(UUID.randomUUID()));
            return pr;
        });

        PurchaseRequisitionCreateRequest request = new PurchaseRequisitionCreateRequest(
            "PR-001",
            requesterId,
            "Operations",
            "OPS-100",
            LocalDate.now().plusDays(10),
            "USD",
            "Safety stock replenishment",
            List.of(new PurchaseRequisitionLineRequest(null, "Nitrile Gloves", new BigDecimal("10"), "BOX", new BigDecimal("12.50"), null))
        );

        PurchaseRequisitionResponse response = purchaseRequisitionService.create(request);

        assertThat(response.totalAmount()).isEqualByComparingTo("125.00");
        assertThat(response.lines()).hasSize(1);
        assertThat(response.lines().getFirst().estimatedLineAmount()).isEqualByComparingTo("125.00");
        verify(auditService).record(eq("PR"), eq(response.id()), eq("CREATED"), eq(requesterId), any());
    }
}
