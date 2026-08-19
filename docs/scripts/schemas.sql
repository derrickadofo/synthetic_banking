-------------------------------------------------------------------------------
--Datenbank : synthetic_bank
-------------------------------------------------------------------------------

DROP DATABASE IF EXISTS synthetic_bank;
CREATE DATABASE synthetic_bank;

-------------------------------------------------------------------------------
--tabellen erstellen 
-------------------------------------------------------------------------------
DROP TABLE IF EXISTS customers;
CREATE TABLE customers(
 customer_id VARCHAR(20) PRIMARY KEY,
 first_name VARCHAR(50),
 last_name VARCHAR(50),
 email VARCHAR(100),
 city VARCHAR(50),
 credit_score INT,
 created_at DATETIME
);

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts(
 account_id VARCHAR(20) PRIMARY KEY,
 customer_id VARCHAR(20),
 account_type VARCHAR(20),
 balance_usd DECIMAL(12,2),
 open_date DATETIME,
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);


DROP TABLE IF EXISTS cards;
CREATE TABLE cards(
 card_id VARCHAR(20) PRIMARY KEY,
 account_id VARCHAR(20),
 card_type VARCHAR(20),
 expiration_date DATETIME,
 FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);


DROP TABLE IF EXISTS merchants;
CREATE TABLE merchants(
 merchant_id VARCHAR(20) PRIMARY KEY,
 merchant_name VARCHAR(100),
 city VARCHAR(50)
);


DROP TABLE IF EXISTS branches;
CREATE TABLE branches(
 branch_id VARCHAR(20) PRIMARY KEY,
 branch_name VARCHAR(100),
 city VARCHAR(50),
 country VARCHAR(50),
 manager_name VARCHAR(100)   
);


DROP TABLE IF EXISTS loans;
CREATE TABLE loans(
 loan_id VARCHAR(20) PRIMARY KEY,
 customer_id VARCHAR(20),
 loan_amount DECIMAL(12,2),
 interest_rate DECIMAL(5,2),
 start_date DATETIME,
 FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);



DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions(
 transaction_id VARCHAR(25) PRIMARY KEY,
 account_id VARCHAR(20),
 merchant_id VARCHAR(20),
 amount_usd DECIMAL(12,2),
 transaction_date DATE,
 FOREIGN KEY (account_id) REFERENCES accounts(account_id),
 FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

-------------------------------------------------------------------------------
--Daten vom csv datein importieren.
-- Die Daten inhalt für die Tabelle transactions wurde direct hinzugefügt mit insert values.
-------------------------------------------------------------------------------
COPY customers(customer_id ,
 first_name ,
 last_name ,
 email ,
 city ,
 credit_score ,
 created_at)
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);

COPY accounts(account_id,
 customer_id,
 account_type ,
 balance_usd ,
 open_date )
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);


COPY cards(card_id,
 account_id,
 card_type,
 expiration_date)
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);

COPY merchants( merchant_id,
 merchant_name,
 city)
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);

COPY branches( branch_id ,
 branch_name ,
 manager_name)
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);

COPY loans(
 loan_id ,
 customer_id ,
 loan_amount ,
 interest_rate,
 start_date)
FROM 'PATH'
WITH (
    FORMAT CSV,
	DELIMITER ',',
    HEADER TRUE
);

---------------------------------------------------------------------------------------------------------
--transactions wurde im PSQL TOOL importiert als direckt insert values vom transactions_insert.sql file

--Daten vom Jede Tabelle abrufen 
------------------------------------------------------------------------------------------------------------
SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM branches;
SELECT * FROM merchants;
SELECT * FROM cards;
SELECT * FROM loans;
SELECT * FROM transactions; -- Alle daten erfolgreich importiert.



-------------------------------------------------------------------------------
-- Daten qualität überprüfen. NULL, duplikats, etc. vom benötigte Spalte.
-- Null werte mit UNION ALL überprüfen. 
-------------------------------------------------------------------------------

