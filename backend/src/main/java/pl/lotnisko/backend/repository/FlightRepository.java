package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Flight;

public interface FlightRepository extends JpaRepository<Flight,Integer> {
}
