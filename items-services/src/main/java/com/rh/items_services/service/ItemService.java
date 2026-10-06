package com.rh.items_services.service;

import com.rh.items_services.model.dto.ItemRequest;
import com.rh.items_services.model.dto.ItemResponse;
import com.rh.items_services.model.entity.Item;
import com.rh.items_services.repository.ItemsRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class ItemService {

    private final ItemsRepository itemsRepository;

    public void addItem(ItemRequest itemRequest){
        var item = Item.builder()
                .sku(itemRequest.sku())
                .name(itemRequest.name())
                .description(itemRequest.description())
                .price(itemRequest.price())
                .status(itemRequest.status()).build();

        this.itemsRepository.save(item);
        log.info("Item added: {}", item);
    }
    public List<ItemResponse> getAllItems () {
        var items = this.itemsRepository.findAll();
        return items.stream().map(this::mapToItemResponse).toList();
    }

    private ItemResponse mapToItemResponse(Item item) {
        return new ItemResponse(item.getId(),item.getSku(),item.getName(),
                item.getDescription(),item.getPrice(),item.getStatus());
    }


}
