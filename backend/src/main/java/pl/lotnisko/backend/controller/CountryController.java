package pl.lotnisko.backend.controller;


import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Country;
import pl.lotnisko.backend.repository.CountryRepository;

import java.util.List;

@RestController
@RequestMapping("/api/countries")
public class CountryController {

    private final CountryRepository countryRepository;


    public CountryController(CountryRepository countryRepository){
        this.countryRepository = countryRepository;
    }

    @GetMapping
    public List<Country> getAllCountries(){
        return countryRepository.findAll();
    }

    @PostMapping
    public Country addCountry(@RequestBody Country request){
        return countryRepository.save(request);
    }


}
