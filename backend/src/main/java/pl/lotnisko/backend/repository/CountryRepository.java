package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Country;

public interface CountryRepository extends JpaRepository<Country, String> {
}
