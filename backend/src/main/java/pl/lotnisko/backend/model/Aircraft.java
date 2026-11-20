package pl.lotnisko.backend.model;


import jakarta.persistence.*;

@Entity
@Table(name = "aircraft")
public class Aircraft {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer aircraftId;

    @ManyToOne
    @JoinColumn(name = "airline_id")
    private Airline airline;

    private String model;

    @Column(unique = true)
    private String registration;

    private Integer seats;

    public Aircraft() {
    }

    public Integer getAircraftId() {
        return aircraftId;
    }

    public void setAircraftId(Integer aircraftId) {
        this.aircraftId = aircraftId;
    }

    public Airline getAirline() {
        return airline;
    }

    public void setAirline(Airline airline) {
        this.airline = airline;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getRegistration() {
        return registration;
    }

    public void setRegistration(String registration) {
        this.registration = registration;
    }

    public Integer getSeats() {
        return seats;
    }

    public void setSeats(Integer seats) {
        this.seats = seats;
    }
}
