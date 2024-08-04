-- Keep a log of any SQL queries you execute as you solve the mystery.
-- All you know is that the theft took place on July 28, 2023 and that it took place on Humphrey Street.


-- Get desctiption of what happened
SELECT description
FROM crime_scene_reports
WHERE 
    year = 2023 AND month = 7 AND day = 28
AND
    street LIKE '%Humphrey Street%';

-- Crime time 10:15 am, mentioned bakery, littering at 16:36.



SELECT name, transcript 
FROM interviews
WHERE year = 2023 AND month = 7 AND day = 28;

-- Ruth|Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
--      Less that 10 minutes, cars that left
-- Eugene|I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
--      ATM on Leggett Street money withdraw
-- Raymond|As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket.
--      Call less that 1 minute,  left the city by plate earliest tomorrow
--  >>>>  Lily|Our neighboring courthouse has a very annoying rooster that crows loudly at 6am every day. My sons Robert and Patrick took the rooster to a city far, far away, so it may never bother us again. My sons have successfully arrived in Paris.



-- Bakery security: all who left bakery stop within 10 minutes after theft
SELECT license_plate
FROM bakery_security_logs
WHERE 
    year = 2023 AND month = 7 AND day = 28 AND hour = 10 AND minute > 10 AND minute < 25
    AND activity = 'exit'
;



--  ATM on Leggett Street money withdraw -> to bank_accounts
SELECT account_number --, amount
FROM atm_transactions
WHERE
    year = 2023 AND month = 7 AND day = 28
    AND atm_location LIKE '%Leggett Street%'
    AND transaction_type = 'withdraw'
;



-- phone calls less that 1 minute during theft time period, call duration < 60 seconds
SELECT caller, receiver, duration
FROM phone_calls
WHERE
    year = 2023 AND month = 7 AND day = 28
    AND duration < 60
;





-- airports and flights for the next date
SELECT destination_airport_id, hour, minute
FROM flights
JOIN airports ON airports.id = flights.destination_airport_id
WHERE 
    year = 2023 AND month = 7 AND day = 29
    AND origin_airport_id IN (
        SELECT id 
        FROM airports
        WHERE city = 'Fiftyville'
    )
ORDER BY hour
ASC
;

--
SELECT *
FROM airports
WHERE id IN (
    SELECT destination_airport_id
    FROM flights
    JOIN airports ON airports.id = flights.destination_airport_id
    WHERE 
        year = 2023 AND month = 7 AND day = 29
        AND origin_airport_id IN (
            SELECT id 
            FROM airports
            WHERE city = 'Fiftyville'
        )
    ORDER BY hour
    ASC
);

-- Same as up, but shows fligth time  DESTINATION AIRPORT AND FLIGHT TIME
SELECT airports.id, flights.hour, flights.minute
FROM airports
JOIN flights ON airports.id = flights.destination_airport_id
WHERE 
    flights.year = 2023 AND flights.month = 7 AND flights.day = 29
    AND origin_airport_id IN (
        SELECT id 
        FROM airports
        WHERE city = 'Fiftyville'
    )
ORDER BY flights.hour
ASC
;
-- Earliest flights from Fiftyville on the next day after foberry conducted
--- 4 LGA New York 29/07/2024 8:20
--- 1 ORD Chicago 29/07/2024 9:30
--- 11 SFO San Francisco 29/07/2024 12:15



SELECT flights.id
FROM flights
JOIN airports ON airports.id = flights.destination_airport_id
WHERE 
    year = 2023 AND month = 7 AND day = 29
    AND origin_airport_id IN (
        SELECT id 
        FROM airports
        WHERE city = 'Fiftyville'
    )
ORDER BY hour
ASC
LIMIT 3
;


------------------------------------------------------------------------------------

SELECT * 
FROM people

JOIN bank_accounts ON people.id = bank_accounts.person_id

