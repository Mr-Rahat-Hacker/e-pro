package com.eprocurement.erp.repository;

import com.eprocurement.erp.domain.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ItemRepository extends JpaRepository<Item, UUID> {
}
