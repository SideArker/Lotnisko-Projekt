package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Passenger;

public interface PassengerRepository extends JpaRepository<Passenger,Integer> {
}
