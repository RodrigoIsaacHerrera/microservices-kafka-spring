package com.rh.items_services.model.dto;

public record ItemResponse(Long id,
                           String sku,
                           String name,
                           String description,
                           Double price,
                           Boolean status) {
}
