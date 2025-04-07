---Insert test data into car_make, car, customer
INSERT INTO car_make VALUES ('Toyota', 'Corolla', 2);
INSERT INTO car_make VALUES ('Honda', 'Civic', 3);
INSERT INTO car_make VALUES ('BMW', 'X5', 5);
INSERT INTO car VALUES ('SGX1111X', 'Red', 'Toyota', 'Corolla');
INSERT INTO car VALUES ('SGX2222Y', 'Blue', 'Honda', 'Civic');
INSERT INTO car VALUES ('SGX3333Z', 'Black', 'BMW', 'X5');
INSERT INTO customer VALUES ('S1111111A', 'Alice', '1990-01-01', TRUE);  
INSERT INTO customer VALUES ('S2222222B', 'Bob', '2000-01-01', TRUE);  
INSERT INTO customer VALUES ('S3333333C', 'Charlie', '2005-01-01', FALSE);
INSERT INTO customer VALUES ('S4444444D', 'Dora', '2002-01-01', TRUE);
INSERT INTO customer VALUES ('S5555555E', 'Eve', '1995-05-05', TRUE);
INSERT INTO customer VALUES ('S6666666F', 'Frank', '1985-06-06', FALSE);
---Test 1: rent_solo with valid data - Alice rents car successfully
SELECT '--- Test 1: Valid solo rental ---' AS test_case;
CALL rent_solo('SGX1111X', 'S1111111A', '2024-01-01', '2024-01-05');
---Test 2: rent_solo with overlapping period - should fail
SELECT '--- Test 2: Invalid solo rental - overlapping period ---' AS test_case;
CALL rent_solo('SGX1111X', 'S2222222B', '2024-01-03', '2024-01-07');
---Test 3: rent_solo with unlicensed customer - should fail
SELECT '--- Test 3: Invalid solo rental - no license ---' AS test_case;
CALL rent_solo('SGX2222Y', 'S3333333C', '2024-01-10', '2024-01-15');
---Test 4: rent_group with valid data - multiple passengers with licenses
SELECT '--- Test 4: Valid group rental ---' AS test_case;
CALL rent_group('SGX3333Z', 'S5555555E', '2024-02-01', '2024-02-05',
              'S5555555E', 'S2222222B', 'S4444444D', NULL);
---Test 5: rent_group with NULL passengers - should succeed
SELECT '--- Test 5: Group rental with NULL passengers ---' AS test_case;
CALL rent_group('SGX2222Y', 'S5555555E', '2024-04-01', '2024-04-05',
              'S5555555E', NULL, NULL, NULL);
---Test 6: rent_group with all passengers unlicensed - should fail
SELECT '--- Test 6: Invalid group rental - no licensed passenger ---' AS test_case;
CALL rent_group('SGX3333Z', 'S5555555E', '2024-03-01', '2024-03-05',
               'S3333333C', 'S6666666F', 'S3333333C', 'S6666666F');
---Test 7: rent_group with duplicate passengers - should succeed
SELECT '--- Test 7: Valid group rental with duplicate passengers ---' AS test_case;
CALL rent_group('SGX3333Z', 'S5555555E', '2024-03-10', '2024-03-15',
               'S5555555E', 'S5555555E', 'S2222222B', NULL);