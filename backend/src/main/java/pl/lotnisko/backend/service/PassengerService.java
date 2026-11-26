package pl.lotnisko.backend.service;


import org.springframework.stereotype.Service;
import pl.lotnisko.backend.dto.CreatePassengerRequest;
import pl.lotnisko.backend.exception.ResourceNotFoundException;
import pl.lotnisko.backend.model.Country;
import pl.lotnisko.backend.model.Passenger;
import pl.lotnisko.backend.repository.CountryRepository;
import pl.lotnisko.backend.repository.PassengerRepository;

@Service
public class PassengerService {

    private final PassengerRepository passengerRepository;
    private final CountryRepository countryRepository;

    public PassengerService(PassengerRepository passengerRepository, CountryRepository countryRepository) {
        this.passengerRepository = passengerRepository;
        this.countryRepository = countryRepository;
    }

    public Passenger createPassenger(CreatePassengerRequest request){

        Country country = countryRepository.findById(request.getCountryCode())
                .orElseThrow(() -> new ResourceNotFoundException("Country not found"));


        Passenger passenger = new Passenger();
        passenger.setCitizenshipCountry(country);
        passenger.setEmail(request.getEmail());
        passenger.setFirstName(request.getFirstName());
        passenger.setLastName(request.getLastName());
        passenger.setPhoneNumber(request.getPhoneNumber());





            return passengerRepository.save(passenger);
    }

}
