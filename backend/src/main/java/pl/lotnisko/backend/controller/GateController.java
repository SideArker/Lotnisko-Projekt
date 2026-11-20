package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Gate;
import pl.lotnisko.backend.repository.GateRepository;

import java.util.List;

@RestController
@RequestMapping("/api/gates")
public class GateController {

    final private GateRepository gateRepository;

    public GateController(GateRepository gateRepository) {
        this.gateRepository = gateRepository;
    }

    @GetMapping
    public List<Gate> getAllGates(){
        return gateRepository.findAll();
    }

    @PostMapping
    public Gate addGate(@RequestBody Gate request) {
        return gateRepository.save(request);
    }

}
