CREATE OR REPLACE PROCEDURE rent_solo(
IN car VARCHAR(8), IN customer CHAR(9), 
IN start_date DATE, IN end_date DATE
) AS $$
BEGIN
	INSERT INTO rent VALUES(customer, car, start_date, end_date);
	INSERT INTO ride VALUES(car, start_date, end_date, customer);
	--COMMIT;
EXCEPTION WHEN OTHERS THEN
	RAISE NOTICE 'ERROR OCCURED: %', SQLERRM;
	--ROLLBACK;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE rent_group(
IN car VARCHAR(8), IN customer CHAR(9), 
IN start_date DATE, IN end_date DATE,
IN passenger1 CHAR(9) , IN passenger2 CHAR(9),
IN passenger3 CHAR(9) , IN passenger4 CHAR(9)
) AS $$
DECLARE
	tmp CHAR(9);
	passengers CHAR(9)[];
BEGIN
	INSERT INTO rent VALUES(customer, car, start_date, end_date);
	passengers = ARRAY[passenger1, passenger2, passenger3, passenger4];
	FOREACH tmp IN ARRAY passengers
		LOOP
			IF tmp IS NOT NULL THEN
				INSERT INTO ride VALUES(car, start_date, end_date, tmp);
			END IF;
		END LOOP;
	--COMMIT;
EXCEPTION WHEN OTHERS THEN
	--ROLLBACK;
	RAISE NOTICE 'ERROR OCCURED: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;