package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.Item;
import com.eprocurement.erp.domain.entity.PurchaseRequisition;
import com.eprocurement.erp.domain.entity.PurchaseRequisitionLine;
import com.eprocurement.erp.domain.entity.UserEntity;
import com.eprocurement.erp.domain.enums.DocumentStatus;
import com.eprocurement.erp.dto.PurchaseRequisitionCreateRequest;
import com.eprocurement.erp.dto.PurchaseRequisitionLineRequest;
import com.eprocurement.erp.dto.PurchaseRequisitionLineResponse;
import com.eprocurement.erp.dto.PurchaseRequisitionResponse;
import com.eprocurement.erp.exception.BusinessRuleException;
import com.eprocurement.erp.exception.ResourceNotFoundException;
import com.eprocurement.erp.repository.ItemRepository;
import com.eprocurement.erp.repository.PurchaseRequisitionRepository;
import com.eprocurement.erp.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

@Slf4j
@Service
@RequiredArgsConstructor
public class PurchaseRequisitionService {
    private final PurchaseRequisitionRepository purchaseRequisitionRepository;
    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final AuditService auditService;

    @Transactional
    public PurchaseRequisitionResponse create(PurchaseRequisitionCreateRequest request) {
        if (purchaseRequisitionRepository.existsByPrNumberIgnoreCase(request.prNumber())) {
            throw new BusinessRuleException("Purchase requisition number already exists: " + request.prNumber());
        }

        UserEntity requester = userRepository.findById(request.requesterUserId())
            .orElseThrow(() -> new ResourceNotFoundException("Requester not found: " + request.requesterUserId()));

        PurchaseRequisition pr = new PurchaseRequisition();
        pr.setPrNumber(request.prNumber());
        pr.setRequester(requester);
        pr.setDepartment(request.department());
        pr.setCostCenter(request.costCenter());
        pr.setRequiredByDate(request.requiredByDate());
        pr.setCurrencyCode(request.currencyCode());
        pr.setBusinessJustification(request.businessJustification());
        pr.setStatus(DocumentStatus.DRAFT);

        AtomicInteger lineNumber = new AtomicInteger(1);
        for (PurchaseRequisitionLineRequest lineRequest : request.lines()) {
            PurchaseRequisitionLine line = buildLine(lineNumber.getAndIncrement(), lineRequest);
            pr.addLine(line);
        }
        pr.setTotalAmount(pr.getLines().stream()
            .map(PurchaseRequisitionLine::getEstimatedLineAmount)
            .reduce(BigDecimal.ZERO, BigDecimal::add));

        PurchaseRequisition saved = purchaseRequisitionRepository.save(pr);
        auditService.record("PR", saved.getId(), "CREATED", requester.getId(), Map.of("prNumber", saved.getPrNumber()));
        log.info("Created purchase requisition {} ({})", saved.getPrNumber(), saved.getId());
        return toResponse(saved);
    }

    @Transactional
    public PurchaseRequisitionResponse submit(UUID prId) {
        PurchaseRequisition pr = purchaseRequisitionRepository.findById(prId)
            .orElseThrow(() -> new ResourceNotFoundException("Purchase requisition not found: " + prId));
        if (pr.getStatus() != DocumentStatus.DRAFT) {
            throw new BusinessRuleException("Only draft purchase requisitions can be submitted");
        }
        pr.setStatus(DocumentStatus.SUBMITTED);
        PurchaseRequisition saved = purchaseRequisitionRepository.save(pr);
        auditService.record("PR", saved.getId(), "SUBMITTED", saved.getRequester().getId(), Map.of("status", saved.getStatus().name()));
        return toResponse(saved);
    }

    @Transactional(readOnly = true)
    public PurchaseRequisitionResponse get(UUID id) {
        return purchaseRequisitionRepository.findById(id)
            .map(this::toResponse)
            .orElseThrow(() -> new ResourceNotFoundException("Purchase requisition not found: " + id));
    }

    @Transactional(readOnly = true)
    public Page<PurchaseRequisitionResponse> list(Pageable pageable) {
        return purchaseRequisitionRepository.findAll(pageable).map(this::toResponse);
    }

    private PurchaseRequisitionLine buildLine(int lineNumber, PurchaseRequisitionLineRequest request) {
        PurchaseRequisitionLine line = new PurchaseRequisitionLine();
        line.setLineNumber(lineNumber);
        if (request.itemId() != null) {
            Item item = itemRepository.findById(request.itemId())
                .orElseThrow(() -> new ResourceNotFoundException("Item not found: " + request.itemId()));
            line.setItem(item);
        }
        line.setDescription(request.description());
        line.setQuantity(request.quantity());
        line.setUom(request.uom());
        line.setEstimatedUnitPrice(request.estimatedUnitPrice());
        line.setEstimatedLineAmount(request.quantity().multiply(request.estimatedUnitPrice()));
        line.setRequiredByDate(request.requiredByDate());
        return line;
    }

    private PurchaseRequisitionResponse toResponse(PurchaseRequisition pr) {
        return new PurchaseRequisitionResponse(
            pr.getId(),
            pr.getPrNumber(),
            pr.getRequester().getId(),
            pr.getStatus(),
            pr.getCurrencyCode(),
            pr.getTotalAmount(),
            pr.getLines().stream().map(this::toLineResponse).toList()
        );
    }

    private PurchaseRequisitionLineResponse toLineResponse(PurchaseRequisitionLine line) {
        return new PurchaseRequisitionLineResponse(
            line.getId(),
            line.getLineNumber(),
            line.getItem() == null ? null : line.getItem().getId(),
            line.getDescription(),
            line.getQuantity(),
            line.getUom(),
            line.getEstimatedUnitPrice(),
            line.getEstimatedLineAmount()
        );
    }
}