WHERE
    -- Licence plate of a car that left bakery at approximate 10 minutest from the robbery
    people.license_plate IN (
        SELECT license_plate
        FROM bakery_security_logs
        WHERE 
            bakery_security_logs.year = 2023 AND bakery_security_logs.month = 7 AND bakery_security_logs.day = 28 
            AND bakery_security_logs.hour = 10 AND bakery_security_logs.minute > 10 AND bakery_security_logs.minute < 25
            AND activity = 'exit'
    )

    -- Witdraw transaction, ATM on Leggett Street at day of robbery
    AND bank_accounts.account_number IN (
        SELECT account_number
        FROM atm_transactions
        WHERE
            atm_transactions.year = 2023 AND atm_transactions.month = 7 AND atm_transactions.day = 28 
            AND atm_location LIKE '%Leggett Street%'
            AND transaction_type = 'withdraw'
    )

    -- Person who call to someone for less that 1 minute at time of the robbery (maybe need to check reciever too)
    AND people.phone_number IN (
        SELECT caller
        FROM phone_calls
        WHERE
            year = 2023 AND month = 7 AND day = 28
            AND duration < 60
    )
    -- AND people.phone_number IN (
    --     SELECT receiver
    --     FROM phone_calls
    --     WHERE
    --         year = 2023 AND month = 7 AND day = 28
    --         AND duration < 60
    -- )
    
    -- on the earliest flight next day out of Fiftyville
    AND people.passport_number IN (
        SELECT passport_number 
        FROM passengers
        WHERE passengers.flight_id IN (
            SELECT flights.id
            FROM flights
            JOIN airports ON airports.id = flights.destination_airport_id
            WHERE 
                year = 2023 AND month = 7 AND day = 29
                AND origin_airport_id IN (
                    SELECT id 
                    FROM airports
                    WHERE city = 'Fiftyville'
                )
            ORDER BY hour
            ASC
            LIMIT 1
        )
    )
;

-- only person - Bruce


--- Thief Person by joins
SELECT p.name, pas.flight_id
FROM people p

--- Witdraw transaction, ATM on Leggett Street at day of robbery
INNER JOIN bank_accounts ba ON p.id = ba.person_id
INNER JOIN atm_transactions atm ON ba.account_number = atm.account_number
    AND (
        atm.year = 2023 AND atm.month = 7 AND atm.day = 28 
        AND atm.atm_location LIKE '%Leggett Street%'
        AND atm.transaction_type = 'withdraw'
    )

--- Licence plate of a car that left bakery at approximate 10 minutest from the robbery
INNER JOIN bakery_security_logs bsl ON p.license_plate = bsl.license_plate 
    AND (
        bsl.year = 2023 AND bsl.month = 7 AND bsl.day = 28 AND bsl.hour = 10 
        AND bsl.minute > 10 AND bsl.minute < 25 
        AND bsl.activity = 'exit'
    )

-- Person who call to someone for less that 1 minute at time of the robbery
INNER JOIN phone_calls pc ON p.phone_number = pc.caller 
    AND (
        pc.year = 2023 AND pc.month = 7 AND pc.day = 28 AND pc.duration < 60
    )

-- person on the earliest flight next day out of Fiftyville
INNER JOIN passengers pas ON p.passport_number = pas.passport_number 


-- INNER JOIN flights fl on pas.flight_id = fl.id 
--     AND(
--         fl.year = 2023 AND fl.month = 7 AND fl.day = 29 
--         AND origin_airport_id IN (
--             SELECT id 
--             FROM airports
--             WHERE city = 'Fiftyville'
--         )
--     )


    AND (
        pas.flight_id IN (
            SELECT flights.id
            FROM flights
            WHERE 
                flights.year = 2023 AND flights.month = 7 AND flights.day = 29 
                AND origin_airport_id IN (
                    SELECT airports.id 
                    FROM airports
                    WHERE airports.city = 'Fiftyville'
                )
            ORDER BY flights.hour
            ASC
            LIMIT 3  -- Earliest flights
        )
    )
   
;






