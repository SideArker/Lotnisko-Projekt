package pl.lotnisko.backend.model;


import jakarta.persistence.*;

@Entity
@Table(name = "gates")
public class Gate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer gateId;



    @ManyToOne
    @JoinColumn(name = "terminal_id")
    private Terminal terminal;

    private String name;

    @Column(length = 20)
    private String status;


    public Gate() {
    }

    public Integer getGateId() {
        return gateId;
    }

    public void setGateId(Integer gateId) {
        this.gateId = gateId;
    }

    public Terminal getTerminal() {
        return terminal;
    }

    public void setTerminal(Terminal terminal) {
        this.terminal = terminal;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
