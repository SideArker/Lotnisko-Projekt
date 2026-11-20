package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Gate;

public interface GateRepository extends JpaRepository<Gate,Integer> {
}
