package pl.lotnisko.backend.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.dto.CreateTicketRequest;
import pl.lotnisko.backend.model.Ticket;
import pl.lotnisko.backend.repository.TicketRepository;

import java.util.List;


@RestController
@RequestMapping("/api/tickets")
public class TicketController {
    
   final private TicketRepository ticketRepository;

    public TicketController(TicketRepository ticketRepository) {
        this.ticketRepository = ticketRepository;
    }

    @GetMapping
    public List<Ticket> getAllTickets(){
        return ticketRepository.findAll();
    }

    @PostMapping
    public ResponseEntity<Void> createTicket  (@Valid @RequestBody CreateTicketRequest request){
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }


}
