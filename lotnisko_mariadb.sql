-- Schemat lotniska KRK | MariaDB 11.x
-- Skrypt inicjalizacyjny: CREATE OR REPLACE TABLE może usunąć istniejące dane.
-- Wykonuj jako skrypt (DELIMITER wymagany przy procedurach i triggerach).

SET NAMES utf8mb4;
 SET FOREIGN_KEY_CHECKS = 0;   -- przebudowa schematu; istniejące dane mogą zostać usunięte

-- ---------------------------------------------------------------------
 -- 1. TABELE
 -- ---------------------------------------------------------------------

CREATE OR REPLACE TABLE `Countries` (
   `country_code` CHAR(2) NOT NULL,
   `name`         VARCHAR(255) NOT NULL,
   `phone_prefix` VARCHAR(8) NOT NULL,
   PRIMARY KEY (`country_code`),
   UNIQUE KEY `uq_country_name` (`name`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Słownik krajów (ISO 3166-1 alpha-2)';

CREATE OR REPLACE TABLE `Terminals` (
   `terminal_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `name`          VARCHAR(255) NOT NULL,
   `terminal_type` VARCHAR(20) NOT NULL DEFAULT 'passenger' COMMENT 'passenger, cargo, general_aviation',
   `status`        VARCHAR(20) NOT NULL DEFAULT 'open'      COMMENT 'open, closed, maintenance',
   PRIMARY KEY (`terminal_id`),
   UNIQUE KEY `uq_terminal_name` (`name`),
   CONSTRAINT `chk_terminal_type`   CHECK (`terminal_type` IN ('passenger','cargo','general_aviation')),
   CONSTRAINT `chk_terminal_status` CHECK (`status` IN ('open','closed','maintenance'))
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Gates` (
   `gate_id`     INTEGER NOT NULL AUTO_INCREMENT,
   `terminal_id` INTEGER NOT NULL,
   `name`        VARCHAR(255) NOT NULL,
   `status`      VARCHAR(20) NOT NULL DEFAULT 'open' COMMENT 'open, closed, maintenance',
   PRIMARY KEY (`gate_id`),
   UNIQUE KEY `uq_gate_per_terminal` (`terminal_id`, `name`),
   CONSTRAINT `chk_gate_status` CHECK (`status` IN ('open','closed','maintenance')),
   CONSTRAINT `fk_gates_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `Terminals` (`terminal_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Airports` (
   `airport_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `iata_code`    CHAR(3) NOT NULL,
   `icao_code`    CHAR(4) NOT NULL,
   `name`         VARCHAR(255) NOT NULL,
   `city`         VARCHAR(255) NOT NULL,
   `country_code` CHAR(2) NOT NULL,
   `is_home`      TINYINT(1) NULL DEFAULT NULL
     COMMENT '1 = lotnisko obsługiwane przez system (Kraków KRK); NULL = lotnisko zewnętrzne. Unikalność gwarantuje, że może być tylko jedno',
   PRIMARY KEY (`airport_id`),
   UNIQUE KEY `uq_airport_iata` (`iata_code`),
   UNIQUE KEY `uq_airport_icao` (`icao_code`),
   UNIQUE KEY `uq_airport_is_home` (`is_home`),
   CONSTRAINT `chk_airport_is_home` CHECK (`is_home` IS NULL OR `is_home` = 1),
   CONSTRAINT `fk_airports_country` FOREIGN KEY (`country_code`) REFERENCES `Countries` (`country_code`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Kraków (KRK) + lotniska docelowe/początkowe tras obsługiwanych z Krakowa';

CREATE OR REPLACE TABLE `Airlines` (
   `airline_id`             INTEGER NOT NULL AUTO_INCREMENT,
   `iata_code`              CHAR(2) NOT NULL,
   `icao_code`              CHAR(3) NOT NULL,
   `name`                   VARCHAR(255) NOT NULL,
   `emergency_phone_number` VARCHAR(20) NOT NULL,
   `country_code`           CHAR(2) NOT NULL,
   PRIMARY KEY (`airline_id`),
   UNIQUE KEY `uq_airline_iata` (`iata_code`),
   UNIQUE KEY `uq_airline_icao` (`icao_code`),
   CONSTRAINT `fk_airlines_country` FOREIGN KEY (`country_code`) REFERENCES `Countries` (`country_code`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Aircraft` (
   `aircraft_id`  INTEGER NOT NULL AUTO_INCREMENT,
   `airline_id`   INTEGER NOT NULL,
   `model`        VARCHAR(255) NOT NULL,
   `registration` VARCHAR(255) NOT NULL,
   `seats`        INTEGER NOT NULL,
   PRIMARY KEY (`aircraft_id`),
   UNIQUE KEY `uq_aircraft_registration` (`registration`),
   CONSTRAINT `chk_aircraft_seats` CHECK (`seats` > 0),
   CONSTRAINT `fk_aircraft_airline` FOREIGN KEY (`airline_id`) REFERENCES `Airlines` (`airline_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Flights` (
   `flight_id`              INTEGER NOT NULL AUTO_INCREMENT,
   `aircraft_id`            INTEGER NOT NULL,
   `flight_number`          VARCHAR(10) NOT NULL,
   `origin_airport_id`      INTEGER NOT NULL,
   `destination_airport_id` INTEGER NOT NULL,
   `departure_time`         DATETIME NOT NULL COMMENT 'planowany odlot',
   `arrival_time`           DATETIME NOT NULL COMMENT 'planowany przylot',
   `actual_departure_time`  DATETIME NULL COMMENT 'faktyczny odlot',
   `actual_arrival_time`    DATETIME NULL COMMENT 'faktyczny przylot',
   `status`                 VARCHAR(20) NOT NULL DEFAULT 'scheduled'
     COMMENT 'scheduled, boarding, departed, arrived, delayed, cancelled, diverted',
   `gate_id`                INTEGER NULL COMMENT 'NULL do czasu przydzielenia bramki',
   PRIMARY KEY (`flight_id`),
   UNIQUE KEY `uq_flight_number_departure` (`flight_number`, `departure_time`),
   KEY `idx_flights_departure` (`departure_time`),
   CONSTRAINT `chk_flight_airports` CHECK (`origin_airport_id` <> `destination_airport_id`),
   CONSTRAINT `chk_flight_times`    CHECK (`arrival_time` > `departure_time`),
   CONSTRAINT `chk_flight_actual`   CHECK (`actual_arrival_time` IS NULL OR `actual_departure_time` IS NULL
                                           OR `actual_arrival_time` >= `actual_departure_time`),
   CONSTRAINT `chk_flight_status`   CHECK (`status` IN ('scheduled','boarding','departed','arrived','delayed','cancelled','diverted')),
   CONSTRAINT `fk_flights_aircraft`    FOREIGN KEY (`aircraft_id`)            REFERENCES `Aircraft` (`aircraft_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT,
   CONSTRAINT `fk_flights_origin`      FOREIGN KEY (`origin_airport_id`)      REFERENCES `Airports` (`airport_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT,
   CONSTRAINT `fk_flights_destination` FOREIGN KEY (`destination_airport_id`) REFERENCES `Airports` (`airport_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT,
   CONSTRAINT `fk_flights_gate`        FOREIGN KEY (`gate_id`)                REFERENCES `Gates` (`gate_id`)
     ON UPDATE NO ACTION ON DELETE SET NULL
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Kierunek (odlot/przylot) i opóźnienie są liczone w widoku v_flights';

CREATE OR REPLACE TABLE `Passengers` (
   `passenger_id`             INTEGER NOT NULL AUTO_INCREMENT,
   `first_name`               VARCHAR(100) NOT NULL,
   `last_name`                VARCHAR(100) NOT NULL,
   `phone_number`             VARCHAR(20) NOT NULL,
   `email`                    VARCHAR(255) NOT NULL,
   `citizenship_country_code` CHAR(2) NOT NULL,
   PRIMARY KEY (`passenger_id`),
   UNIQUE KEY `uq_passenger_email` (`email`),
   CONSTRAINT `fk_passengers_country` FOREIGN KEY (`citizenship_country_code`) REFERENCES `Countries` (`country_code`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Tickets` (
   `ticket_id`     INTEGER NOT NULL AUTO_INCREMENT,
   `passenger_id`  INTEGER NOT NULL,
   `flight_id`     INTEGER NOT NULL,
   `seat_number`   VARCHAR(5) NOT NULL,
   `travel_class`  VARCHAR(20) NOT NULL DEFAULT 'economy' COMMENT 'economy, premium_economy, business, first',
   `price`         DECIMAL(10,2) NOT NULL,
   `purchase_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
   `status`        VARCHAR(20) NOT NULL DEFAULT 'booked' COMMENT 'booked, checked_in, boarded, cancelled, no_show',
   PRIMARY KEY (`ticket_id`),
   UNIQUE KEY `uq_ticket_seat_per_flight`      (`flight_id`, `seat_number`),
   UNIQUE KEY `uq_ticket_passenger_per_flight` (`flight_id`, `passenger_id`),
   KEY `idx_tickets_passenger` (`passenger_id`),
   CONSTRAINT `chk_ticket_price`  CHECK (`price` >= 0),
   CONSTRAINT `chk_ticket_class`  CHECK (`travel_class` IN ('economy','premium_economy','business','first')),
   CONSTRAINT `chk_ticket_status` CHECK (`status` IN ('booked','checked_in','boarded','cancelled','no_show')),
   CONSTRAINT `fk_tickets_passenger` FOREIGN KEY (`passenger_id`) REFERENCES `Passengers` (`passenger_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT,
   CONSTRAINT `fk_tickets_flight`    FOREIGN KEY (`flight_id`)    REFERENCES `Flights` (`flight_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Baggage` (
   `baggage_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `ticket_id`    INTEGER NOT NULL,
   `tag_number`   VARCHAR(255) NOT NULL,
   `weight_kg`    DECIMAL(5,2) NOT NULL,
   `baggage_type` VARCHAR(20) NOT NULL DEFAULT 'checked'    COMMENT 'checked, cabin, special',
   `status`       VARCHAR(20) NOT NULL DEFAULT 'registered' COMMENT 'registered, loaded, in_transit, arrived, lost',
   PRIMARY KEY (`baggage_id`),
   UNIQUE KEY `uq_baggage_tag` (`tag_number`),
   KEY `idx_baggage_ticket` (`ticket_id`),
   CONSTRAINT `chk_baggage_weight` CHECK (`weight_kg` > 0),
   CONSTRAINT `chk_baggage_type`   CHECK (`baggage_type` IN ('checked','cabin','special')),
   CONSTRAINT `chk_baggage_status` CHECK (`status` IN ('registered','loaded','in_transit','arrived','lost')),
   CONSTRAINT `fk_baggage_ticket` FOREIGN KEY (`ticket_id`) REFERENCES `Tickets` (`ticket_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Loyalty_Program` (
   `loyalty_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `passenger_id` INTEGER NOT NULL COMMENT 'unique = relacja 1:1 z pasażerem',
   `points`       INTEGER NOT NULL DEFAULT 0,
   `card_number`  VARCHAR(255) NOT NULL,
   PRIMARY KEY (`loyalty_id`),
   UNIQUE KEY `uq_loyalty_passenger` (`passenger_id`),
   UNIQUE KEY `uq_loyalty_card` (`card_number`),
   CONSTRAINT `chk_loyalty_points` CHECK (`points` >= 0),
   CONSTRAINT `fk_loyalty_passenger` FOREIGN KEY (`passenger_id`) REFERENCES `Passengers` (`passenger_id`)
     ON UPDATE NO ACTION ON DELETE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Program lojalnościowy LOTNISKA (nie linii lotniczych) - jeden program, jedna karta na pasażera';

CREATE OR REPLACE TABLE `Lounges` (
   `lounge_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `terminal_id` INTEGER NOT NULL,
   `name`        VARCHAR(255) NOT NULL,
   `capacity`    INTEGER NULL,
   PRIMARY KEY (`lounge_id`),
   UNIQUE KEY `uq_lounge_per_terminal` (`terminal_id`, `name`),
   CONSTRAINT `chk_lounge_capacity` CHECK (`capacity` IS NULL OR `capacity` > 0),
   CONSTRAINT `fk_lounges_terminal` FOREIGN KEY (`terminal_id`) REFERENCES `Terminals` (`terminal_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Saloniki VIP dla gości (w terminalach)';

CREATE OR REPLACE TABLE `Lounge_Access` (
   `access_id`    INTEGER NOT NULL AUTO_INCREMENT,
   `passenger_id` INTEGER NOT NULL,
   `access_type`  VARCHAR(20) NOT NULL DEFAULT 'loyalty'
     COMMENT 'podstawa prawa wejścia: loyalty, business_class, paid, other',
   `valid_from`   DATE NOT NULL,
   `valid_until`  DATE NOT NULL,
   PRIMARY KEY (`access_id`),
   KEY `idx_lounge_access_passenger` (`passenger_id`, `valid_from`, `valid_until`),
   CONSTRAINT `chk_access_dates` CHECK (`valid_until` >= `valid_from`),
   CONSTRAINT `chk_access_type`  CHECK (`access_type` IN ('loyalty','business_class','paid','other')),
   CONSTRAINT `fk_lounge_access_passenger` FOREIGN KEY (`passenger_id`) REFERENCES `Passengers` (`passenger_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Uprawnienia gości do wejścia do saloników VIP (okres ważności i podstawa)';

CREATE OR REPLACE TABLE `Lounge_Visits` (
   `visit_id`   INTEGER NOT NULL AUTO_INCREMENT,
   `access_id`  INTEGER NOT NULL,
   `lounge_id`  INTEGER NOT NULL,
   `entry_time` DATETIME NOT NULL,
   `exit_time`  DATETIME NULL COMMENT 'NULL = pasażer nadal w salonie VIP',
   PRIMARY KEY (`visit_id`),
   KEY `idx_visits_access` (`access_id`),
   KEY `idx_visits_lounge` (`lounge_id`, `entry_time`),
   CONSTRAINT `chk_visit_times` CHECK (`exit_time` IS NULL OR `exit_time` >= `entry_time`),
   CONSTRAINT `fk_visits_access` FOREIGN KEY (`access_id`) REFERENCES `Lounge_Access` (`access_id`)
     ON UPDATE NO ACTION ON DELETE CASCADE,
   CONSTRAINT `fk_visits_lounge` FOREIGN KEY (`lounge_id`) REFERENCES `Lounges` (`lounge_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
   COMMENT='Wizyty gości w salonikach VIP';

CREATE OR REPLACE TABLE `Employees` (
   `employee_id`        INTEGER NOT NULL AUTO_INCREMENT,
   `airline_id`         INTEGER NULL COMMENT 'NULL = pracownik lotniska, wartość = pracownik linii',
   `first_name`         VARCHAR(100) NOT NULL,
   `last_name`          VARCHAR(100) NOT NULL,
   `position`           VARCHAR(100) NOT NULL,
   `phone_number`       VARCHAR(20) NOT NULL,
   `email`              VARCHAR(255) NOT NULL,
   `date_of_birth`      DATE NOT NULL,
   `date_of_employment` DATE NOT NULL,
   PRIMARY KEY (`employee_id`),
   UNIQUE KEY `uq_employee_email` (`email`),
   KEY `idx_employees_airline` (`airline_id`),
   CONSTRAINT `chk_employee_dates` CHECK (`date_of_employment` > `date_of_birth`),
   CONSTRAINT `fk_employees_airline` FOREIGN KEY (`airline_id`) REFERENCES `Airlines` (`airline_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Certificates` (
   `certificate_id` INTEGER NOT NULL AUTO_INCREMENT,
   `name`           VARCHAR(250) NOT NULL,
   PRIMARY KEY (`certificate_id`),
   UNIQUE KEY `uq_certificate_name` (`name`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Employee_Certificates` (
   `employee_certificate_id` INTEGER NOT NULL AUTO_INCREMENT,
   `employee_id`             INTEGER NOT NULL,
   `certificate_id`          INTEGER NOT NULL,
   `issue_date`              DATE NOT NULL,
   `expiry_date`             DATE NULL,
   PRIMARY KEY (`employee_certificate_id`),
   UNIQUE KEY `uq_employee_certificate_issue` (`employee_id`, `certificate_id`, `issue_date`),
   KEY `idx_empcert_certificate` (`certificate_id`),
   CONSTRAINT `chk_empcert_dates` CHECK (`expiry_date` IS NULL OR `expiry_date` > `issue_date`),
   CONSTRAINT `fk_empcert_employee`    FOREIGN KEY (`employee_id`)    REFERENCES `Employees` (`employee_id`)
     ON UPDATE NO ACTION ON DELETE CASCADE,
   CONSTRAINT `fk_empcert_certificate` FOREIGN KEY (`certificate_id`) REFERENCES `Certificates` (`certificate_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE OR REPLACE TABLE `Flight_Crew` (
   `flight_crew_id` INTEGER NOT NULL AUTO_INCREMENT,
   `flight_id`      INTEGER NOT NULL,
   `employee_id`    INTEGER NOT NULL,
   `role`           VARCHAR(20) NOT NULL COMMENT 'captain, first_officer, cabin_crew, ground_staff',
   `duty_start`     DATETIME NOT NULL,
   `duty_end`       DATETIME NOT NULL,
   `status`         VARCHAR(20) NOT NULL DEFAULT 'assigned' COMMENT 'assigned, confirmed, completed, cancelled',
   PRIMARY KEY (`flight_crew_id`),
   UNIQUE KEY `uq_crew_member_per_flight` (`flight_id`, `employee_id`),
   KEY `idx_crew_employee` (`employee_id`, `duty_start`, `duty_end`),
   CONSTRAINT `chk_crew_duty`   CHECK (`duty_end` > `duty_start`),
   CONSTRAINT `chk_crew_role`   CHECK (`role` IN ('captain','first_officer','cabin_crew','ground_staff')),
   CONSTRAINT `chk_crew_status` CHECK (`status` IN ('assigned','confirmed','completed','cancelled')),
   CONSTRAINT `fk_crew_flight`   FOREIGN KEY (`flight_id`)   REFERENCES `Flights` (`flight_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT,
   CONSTRAINT `fk_crew_employee` FOREIGN KEY (`employee_id`) REFERENCES `Employees` (`employee_id`)
     ON UPDATE NO ACTION ON DELETE RESTRICT
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Konto aplikacji: dokładnie jeden właściciel (pasażer albo pracownik).
CREATE OR REPLACE TABLE `User_Accounts` (
  `user_id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` VARCHAR(20) NOT NULL,
  `passenger_id` INT NULL,
  `employee_id` INT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_account_email` (`email`),
  UNIQUE KEY `uq_account_passenger` (`passenger_id`),
  UNIQUE KEY `uq_account_employee` (`employee_id`),
  CONSTRAINT `chk_account_owner` CHECK (
    (`role` = 'passenger' AND `passenger_id` IS NOT NULL AND `employee_id` IS NULL) OR
    (`role` = 'employee' AND `employee_id` IS NOT NULL AND `passenger_id` IS NULL)
  ),
  CONSTRAINT `chk_account_active` CHECK (`is_active` IN (0, 1)),
  CONSTRAINT `fk_account_passenger` FOREIGN KEY (`passenger_id`) REFERENCES `Passengers` (`passenger_id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_account_employee` FOREIGN KEY (`employee_id`) REFERENCES `Employees` (`employee_id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- ---------------------------------------------------------------------
 -- 2. WIDOK: kierunek lotu i opóźnienie liczone z danych
 --    direction = 'departure' gdy lot wylatuje z lotniska własnego (KRK),
 --                'arrival'   gdy do niego przylatuje
 --    delay_minutes: dla odlotu różnica odlot faktyczny - planowany,
 --                   dla przylotu przylot faktyczny - planowany (NULL do czasu faktycznych danych)
 -- ---------------------------------------------------------------------

CREATE OR REPLACE VIEW `v_flights` AS
 SELECT
   f.`flight_id`,
   f.`flight_number`,
   CASE WHEN ao.`is_home` = 1 THEN 'departure' ELSE 'arrival' END AS `direction`,
   ao.`iata_code` AS `origin_iata`,
   ad.`iata_code` AS `destination_iata`,
   f.`departure_time`,
   f.`arrival_time`,
   f.`actual_departure_time`,
   f.`actual_arrival_time`,
   CASE WHEN ao.`is_home` = 1
     THEN TIMESTAMPDIFF(MINUTE, f.`departure_time`, f.`actual_departure_time`)
     ELSE TIMESTAMPDIFF(MINUTE, f.`arrival_time`,   f.`actual_arrival_time`)
   END AS `delay_minutes`,
   f.`status`,
   g.`name` AS `gate`,
   a.`registration`,
   al.`iata_code` AS `airline_iata`
 FROM `Flights` f
 JOIN `Airports` ao ON ao.`airport_id` = f.`origin_airport_id`
 JOIN `Airports` ad ON ad.`airport_id` = f.`destination_airport_id`
 JOIN `Aircraft` a  ON a.`aircraft_id` = f.`aircraft_id`
 JOIN `Airlines` al ON al.`airline_id` = a.`airline_id`
 LEFT JOIN `Gates` g ON g.`gate_id` = f.`gate_id`;

-- ---------------------------------------------------------------------
 -- 3. REGUŁY BIZNESOWE: procedury + triggery
 --    Procedury trzymają logikę w jednym miejscu, triggery INSERT i UPDATE
 --    wywołują tę samą procedurę.
 -- ---------------------------------------------------------------------

DELIMITER //

-- Lot musi zaczynać się albo kończyć na lotnisku własnym (is_home = 1)
 CREATE OR REPLACE PROCEDURE `chk_flight_home`(IN p_origin INT, IN p_dest INT)
 BEGIN
   IF (SELECT COUNT(*) FROM `Airports`
       WHERE `airport_id` IN (p_origin, p_dest) AND `is_home` = 1) = 0 THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Lot musi odlatywać z lotniska własnego (is_home=1) albo do niego przylatywać';
   END IF;
 END//

-- Załoga latająca (kapitan, pierwszy oficer, personel pokładowy) musi być z linii, do której należy samolot;
 -- jeden pracownik nie może mieć dwóch nakładających się dyżurów
 CREATE OR REPLACE PROCEDURE `chk_crew`(
   IN p_id INT, IN p_flight INT, IN p_employee INT, IN p_role VARCHAR(20),
   IN p_start DATETIME, IN p_end DATETIME, IN p_status VARCHAR(20))
 BEGIN
   DECLARE v_aircraft_airline INT;
   DECLARE v_employee_airline INT;

  IF p_role IN ('captain','first_officer','cabin_crew') THEN
     SELECT a.`airline_id` INTO v_aircraft_airline
     FROM `Flights` f JOIN `Aircraft` a ON a.`aircraft_id` = f.`aircraft_id`
     WHERE f.`flight_id` = p_flight;

    SELECT `airline_id` INTO v_employee_airline
     FROM `Employees` WHERE `employee_id` = p_employee;

    IF v_employee_airline IS NULL OR v_employee_airline <> v_aircraft_airline THEN
       SIGNAL SQLSTATE '45000'
         SET MESSAGE_TEXT = 'Załoga lotnicza musi pochodzić z linii lotniczej właściciela samolotu';
     END IF;
   END IF;

  IF p_status <> 'cancelled' AND EXISTS (
     SELECT 1 FROM `Flight_Crew`
     WHERE `employee_id` = p_employee
       AND `flight_crew_id` <> IFNULL(p_id, 0)
       AND `status` <> 'cancelled'
       AND `duty_start` < p_end AND `duty_end` > p_start) THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Pracownik ma już nakładający się dyżur';
   END IF;
 END//

-- Wejście do salonika VIP wymaga ważnego dostępu w dniu wejścia
 CREATE OR REPLACE PROCEDURE `chk_lounge_visit`(
  IN p_visit INT, IN p_access INT, IN p_lounge INT, IN p_entry DATETIME, IN p_exit DATETIME)
BEGIN
  DECLARE v_capacity INT;
  DECLARE v_occupied INT;
  IF NOT EXISTS (
    SELECT 1 FROM `Lounge_Access` WHERE `access_id` = p_access
      AND DATE(p_entry) BETWEEN `valid_from` AND `valid_until`) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dostęp do salonika VIP nie jest ważny w dniu wejścia';
  END IF;
  IF p_exit IS NULL THEN
    SELECT `capacity` INTO v_capacity FROM `Lounges` WHERE `lounge_id` = p_lounge;
    IF v_capacity IS NOT NULL THEN
      SELECT COUNT(*) INTO v_occupied FROM `Lounge_Visits`
      WHERE `lounge_id` = p_lounge AND `exit_time` IS NULL
        AND (`visit_id` <> p_visit OR p_visit IS NULL);
      IF v_occupied >= v_capacity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salonik VIP jest pełny';
      END IF;
    END IF;
  END IF;
END//

-- Okresy ważności dostępu do salonika VIP tego samego pasażera nie mogą się nakładać
 CREATE OR REPLACE PROCEDURE `chk_lounge_access_overlap`(
   IN p_id INT, IN p_passenger INT, IN p_from DATE, IN p_until DATE)
 BEGIN
   IF EXISTS (
     SELECT 1 FROM `Lounge_Access`
     WHERE `passenger_id` = p_passenger
       AND `access_id` <> IFNULL(p_id, 0)
       AND `valid_from` <= p_until AND `valid_until` >= p_from) THEN
     SIGNAL SQLSTATE '45000'
       SET MESSAGE_TEXT = 'Okres ważności dostępu do salonika VIP nakłada się na inny dostęp tego pasażera';
   END IF;
 END//

-- Liczba aktywnych biletów na lot nie może przekroczyć liczby miejsc w samolocie
 CREATE OR REPLACE PROCEDURE `chk_ticket_capacity`(IN p_ticket INT, IN p_flight INT, IN p_status VARCHAR(20))
BEGIN
  DECLARE v_seats INT;
  DECLARE v_sold INT;
  IF p_status <> 'cancelled' THEN
    SELECT a.`seats` INTO v_seats
    FROM `Flights` f JOIN `Aircraft` a ON a.`aircraft_id` = f.`aircraft_id`
    WHERE f.`flight_id` = p_flight;
    SELECT COUNT(*) INTO v_sold
    FROM `Tickets` WHERE `flight_id` = p_flight AND `status` <> 'cancelled'
    AND (`ticket_id` <> p_ticket OR p_ticket IS NULL);
    IF v_sold >= v_seats THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Brak wolnych miejsc: samolot jest pełny';
    END IF;
  END IF;
END//

-- --- triggery ---------------------------------------------------------

CREATE OR REPLACE TRIGGER `trg_flights_bi` BEFORE INSERT ON `Flights` FOR EACH ROW
 BEGIN
   CALL chk_flight_home(NEW.`origin_airport_id`, NEW.`destination_airport_id`);
 END//
 CREATE OR REPLACE TRIGGER `trg_flights_bu` BEFORE UPDATE ON `Flights` FOR EACH ROW
 BEGIN
   CALL chk_flight_home(NEW.`origin_airport_id`, NEW.`destination_airport_id`);
 END//

CREATE OR REPLACE TRIGGER `trg_flight_crew_bi` BEFORE INSERT ON `Flight_Crew` FOR EACH ROW
 BEGIN
   CALL chk_crew(NEW.`flight_crew_id`, NEW.`flight_id`, NEW.`employee_id`, NEW.`role`,
                 NEW.`duty_start`, NEW.`duty_end`, NEW.`status`);
 END//
 CREATE OR REPLACE TRIGGER `trg_flight_crew_bu` BEFORE UPDATE ON `Flight_Crew` FOR EACH ROW
 BEGIN
   CALL chk_crew(OLD.`flight_crew_id`, NEW.`flight_id`, NEW.`employee_id`, NEW.`role`,
                 NEW.`duty_start`, NEW.`duty_end`, NEW.`status`);
 END//

CREATE OR REPLACE TRIGGER `trg_lounge_visits_bi` BEFORE INSERT ON `Lounge_Visits` FOR EACH ROW
 BEGIN
   CALL chk_lounge_visit(NULL, NEW.`access_id`, NEW.`lounge_id`, NEW.`entry_time`, NEW.`exit_time`);
 END//
 CREATE OR REPLACE TRIGGER `trg_lounge_visits_bu` BEFORE UPDATE ON `Lounge_Visits` FOR EACH ROW
 BEGIN
   CALL chk_lounge_visit(OLD.`visit_id`, NEW.`access_id`, NEW.`lounge_id`, NEW.`entry_time`, NEW.`exit_time`);
 END//

CREATE OR REPLACE TRIGGER `trg_lounge_access_bi` BEFORE INSERT ON `Lounge_Access` FOR EACH ROW
 BEGIN
   CALL chk_lounge_access_overlap(NEW.`access_id`, NEW.`passenger_id`, NEW.`valid_from`, NEW.`valid_until`);
 END//
 CREATE OR REPLACE TRIGGER `trg_lounge_access_bu` BEFORE UPDATE ON `Lounge_Access` FOR EACH ROW
 BEGIN
   CALL chk_lounge_access_overlap(OLD.`access_id`, NEW.`passenger_id`, NEW.`valid_from`, NEW.`valid_until`);
 END//

CREATE OR REPLACE TRIGGER `trg_tickets_bi` BEFORE INSERT ON `Tickets` FOR EACH ROW
 BEGIN
   CALL chk_ticket_capacity(NULL, NEW.`flight_id`, NEW.`status`);
 END//

CREATE OR REPLACE TRIGGER `trg_tickets_bu` BEFORE UPDATE ON `Tickets` FOR EACH ROW
BEGIN
  CALL chk_ticket_capacity(OLD.`ticket_id`, NEW.`flight_id`, NEW.`status`);
END//

DELIMITER ;
