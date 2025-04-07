---Inset data into car_make, car, customer
INSERT INTO car_make VALUES ('Toyota', 'Corolla', 2);
INSERT INTO car_make VALUES ('Honda', 'Civic', 3);
INSERT INTO car VALUES ('SGX1111X', 'Red', 'Toyota', 'Corolla');
INSERT INTO car VALUES ('SGX2222Y', 'Blue', 'Honda', 'Civic');
INSERT INTO customer VALUES ('S1111111A', 'Alice', '1990-01-01', TRUE);  
INSERT INTO customer VALUES ('S2222222B', 'Bob', '2000-01-01', TRUE);  
INSERT INTO customer VALUES ('S3333333C', 'Charlie', '2005-01-01', FALSE); 
INSERT INTO customer VALUES ('S4444444C', 'Dora', '2002-01-01', TRUE); 

---Trigger1: Alice rent toyota from 04-01 to 04-05, bob cannot rent same car for period from 04-01 to 04-05
INSERT INTO rent VALUES ('S1111111A', 'SGX1111X', '2025-04-01', '2025-04-05'); --- insert rent data
INSERT INTO rent VALUES ('S2222222B', 'SGX1111X', '2025-04-03', '2025-04-04'); --- overlap period, shows ERROR:  Overlapping rent period for car SGX1111X
INSERT INTO rent VALUES ('S2222222B', 'SGX1111X', '2025-04-05', '2025-04-08'); --- partially overlap period, shows ERROR:  Overlapping rent period for car SGX1111X

---Trigger2:
-- Bob rent honda from 04-02 to 04-04 and Alice rent toyata from 04-01 to 04-05
INSERT INTO rent VALUES ('S2222222B', 'SGX2222Y', '2025-04-02', '2025-04-04');
--- Dora cannot appear on both toyota and honda at the same time, shows ERROR:  Passenger S4444444C already on another car during overlapping period
INSERT INTO ride VALUES ('SGX1111X', '2025-04-01', '2025-04-05', 'S4444444C');
INSERT INTO ride VALUES ('SGX2222Y', '2025-04-02', '2025-04-04', 'S4444444C');

---Trigger3:
-- Dora already on toyotam and toyota has a capacity of 2
---add alice, capacity = 2 so it is fine
INSERT INTO ride VALUES ('SGX1111X', '2025-04-01', '2025-04-05', 'S1111111A'); 
---add bob, capacity = 3 so it violates and shows ERROR:  Car SGX1111X exceeded capacity: 3 passengers > 2 seats
INSERT INTO ride VALUES ('SGX1111X', '2025-04-01', '2025-04-05', 'S2222222B');

---Trigger4: currently, no one ride honda. 
---I will try insert Charlie who does not have liscence to honda. It shows ERROR:  Ride for car SGX2222Y from 2025-04-02 to 2025-04-04 has no licensed driver
INSERT INTO ride VALUES ('SGX2222Y', '2025-04-02', '2025-04-04', 'S3333333C');





