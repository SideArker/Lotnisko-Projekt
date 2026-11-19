package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Aircraft;
import pl.lotnisko.backend.repository.AircraftRepository;

import java.util.List;


@RestController
@RequestMapping("/api/aircraft")
public class AircraftController {

    final private AircraftRepository aircraftRepository;

    public AircraftController(AircraftRepository aircraftRepository) {
        this.aircraftRepository = aircraftRepository;
    }

    @GetMapping
    public List<Aircraft> getAllAircraft(){
        return aircraftRepository.findAll();
    }


    @PostMapping
    public Aircraft addAircraft(@RequestBody Aircraft request){
        return aircraftRepository.save(request);
    }




}
