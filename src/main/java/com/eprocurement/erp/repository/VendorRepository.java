package com.eprocurement.erp.repository;

import com.eprocurement.erp.domain.entity.Vendor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface VendorRepository extends JpaRepository<Vendor, UUID> {
    Optional<Vendor> findByVendorCodeIgnoreCase(String vendorCode);
    boolean existsByVendorCodeIgnoreCase(String vendorCode);
}
