package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Terminal;

public interface TerminalRepository extends JpaRepository<Terminal,Integer> {
}
