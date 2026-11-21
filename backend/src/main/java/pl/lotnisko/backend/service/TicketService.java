package pl.lotnisko.backend.service;


import org.springframework.stereotype.Service;
import pl.lotnisko.backend.dto.CreateTicketRequest;
import pl.lotnisko.backend.exception.ConflictException;
import pl.lotnisko.backend.exception.ResourceNotFoundException;
import pl.lotnisko.backend.model.Flight;
import pl.lotnisko.backend.model.Passenger;
import pl.lotnisko.backend.model.Ticket;
import pl.lotnisko.backend.repository.FlightRepository;
import pl.lotnisko.backend.repository.PassengerRepository;
import pl.lotnisko.backend.repository.TicketRepository;

import java.math.BigDecimal;
import java.time.Instant;

@Service
public class TicketService {

    private final TicketRepository ticketRepository;
    private final FlightRepository flightRepository;
    private final PassengerRepository passengerRepository;


    public TicketService(TicketRepository ticketRepository, FlightRepository flightRepository, PassengerRepository passengerRepository) {
        this.ticketRepository = ticketRepository;
        this.flightRepository = flightRepository;
        this.passengerRepository = passengerRepository;
    }

    public Ticket createTicket(CreateTicketRequest request){
        Flight flight = flightRepository.findById(request.getFlightId())
                .orElseThrow(() -> new ResourceNotFoundException("Flight not found"));

        Passenger passenger = passengerRepository.findById(request.getPassengerId())
                .orElseThrow(() -> new ResourceNotFoundException("Passenger not found"));


        if ( ticketRepository.existsByFlight_FlightIdAndSeatNumber(request.getFlightId(),request.getSeatNumber()))
        {
            throw new ConflictException("Seat is already taken");
        }


        Ticket ticket = new Ticket();
        ticket.setPassenger(passenger);
        ticket.setFlight(flight);
        ticket.setPrice(BigDecimal.ZERO);
        ticket.setPurchaseDate(Instant.now());
        ticket.setSeatNumber(request.getSeatNumber());
        ticket.setTravelClass(request.getTravelClass());
        ticket.setStatus("booked");
        return ticketRepository.save(ticket);

    }
}
