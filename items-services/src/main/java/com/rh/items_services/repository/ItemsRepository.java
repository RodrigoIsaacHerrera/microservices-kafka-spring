package com.rh.items_services.repository;

import com.rh.items_services.model.entity.Item;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ItemsRepository extends JpaRepository<Item, Long> {

}
