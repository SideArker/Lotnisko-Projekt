package pl.lotnisko.backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import pl.lotnisko.backend.model.Certificate;

public interface CertificateRepository extends JpaRepository<Certificate,Integer> {
}