SELECT 'customers' AS tabelle_name, 'customer_id' AS spalte_name, COUNT(*) AS anzahl_null_werte 
FROM customers WHERE customer_id IS NULL
UNION ALL
SELECT 'customers', 'email', COUNT(*) FROM customers WHERE email IS NULL OR email = '' 
UNION ALL
SELECT 'customers', 'city', COUNT(*) FROM customers WHERE city IS NULL OR city = '' 
UNION ALL
SELECT 'customers', 'credit_score', COUNT(*) FROM customers WHERE credit_score IS NULL
UNION ALL
SELECT 'accounts', 'account_id', COUNT(*) FROM accounts WHERE account_id IS NULL 
UNION ALL
SELECT 'accounts', 'customer_id', COUNT(*) FROM accounts WHERE customer_id IS NULL 
UNION ALL
SELECT 'branches', 'branch_id', COUNT(*) FROM branches WHERE branch_id IS NULL 
UNION ALL
SELECT 'merchants', 'merchant_id', COUNT(*) FROM merchants WHERE merchant_id IS NULL 
UNION ALL
SELECT 'merchants', 'city', COUNT(*) FROM merchants WHERE city IS NULL OR city = '' 
UNION ALL
SELECT 'cards', 'card_id', COUNT(*) FROM cards WHERE card_id IS NULL 
UNION ALL
SELECT 'cards', 'account_id', COUNT(*) FROM cards WHERE account_id IS NULL 
UNION ALL
SELECT 'loans', 'loan_id', COUNT(*) FROM loans WHERE loan_id IS NULL 
UNION ALL
SELECT 'loans', 'customer_id', COUNT(*) FROM loans WHERE customer_id IS NULL 
UNION ALL
SELECT 'transactions', 'transaction_id', COUNT(*) FROM transactions WHERE transaction_id IS NULL 
UNION ALL
SELECT 'transactions', 'account_id', COUNT(*) FROM transactions WHERE account_id IS NULL 
UNION ALL
SELECT 'transactions', 'merchant_id', COUNT(*) FROM transactions WHERE merchant_id IS NULL;

-- null count liefert keine ergibnisse aus. keine null werte im ausgewählten spalten 


----------------------------------------------------------------------------------------------------------------------------
--CONSTRAINTS (Einschränkungen)
/*constraints wurde beim aufbau die tabellen erstellt. Die fehlen aber noch die sicherheits Einschränkungen beim DELETE:
dazu wurde die tabellen einschränkungen aktualisiert */
-------------------------------------------------------------------------------
-- CONSTRAINTS aktualisieren
ALTER TABLE accounts
DROP CONSTRAINT accounts_customer_id_fkey;

ALTER TABLE accounts 
ADD CONSTRAINT fk_accounts_customers
FOREIGN KEY (customer_id) 
REFERENCES customers (customer_id) 
ON DELETE CASCADE;


ALTER TABLE cards
DROP CONSTRAINT cards_account_id_fkey;

ALTER TABLE cards 
ADD CONSTRAINT fk_cards_accounts
FOREIGN KEY (account_id) 
REFERENCES accounts (account_id)  
ON DELETE CASCADE;


ALTER TABLE loans 
DROP CONSTRAINT loans_customer_id_fkey;

ALTER TABLE loans 
ADD CONSTRAINT fk_loans_customers
FOREIGN KEY (customer_id) 
REFERENCES customers (customer_id) 
ON DELETE CASCADE;


ALTER TABLE transactions 
DROP CONSTRAINT transactions_account_id_fkey,
DROP CONSTRAINT transactions_merchant_id_fkey;


ALTER TABLE transactions 
ADD CONSTRAINT fk_transactions_accounts
FOREIGN KEY (account_id) 
REFERENCES accounts (account_id) 
ON DELETE CASCADE;

ALTER TABLE transactions 
ADD CONSTRAINT fk_transactions_merchants
FOREIGN KEY (merchant_id) 
REFERENCES merchants (merchant_id) 
ON DELETE RESTRICT;


-- Es ist sinnvoller, ein NOT NULL constraint auf die wichtigste spalten hinzugügen zum sicherheit.
ALTER TABLE customers 
    ALTER COLUMN email SET NOT NULL,
    ALTER COLUMN city SET NOT NULL,
    ALTER COLUMN credit_score SET NOT NULL;

ALTER TABLE merchants 
    ALTER COLUMN city SET NOT NULL;

-- chk constraints für email und city
ALTER TABLE customers
    ADD CONSTRAINT chk_email_not_empty CHECK (email <> ''),
    ADD CONSTRAINT chk_city_not_empty CHECK (city <> '');



-- Zustand von alle Einschränkungen in jede Tabelle

SELECT constraint_name 
FROM information_schema.table_constraints 
WHERE table_name = 'accounts'
    OR table_name = 'cards'
    OR table_name = 'loans'
    OR table_name = 'transactions'
    OR table_name = 'customers'
    OR table_name = 'merchants'
    OR table_name = 'branches';




-------------------------------------------------------------------------------
-- Einschränkungen Testen
-- TEST 1: Überprüfen Data Qualität (NOT NULL constraints)
-------------------------------------------------------------------------------
-- Erwartete Ergebnis: Fehlermeldung, email, credit_score und city durfen nicht null sein.
INSERT INTO customers (customer_id, first_name, last_name, created_at)
VALUES ('TEST_CUST_1', 'John', 'Doe', '12-01-2025'); -- ERROR:  null value in column "email" of relation "customers" violates not-null constraint
                                                       --Failing row contains (TEST_CUST_1, John, Doe, null, null, null, 2025-01-12). 



