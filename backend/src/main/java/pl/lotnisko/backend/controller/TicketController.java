package pl.lotnisko.backend.controller;

import org.springframework.web.bind.annotation.*;
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
    public Ticket addTicket(@RequestBody Ticket request){
        return ticketRepository.save(request);
    }


}
