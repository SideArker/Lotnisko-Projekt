package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Airline;
import pl.lotnisko.backend.repository.AirlineRepository;

import java.util.List;

@RestController
@RequestMapping("/api/airlines")
public class AirlineController {

    private final AirlineRepository airlineRepository;

    public AirlineController(AirlineRepository airlineRepository) {
        this.airlineRepository = airlineRepository;
    }

    @GetMapping
    public List<Airline> getAllAirlines(){
        return airlineRepository.findAll();
    }

    @PostMapping
    public Airline addAirline(@RequestBody Airline request){
        return airlineRepository.save(request);
    }



}
