package pl.lotnisko.backend.controller;


import org.springframework.web.bind.annotation.*;
import pl.lotnisko.backend.model.Certificate;
import pl.lotnisko.backend.repository.CertificateRepository;

import java.util.List;

@RestController
@RequestMapping("/api/certificates")
public class CertificateController {

    private final CertificateRepository certificateRepository;

    public CertificateController(CertificateRepository certificateRepository) {
        this.certificateRepository = certificateRepository;
    }

    @GetMapping
    public List<Certificate> getAllCertificates(){
        return certificateRepository.findAll();
    }

    @PostMapping
    public Certificate addCertificate(@RequestBody Certificate request){
        return certificateRepository.save(request);
    }

}
