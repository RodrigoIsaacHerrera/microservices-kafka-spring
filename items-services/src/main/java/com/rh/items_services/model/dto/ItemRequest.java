package com.rh.items_services.model.dto;

public record ItemRequest(String sku,
                          String name,
                          String description,
                          Double price,
                          Boolean status) {
}
