package pl.lotnisko.backend.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public class CreateTicketRequest {

    @NotNull
    private Integer flightId;

    @NotNull
    private Integer passengerId;

    @NotBlank
    @Size(max = 5)
    private String seatNumber;

    @NotBlank
    private String travelClass;

    public Integer getFlightId() {
        return flightId;
    }

    public void setFlightId(Integer flightId) {
        this.flightId = flightId;
    }

    public Integer getPassengerId() {
        return passengerId;
    }

    public void setPassengerId(Integer passengerId) {
        this.passengerId = passengerId;
    }

    public String getSeatNumber() {
        return seatNumber;
    }

    public void setSeatNumber(String seatNumber) {
        this.seatNumber = seatNumber;
    }

    public String getTravelClass() {
        return travelClass;
    }

    public void setTravelClass(String travelClass) {
        this.travelClass = travelClass;
    }
}
