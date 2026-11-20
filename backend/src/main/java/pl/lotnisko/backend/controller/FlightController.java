package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Aircraft;
import pl.lotnisko.backend.model.Flight;
import pl.lotnisko.backend.repository.AircraftRepository;
import pl.lotnisko.backend.repository.FlightRepository;

import java.util.List;

@RestController
@RequestMapping("/api/flights")
public class FlightController {


    private final FlightRepository flightRepository;

    public FlightController(FlightRepository flightRepository) {
        this.flightRepository = flightRepository;
    }

    @GetMapping
    public List<Flight> getAllflights(){
        return flightRepository.findAll();
    }


    @PostMapping
    public Flight addFlight(@RequestBody Flight request){
        return flightRepository.save(request);
    }





}
