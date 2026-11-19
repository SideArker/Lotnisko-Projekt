package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Aircraft;

public interface AircraftRepository extends JpaRepository<Aircraft,Integer> {
}
