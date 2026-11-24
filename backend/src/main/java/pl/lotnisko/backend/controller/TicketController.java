package pl.lotnisko.backend.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.dto.CreateTicketRequest;
import pl.lotnisko.backend.dto.TicketResponse;
import pl.lotnisko.backend.service.TicketService;

import java.util.UUID;


@RestController
@RequestMapping("/api/tickets")
public class TicketController {
    
   final private TicketService ticketService;

    public TicketController(TicketService ticketService) {
        this.ticketService = ticketService;
    }


    @GetMapping("/{id}")
    public ResponseEntity<TicketResponse> getTicket(@PathVariable UUID id){
        TicketResponse response = ticketService.getTicket(id);
        return ResponseEntity.status(HttpStatus.OK).body(response);
    }



    @PostMapping
    public ResponseEntity<Void> createTicket  (@Valid @RequestBody CreateTicketRequest request){

        ticketService.createTicket(request);

        return ResponseEntity.status(HttpStatus.CREATED).build();
    }


}
