package pl.lotnisko.backend.controller;


import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.dto.CreatePassengerRequest;
import pl.lotnisko.backend.model.Passenger;
import pl.lotnisko.backend.repository.PassengerRepository;
import pl.lotnisko.backend.service.PassengerService;

import java.util.List;

@RestController
@RequestMapping("/api/passengers")
public class PassengerController {

    private final PassengerRepository passengerRepository;
    private final PassengerService passengerService;

    public PassengerController(PassengerRepository passengerRepository, PassengerService passengerService) {
        this.passengerRepository = passengerRepository;
        this.passengerService = passengerService;
    }

    @GetMapping
    public List<Passenger> getAllPassengers(){
        return passengerRepository.findAll();
    }

    @PostMapping
    public ResponseEntity<Void> addPassenger(@Valid @RequestBody CreatePassengerRequest request){
        Passenger passenger = passengerService.createPassenger(request);
        return ResponseEntity.status(HttpStatus.CREATED).build();
    }



}
