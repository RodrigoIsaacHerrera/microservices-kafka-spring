package com.rh.items_services.controller;

import com.rh.items_services.model.dto.ItemRequest;
import com.rh.items_services.model.dto.ItemResponse;
import com.rh.items_services.service.ItemService;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestControllerAdvice
@RequestMapping("/api/items/v1")
public class ItemController{

    private final ItemService itemService;

    ItemController(ItemService itemService){
        this.itemService = itemService;

    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void addItem (@RequestBody ItemRequest itemRequest){
        this.itemService.addItem(itemRequest);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<ItemResponse> getAllItems(){
        return this.itemService.getAllItems();
    }
}
