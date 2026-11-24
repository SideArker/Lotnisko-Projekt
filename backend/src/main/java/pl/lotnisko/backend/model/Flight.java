package pl.lotnisko.backend.model;


import jakarta.persistence.*;

import java.time.Instant;


@Entity
@Table(name = "flights")
public class Flight {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer flightId;


    @ManyToOne
    @JoinColumn(name = "aircraft_id")
    private Aircraft aircraft;


    @Column(length = 10)
    private  String flightNumber;

    @ManyToOne
    @JoinColumn(name = "origin_airport_id")
    private Airport originAirport;

    @ManyToOne
    @JoinColumn(name = "destination_airport_id")
    private Airport destinationAirport;

    private Instant departureTime;
    private Instant arrivalTime;
    private Instant actualDepartureTime;
    private Instant actualArrivalTime;
    private String status;

    @ManyToOne
    @JoinColumn(name = "gate_id")
    private Gate gate;


    public Flight() {
    }


    public Integer getFlightId() {
        return flightId;
    }

    public void setFlightId(Integer flightId) {
        this.flightId = flightId;
    }

    public Aircraft getAircraft() {
        return aircraft;
    }

    public void setAircraft(Aircraft aircraft) {
        this.aircraft = aircraft;
    }

    public String getFlightNumber() {
        return flightNumber;
    }

    public void setFlightNumber(String flightNumber) {
        this.flightNumber = flightNumber;
    }

    public Airport getOriginAirport() {
        return originAirport;
    }

    public void setOriginAirport(Airport originAirport) {
        this.originAirport = originAirport;
    }

    public Airport getDestinationAirport() {
        return destinationAirport;
    }

    public void setDestinationAirport(Airport destinationAirport) {
        this.destinationAirport = destinationAirport;
    }

    public Instant getDepartureTime() {
        return departureTime;
    }

    public void setDepartureTime(Instant departureTime) {
        this.departureTime = departureTime;
    }

    public Instant getArrivalTime() {
        return arrivalTime;
    }

    public void setArrivalTime(Instant arrivalTime) {
        this.arrivalTime = arrivalTime;
    }

    public Instant getActualDepartureTime() {
        return actualDepartureTime;
    }

    public void setActualDepartureTime(Instant actualDepartureTime) {
        this.actualDepartureTime = actualDepartureTime;
    }

    public Instant getActualArrivalTime() {
        return actualArrivalTime;
    }

    public void setActualArrivalTime(Instant actualArrivalTime) {
        this.actualArrivalTime = actualArrivalTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Gate getGate() {
        return gate;
    }

    public void setGate(Gate gate) {
        this.gate = gate;
    }
}
