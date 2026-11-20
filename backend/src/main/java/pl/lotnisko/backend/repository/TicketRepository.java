package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Ticket;

public interface TicketRepository extends JpaRepository<Ticket,Integer> {
}