---- Destination Airport
SELECT airports.abbreviation, airports.full_name, airports.city
FROM airports
WHERE airports.id IN (

    SELECT flights.destination_airport_id
    FROM flights
    WHERE flights.id IN (

        SELECT pas.flight_id
        FROM people p

        --- Witdraw transaction, ATM on Leggett Street at day of robbery
        INNER JOIN bank_accounts ba ON p.id = ba.person_id
        INNER JOIN atm_transactions atm ON ba.account_number = atm.account_number
            AND (
                atm.year = 2023 AND atm.month = 7 AND atm.day = 28 
                AND atm.atm_location LIKE '%Leggett Street%'
                AND atm.transaction_type = 'withdraw'
            )

        --- Licence plate of a car that left bakery at approximate 10 minutest from the robbery
        INNER JOIN bakery_security_logs bsl ON p.license_plate = bsl.license_plate 
            AND (
                bsl.year = 2023 AND bsl.month = 7 AND bsl.day = 28 AND bsl.hour = 10 
                AND bsl.minute > 10 AND bsl.minute < 25 
                AND bsl.activity = 'exit'
            )

        -- Person who call to someone for less that 1 minute at time of the robbery
        INNER JOIN phone_calls pc ON p.phone_number = pc.caller 
            AND (
                pc.year = 2023 AND pc.month = 7 AND pc.day = 28 AND pc.duration < 60
            )

        -- person on the earliest flight next day out of Fiftyville
        INNER JOIN passengers pas ON p.passport_number = pas.passport_number 
            AND (
                pas.flight_id IN (
                    SELECT flights.id
                    FROM flights
                    WHERE 
                        flights.year = 2023 AND flights.month = 7 AND flights.day = 29 
                        AND origin_airport_id IN (
                            SELECT airports.id 
                            FROM airports
                            WHERE airports.city = 'Fiftyville'
                        )
                    ORDER BY flights.hour
                    ASC
                    LIMIT 3  -- Earliest flights
                )
            )
        
    )
)
;
-- Escape location New York


-- ACCOMPLICE

SELECT people.name
FROM people
WHERE people.phone_number IN (

    -- Same query as for thief but returning only phone calls receiver phone number
    SELECT pc.receiver
    FROM people p

    --- Witdraw transaction, ATM on Leggett Street at day of robbery
    INNER JOIN bank_accounts ba ON p.id = ba.person_id
    INNER JOIN atm_transactions atm ON ba.account_number = atm.account_number
        AND (
            atm.year = 2023 AND atm.month = 7 AND atm.day = 28 
            AND atm.atm_location LIKE '%Leggett Street%'
            AND atm.transaction_type = 'withdraw'
        )

    --- Licence plate of a car that left bakery at approximate 10 minutest from the robbery
    INNER JOIN bakery_security_logs bsl ON p.license_plate = bsl.license_plate 
        AND (
            bsl.year = 2023 AND bsl.month = 7 AND bsl.day = 28 AND bsl.hour = 10 
            AND bsl.minute > 10 AND bsl.minute < 25 
            AND bsl.activity = 'exit'
        )

    -- Person who call to someone for less that 1 minute at time of the robbery
    INNER JOIN phone_calls pc ON p.phone_number = pc.caller 
        AND (
            pc.year = 2023 AND pc.month = 7 AND pc.day = 28 AND pc.duration < 60
        )

    -- person on the earliest flight next day out of Fiftyville
    INNER JOIN passengers pas ON p.passport_number = pas.passport_number 
        AND (
            pas.flight_id IN (
                SELECT flights.id
                FROM flights
                WHERE 
                    flights.year = 2023 AND flights.month = 7 AND flights.day = 29 
                    AND origin_airport_id IN (
                        SELECT airports.id 
                        FROM airports
                        WHERE airports.city = 'Fiftyville'
                    )
                ORDER BY flights.hour
                ASC
                LIMIT 3  -- Earliest flights
            )
        )
)
;

--  Acomplice - Robin