package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Airline;

public interface AirlineRepository extends JpaRepository<Airline,Integer> {
}
