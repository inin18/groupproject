CREATE OR REPLACE FUNCTION check_rent_overlap()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM rent r
    WHERE r.plate = NEW.plate
      AND r.start_date <= NEW.end_date
      AND r.end_date >= NEW.start_date
      AND (r.plate, r.start_date, r.end_date) IS DISTINCT FROM (NEW.plate, NEW.start_date, NEW.end_date)
  ) THEN
    RAISE EXCEPTION 'Overlapping rent period for car %', NEW.plate;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_rent_overlap
AFTER INSERT OR UPDATE ON rent
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_rent_overlap();

CREATE OR REPLACE FUNCTION check_passenger_overlap()
RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM ride r
    WHERE r.passenger = NEW.passenger
      AND r.start_date <= NEW.end_date
      AND r.end_date >= NEW.start_date
      AND (r.plate, r.start_date, r.end_date, r.passenger) IS DISTINCT FROM (NEW.plate, NEW.start_date, NEW.end_date, NEW.passenger)
  ) THEN
    RAISE EXCEPTION 'Passenger % already on another car during overlapping period', NEW.passenger;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_passenger_overlap
AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_passenger_overlap();

CREATE OR REPLACE FUNCTION check_capacity()
RETURNS TRIGGER AS $$
DECLARE
  passenger_count INT;
  capacity INT;
BEGIN
  SELECT COUNT(*) INTO passenger_count
  FROM ride r
  WHERE r.plate = NEW.plate AND r.start_date = NEW.start_date AND r.end_date = NEW.end_date;

  SELECT cm.capacity INTO capacity
  FROM car c
  JOIN car_make cm ON c.brand = cm.brand AND c.model = cm.model
  WHERE c.plate = NEW.plate;

  IF passenger_count > capacity THEN
    RAISE EXCEPTION 'Car % exceeded capacity: % passengers > % seats', NEW.plate, passenger_count, capacity;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_capacity
AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_capacity();

CREATE OR REPLACE FUNCTION check_driver_presence()
RETURNS TRIGGER AS $$
DECLARE
  licensed_count INT;
BEGIN
  SELECT COUNT(*) INTO licensed_count
  FROM ride r
  JOIN customer c ON r.passenger = c.nric
  WHERE r.plate = NEW.plate AND r.start_date = NEW.start_date AND r.end_date = NEW.end_date
    AND c.license = TRUE;

  IF licensed_count < 1 THEN
    RAISE EXCEPTION 'Ride for car % from % to % has no licensed driver', NEW.plate, NEW.start_date, NEW.end_date;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER trg_check_driver_presence
AFTER INSERT OR UPDATE ON ride
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION check_driver_presence();