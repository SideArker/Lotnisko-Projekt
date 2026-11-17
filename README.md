# Lotnisko Projekt (Monorepo)

Projekt systemu lotniskowego w architekturze monorepo:
- **Baza danych**: MariaDB 11.4 (`port 3306`)
- **Backend**: Java 21 + Spring Boot (`port 8080`)
- **Frontend**: React + Vite + TypeScript + React Router (`port 5173`)

## Uruchomienie całego projektu (Docker Compose)

Nie musisz instalować Javy ani Node.js lokalnie – wszystko uruchamia się jednym poleceniem wraz z **hot-reloadem** przy edycji plików w `backend/src` oraz `frontend/src`:

```bash
docker compose up --build
```
*(lub z flagą `-d`, aby uruchomić w tle: `docker compose up -d --build`)*

### Dostępne adresy po uruchomieniu:
- **Frontend (React)**: [http://localhost:5173](http://localhost:5173)
- **Backend API (Spring Boot)**: [http://localhost:8080/api/health](http://localhost:8080/api/health)
- **Baza danych (MariaDB)**: `localhost:3306` (użytkownik: `lotnisko_user`, hasło: `lotnisko_pass`, baza: `lotnisko`)

### Przydatne komendy:
- Podgląd logów: `docker compose logs -f`
- Zatrzymanie kontenerów: `docker compose down`
- Zatrzymanie wraz z wyczyszczeniem bazy danych: `docker compose down -v`
