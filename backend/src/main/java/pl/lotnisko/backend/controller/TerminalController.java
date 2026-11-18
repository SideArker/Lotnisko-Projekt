package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Terminal;
import pl.lotnisko.backend.repository.CountryRepository;
import pl.lotnisko.backend.repository.TerminalRepository;

import java.util.List;

@RestController
@RequestMapping("/api/terminals")
public class TerminalController {


    private final TerminalRepository terminalRepository;


    public TerminalController(TerminalRepository terminalRepository){
        this.terminalRepository = terminalRepository;
    }

    @GetMapping
    public List<Terminal> getAllTerminals(){
        return terminalRepository.findAll();
    }


    @PostMapping
    public Terminal addTerminal(@RequestBody Terminal request){
       return terminalRepository.save(request);
    }



}
