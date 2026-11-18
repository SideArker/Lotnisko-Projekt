package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Airport;

public interface AirportRepository extends JpaRepository<Airport,Integer> {

}