-------------------------------------------------------------------------------
-- TEST 2: (FOREIGN KEY restriction)
-------------------------------------------------------------------------------
-- Erwartete Ergebnis: Fehlermeldung, es gibt kein customer_id mit angegebene wert.
INSERT INTO accounts (account_id, customer_id, account_type, balance_usd, open_date)
VALUES ('TEST_ACC_1', 'Try_and_error', 'CHECKING', 500.00, NOW()); -- ERROR:  insert or update on table "accounts" violates foreign key constraint "fk_accounts_customers"
                                                                   -- Key (customer_id)=(Try_and_error) is not present in table "customers". 



-------------------------------------------------------------------------------
-- TEST 3: Einschränkung RESTRICT testen (transactions -> merchants)
-------------------------------------------------------------------------------
-- Eine Zeile in customers, accounts, merchants und transactions hinzufügen
INSERT INTO customers (customer_id, first_name, last_name, email, city, credit_score, created_at)
VALUES ('MOCK_CUST', 'derrick', 'adofo', 'derrick@test.com', 'koblenz', 750, NOW());

INSERT INTO accounts (account_id, customer_id, account_type, balance_usd, open_date)
VALUES ('MOCK_ACC', 'MOCK_CUST', 'SAVINGS', 1000.00, NOW());

INSERT INTO merchants (merchant_id, merchant_name, city)
VALUES ('MOCK_MERCH', 'Test Shop', 'koblenz');

INSERT INTO transactions (transaction_id, account_id, merchant_id, amount_usd, transaction_date)
VALUES ('MOCK_TX', 'MOCK_ACC', 'MOCK_MERCH', 50.00, NOW());

-- Test beim delete von merchant beim existeirenden transaction
-- Erwartete Ergebnis: Fehlermeldung, einschränkung ON DELETE RESTRICT auf beziehung zwichen merchant und transaktion.
DELETE FROM merchants WHERE merchant_id = 'MOCK_MERCH'; --ERROR:  update or delete on table "merchants" violates RESTRICT setting of foreign key constraint 
                                                        --"fk_transactions_merchants" on table "transactions"
                                                        --Key (merchant_id)=(MOCK_MERCH) is referenced from table "transactions". 



-------------------------------------------------------------------------------
-- TEST 4: CASCADE Einschränkung (customers -> accounts -> cards & loans)
-------------------------------------------------------------------------------
-- Step A: Add a card and a loan linked to our mock customer/account
-- Eine zeile in Tebellen cards und loans hinzufügen und verbundet mit customer und acoounts 

INSERT INTO cards (card_id, account_id, card_type, expiration_date)
VALUES ('MOCK_CARD', 'MOCK_ACC', 'DEBIT', '2030-01-01');

INSERT INTO loans (loan_id, customer_id, loan_amount, interest_rate, start_date)
VALUES ('MOCK_LOAN', 'MOCK_CUST', 5000.00, 4.5, NOW());

-- versuch kunden information zu entfernen
DELETE FROM customers WHERE customer_id = 'MOCK_CUST';

-- Überprüft ob alles durch CASCADE gleichzeitig gelöscht wurde
--Erwartete Ergebnis, mit CASCADE constraint, wurde alle informationen verbundet mit customer_id 'MOCK_CUST' gelöscht.
SELECT 
    (SELECT COUNT(*) FROM customers WHERE customer_id = 'MOCK_CUST') AS kunde,
    (SELECT COUNT(*) FROM accounts WHERE account_id = 'MOCK_ACC') AS konto,
    (SELECT COUNT(*) FROM cards WHERE card_id = 'MOCK_CARD') AS karte,
    (SELECT COUNT(*) FROM loans WHERE loan_id = 'MOCK_LOAN') AS darlehen,
    (SELECT COUNT(*) FROM transactions WHERE transaction_id = 'MOCK_TX') AS transaktionen;


-------------------------------------------------------------------------------
-- Aufraümen , alle mock zeilen entfernen.
-------------------------------------------------------------------------------
DELETE FROM transactions WHERE transaction_id = 'MOCK_TX'; -- erfolgreich

-- jetzt wieder versuchen vom merchant tabelle die zeile zu entfernen
DELETE FROM merchants WHERE merchant_id = 'MOCK_MERCH'; -- erfolgreich


select * FROM transactions where transaction_id = 'MOCK_TX';
select * FROM accounts where account_id = 'MOCK_ACC';
SELECT * FROM merchants WHERE merchant_id = 'MOCK_MERCH';
SELECT * FROM cards WHERE card_id = 'MOCK_CARD';
SELECT * FROM loans WHERE loan_id = 'MOCK_LOAN';


----------------------------------------------------------------------------------------
--Indexing und Performance 
----------------------------------------------------------------------------------------
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_accounts_type ON accounts(account_type);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_branches_id ON branches(branch_id);






