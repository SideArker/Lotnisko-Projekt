package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Airport;
import pl.lotnisko.backend.repository.AirportRepository;

import java.util.List;

@RestController
@RequestMapping("/api/airports")
public class AirportController {

    private final AirportRepository airportRepository;

    public AirportController(AirportRepository airportRepository) {
        this.airportRepository = airportRepository;
    }


    @GetMapping
    public List<Airport> getAllAirports(){
        return airportRepository.findAll();
    }

    @PostMapping
    public Airport addAirport(@RequestBody Airport request){
      return airportRepository.save(request);
    }

}
