package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Passenger;
import pl.lotnisko.backend.repository.PassengerRepository;

import java.util.List;

@RestController
@RequestMapping("/api/passengers")
public class PassengerController {

    private final PassengerRepository passengerRepository;

    public PassengerController(PassengerRepository passengerRepository) {
        this.passengerRepository = passengerRepository;
    }


    @GetMapping
    public List<Passenger> getAllPassengers(){
        return passengerRepository.findAll();
    }

    @PostMapping
    public Passenger addPassenger(@RequestBody Passenger request){
        return passengerRepository.save(request);
    }



}
