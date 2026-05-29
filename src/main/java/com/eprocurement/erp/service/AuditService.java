package com.eprocurement.erp.service;

import com.eprocurement.erp.domain.entity.AuditLog;
import com.eprocurement.erp.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuditService {
    private final AuditLogRepository auditLogRepository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(String entityType, UUID entityId, String action, UUID actorUserId, Map<String, Object> changedFields) {
        AuditLog auditLog = new AuditLog();
        auditLog.setEntityType(entityType);
        auditLog.setEntityId(entityId);
        auditLog.setAction(action);
        auditLog.setActorUserId(actorUserId);
        auditLog.setChangedFields(changedFields);
        auditLog.setCorrelationId(UUID.randomUUID());
        auditLogRepository.save(auditLog);
    }
}
