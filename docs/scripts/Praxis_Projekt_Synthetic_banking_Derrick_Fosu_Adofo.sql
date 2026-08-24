-------------------------------------------------------------------------------
-- PRAXISPROJEKT: SQL DATENBANK-MANAGEMENT
-- Thema: Synthetic Banking Dataset (PostgreSQL)
-- Fokus: Datenmodellierung, Relationale Datenbanken, Finance-Analysen & Power BI
-------------------------------------------------------------------------------
/*

INHALT BESCHREIBUNG

1. Tabellen-Dokumentation
customers
Primärschlüssel: customer_id
Fremdschlüssel: Keine
Beschreibung: Speichert die Stammdaten der Kunden (Name, E-Mail, Wohnort, Registrierungsdatum) sowie deren Bonitätsscore (credit_score).

accounts
Primärschlüssel: account_id
Fremdschlüssel: customer_id _----> customers(customer_id)
Beschreibung: Verwaltet die einzelnen Bankkonten der Kunden inklusive Kontotyp (z. B. Giro, Sparen), Eröffnungsdatum und aktuelle Kontostände in USD.

cards
Primärschlüssel: card_id
Fremdschlüssel: account_----> accounts(account_id)
Beschreibung: Verknüpft ausgegebene Zahlungskarten (Debit- oder Kreditkarten) und deren Ablaufdatum mit den jeweiligen Bankkonten.

merchants
Primärschlüssel: merchant_id
Fremdschlüssel: Keine
Beschreibung: Stammverzeichnis aller Akzeptanzstellen und Händler (Name und Standort), bei denen Karten-Transaktionen getätigt werden.

branches
Primärschlüssel: branch_id
Fremdschlüssel: Keine
Beschreibung: Enthält Informationen über die physischen Bankfilialen, deren Standorte (Stadt, Land) und den zuständigen Filialleiter.

loans
Primärschlüssel: loan_id
Fremdschlüssel: customer_id ----> customers(customer_id)
Beschreibung: Erfasst die von Kunden aufgenommenen Kredite und Darlehen inklusive Kreditsumme, Zinssatz und Startdatum.

transactions
Primärschlüssel: transaction_id
Fremdschlüssel: account_id ----> accounts(account_id), merchant_id ----> merchants(merchant_id)
Beschreibung: Protokolliert alle Zahlungs- und Transferaktivitäten auf Kontoebene mit Betrag, Buchungsdatum und beteiligtem Händler.

*/
-------------------------------------------------------------------------------
-- 1. DATENBANK-INITIALISIERUNG
-------------------------------------------------------------------------------
DROP DATABASE IF EXISTS synthetic_bank;
CREATE DATABASE synthetic_bank;

-------------------------------------------------------------------------------
-- 2. SCHEMA- DEFINITION (TABELLE ERSTELLEN)
-------------------------------------------------------------------------------

-- Tabelle: Kundenstammdaten
DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
    customer_id  VARCHAR(20) PRIMARY KEY,
    first_name   VARCHAR(50),
    last_name    VARCHAR(50),
    email        VARCHAR(100),
    city         VARCHAR(50),
    credit_score INT,
    created_at   TIMESTAMP
);

-- Tabelle: Bankkonten
DROP TABLE IF EXISTS accounts CASCADE;
CREATE TABLE accounts (
    account_id   VARCHAR(20) PRIMARY KEY,
    customer_id  VARCHAR(20),
    account_type VARCHAR(20),
    balance_usd  DECIMAL(12,2),
    open_date    TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Tabelle: Bankkarten (Debit / Credit)
DROP TABLE IF EXISTS cards CASCADE;
CREATE TABLE cards (
    card_id         VARCHAR(20) PRIMARY KEY,
    account_id      VARCHAR(20),
    card_type       VARCHAR(20),
    expiration_date TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

-- Tabelle: Händler / Partner
DROP TABLE IF EXISTS merchants CASCADE;
CREATE TABLE merchants (
    merchant_id   VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100),
    city          VARCHAR(50)
);

-- Tabelle: Bankfilialen
DROP TABLE IF EXISTS branches CASCADE;
CREATE TABLE branches (
    branch_id    VARCHAR(20) PRIMARY KEY,
    branch_name  VARCHAR(100),
    city         VARCHAR(50),
    country      VARCHAR(50),
    manager_name VARCHAR(100)
);

-- Tabelle: Kredite & Darlehen
DROP TABLE IF EXISTS loans CASCADE;
CREATE TABLE loans (
    loan_id       VARCHAR(20) PRIMARY KEY,
    customer_id   VARCHAR(20),
    loan_amount   DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    start_date    TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Tabelle: Transaktionen
DROP TABLE IF EXISTS transactions CASCADE;
CREATE TABLE transactions (
    transaction_id   VARCHAR(25) PRIMARY KEY,
    account_id       VARCHAR(20),
    merchant_id      VARCHAR(20),
    amount_usd       DECIMAL(12,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id)
);

-------------------------------------------------------------------------------
-- 3. DATENIMPORT (COPY VOM CSV DATEIEN UND DIREKT INSERTS VON SQL SKRIPTS)
-------------------------------------------------------------------------------

COPY customers(customer_id, first_name, last_name, email, city, credit_score, created_at)
FROM '/path/to/customers.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

COPY accounts(account_id, customer_id, account_type, balance_usd, open_date)
FROM '/path/to/accounts.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

COPY cards(card_id, account_id, card_type, expiration_date)
FROM '/path/to/cards.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

COPY merchants(merchant_id, merchant_name, city)
FROM '/path/to/merchants.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

COPY branches(branch_id, branch_name, city, country, manager_name)
FROM '/path/to/branches.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

COPY loans(loan_id, customer_id, loan_amount, interest_rate, start_date)
FROM '/path/to/loans.csv'
WITH (FORMAT CSV, DELIMITER ',', HEADER TRUE);

-- Hinweis: Die Transaktionen und branches wurden via psql direkt importiert (transactions_insert.sql, branches_insert.sql).

-------------------------------------------------------------------------------
-- 4. DATENQUALITÄTSPRÜFUNG & INTEGRITÄTS-CONSTRAINTS
-------------------------------------------------------------------------------

-- Prüfung auf Vollständigkeit (NULL-Werte Check)
SELECT 'customers' AS table_name, 'customer_id' AS column_name, COUNT(*) AS null_count FROM customers WHERE customer_id IS NULL
UNION ALL
SELECT 'customers', 'email', COUNT(*) FROM customers WHERE email IS NULL OR email = ''
UNION ALL
SELECT 'customers', 'city', COUNT(*) FROM customers WHERE city IS NULL OR city = ''
UNION ALL
SELECT 'accounts', 'account_id', COUNT(*) FROM accounts WHERE account_id IS NULL
UNION ALL
SELECT 'transactions', 'transaction_id', COUNT(*) FROM transactions WHERE transaction_id IS NULL;



-- Referenzielle Integrität & Kaskadierungsregeln aktualisieren
ALTER TABLE accounts DROP CONSTRAINT IF EXISTS accounts_customer_id_fkey;
ALTER TABLE accounts 
    ADD CONSTRAINT fk_accounts_customers 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;

ALTER TABLE cards DROP CONSTRAINT IF EXISTS cards_account_id_fkey;
ALTER TABLE cards 
    ADD CONSTRAINT fk_cards_accounts 
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE;

ALTER TABLE loans DROP CONSTRAINT IF EXISTS loans_customer_id_fkey;
ALTER TABLE loans 
    ADD CONSTRAINT fk_loans_customers 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE;

ALTER TABLE transactions 
    DROP CONSTRAINT IF EXISTS transactions_account_id_fkey,
    DROP CONSTRAINT IF EXISTS transactions_merchant_id_fkey;

ALTER TABLE transactions 
    ADD CONSTRAINT fk_transactions_accounts FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    ADD CONSTRAINT fk_transactions_merchants FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE RESTRICT;

-- Zusätzliche Sicherheits-Constraints
ALTER TABLE customers 
    ALTER COLUMN email SET NOT NULL,
    ALTER COLUMN city SET NOT NULL,
    ALTER COLUMN credit_score SET NOT NULL,
    ADD CONSTRAINT chk_email_not_empty CHECK (email <> ''),
    ADD CONSTRAINT chk_city_not_empty CHECK (city <> '');


-------------------------------------------------------------------------------
-- Einschränkungen Testen
-- TEST 1: Überprüfen Data Qualität (NOT NULL constraints)
-------------------------------------------------------------------------------

INSERT INTO customers (customer_id, first_name, last_name, created_at)
VALUES ('TEST_CUST_1', 'John', 'Doe', '12-01-2025'); 

-- ERROR:  null value in column "email" of relation "customers" violates not-null constraint
--Failing row contains (TEST_CUST_1, John, Doe, null, null, null, 2025-01-12). 



-------------------------------------------------------------------------------
 -- (FOREIGN KEY restriction)
-------------------------------------------------------------------------------

INSERT INTO accounts (account_id, customer_id, account_type, balance_usd, open_date)
VALUES ('TEST_ACC_1', 'Try_and_error', 'CHECKING', 500.00, NOW()); 

-- ERROR:  insert or update on table "accounts" violates foreign key constraint "fk_accounts_customers"
-- Key (customer_id)=(Try_and_error) is not present in table "customers". 



-------------------------------------------------------------------------------
-- Einschränkung RESTRICT testen (transactions -> merchants)
-------------------------------------------------------------------------------

INSERT INTO customers (customer_id, first_name, last_name, email, city, credit_score, created_at)
VALUES ('MOCK_CUST', 'derrick', 'adofo', 'derrick@test.com', 'koblenz', 750, NOW());

INSERT INTO accounts (account_id, customer_id, account_type, balance_usd, open_date)
VALUES ('MOCK_ACC', 'MOCK_CUST', 'SAVINGS', 1000.00, NOW());

INSERT INTO merchants (merchant_id, merchant_name, city)
VALUES ('MOCK_MERCH', 'Test Shop', 'koblenz');

INSERT INTO transactions (transaction_id, account_id, merchant_id, amount_usd, transaction_date)
VALUES ('MOCK_TX', 'MOCK_ACC', 'MOCK_MERCH', 50.00, NOW());

-- Test beim delete von merchant beim existeirenden transaction

DELETE FROM merchants WHERE merchant_id = 'MOCK_MERCH'; 

--ERROR:  update or delete on table "merchants" violates RESTRICT setting of foreign key constraint 
--"fk_transactions_merchants" on table "transactions"
--Key (merchant_id)=(MOCK_MERCH) is referenced from table "transactions". 



-------------------------------------------------------------------------------
-- CASCADE Einschränkung (customers -> accounts -> cards & loans)
-------------------------------------------------------------------------------
-- Eine zeile in Tebellen cards und loans hinzufügen und verbundet mit customer und acoounts 

INSERT INTO cards (card_id, account_id, card_type, expiration_date)
VALUES ('MOCK_CARD', 'MOCK_ACC', 'DEBIT', '2030-01-01');

INSERT INTO loans (loan_id, customer_id, loan_amount, interest_rate, start_date)
VALUES ('MOCK_LOAN', 'MOCK_CUST', 5000.00, 4.5, NOW());

-- versuch kunden information zu entfernen
DELETE FROM customers WHERE customer_id = 'MOCK_CUST';

-- Überprüft ob alles durch CASCADE gleichzeitig gelöscht wurde

SELECT 
    (SELECT COUNT(*) FROM customers WHERE customer_id = 'MOCK_CUST') AS kunde,
    (SELECT COUNT(*) FROM accounts WHERE account_id = 'MOCK_ACC') AS konto,
    (SELECT COUNT(*) FROM cards WHERE card_id = 'MOCK_CARD') AS karte,
    (SELECT COUNT(*) FROM loans WHERE loan_id = 'MOCK_LOAN') AS darlehen,
    (SELECT COUNT(*) FROM transactions WHERE transaction_id = 'MOCK_TX') AS transaktionen;


-------------------------------------------------------------------------------
-- Aufraümen , alle test zeilen entfernen.
-------------------------------------------------------------------------------
DELETE FROM transactions WHERE transaction_id = 'MOCK_TX'; -- erfolgreich

-- jetzt wieder versuchen vom merchant tabelle die zeile zu entfernen
DELETE FROM merchants WHERE merchant_id = 'MOCK_MERCH'; -- erfolgreich


select * FROM transactions where transaction_id ~* 'mock_tx';
select * FROM accounts where account_id = 'MOCK_ACC';
SELECT * FROM merchants WHERE merchant_id = 'MOCK_MERCH';
SELECT * FROM cards WHERE card_id = 'MOCK_CARD';
SELECT * FROM loans WHERE loan_id = 'MOCK_LOAN';



-------------------------------------------------------------------------------
-- 5. PERFORMANCE-OPTIMIERUNG (INDEXING)
-------------------------------------------------------------------------------
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_accounts_type ON accounts(account_type);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_branches_id ON branches(branch_id);

-------------------------------------------------------------------------------
-- 6. BEANTWORTUNG DER KERNFRAGESTELLUNGEN (ANALYSEN)
-------------------------------------------------------------------------------

-- Frage 3 & 4: Gesamtanzahl der Kunden & Kontenverteilung nach Kontotyp
 
SELECT 
    COUNT(DISTINCT c.customer_id) AS kunden_gesamt,
    COUNT(DISTINCT a.customer_id) AS kunden_mit_konto,
    (COUNT(DISTINCT c.customer_id) - COUNT(DISTINCT a.customer_id)) AS kunden_ohne_konto
FROM customers c
LEFT JOIN accounts a ON c.customer_id = a.customer_id;

-- Es gibt insgesamt 50000 kunden im Datenbank.
-- es gibt eine menge im höhe von 38838 die mindestens 1 konto besitzen.
-- eine menge von 11162 kunden besitzen kein konto


SELECT 
    account_type AS kontotyp,
    COUNT(account_id) AS anzahl_konten,
    ROUND(COUNT(account_id) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS prozent_anteil
FROM accounts 
GROUP BY account_type;

-- Es gibt 75,000 Anzahl von Kontos im Datenbank verteilt nach Checkin, Savings und Business

-- KontoTyp     Anzahl  Prozen_anteil
-- "Checking"	25090	33.45%
-- "Business"	24948	33.26%
-- "Savings"	24962	33.28%



-- Frage 5 & 6: Transaktionen gesamt & Top-Kunden nach Transaktionsvolumen
SELECT COUNT(*) AS transaktionen_gesamt FROM transactions; 
--1000000 Transaktionsvolumen


WITH customer_transaktion_stats AS (
    SELECT 
        a.customer_id,
        COUNT(t.transaction_id) AS transaktion_anzahl,
        SUM(t.amount_usd) AS transaktion_gesamtwert
    FROM transactions t
    JOIN accounts a ON a.account_id = t.account_id
    GROUP BY a.customer_id
)
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS kunden_name,
    s.transaktion_anzahl,
    s.transaktion_gesamtwert
FROM customer_transaktion_stats s
JOIN customers c ON s.customer_id = c.customer_id
ORDER BY s.transaktion_anzahl DESC, s.transaktion_gesamtwert DESC
LIMIT 10;

/*
    
"customer_id"       "kunden_name"	  "transaktion_anzahl"	"transaktion_gesamtwert"
"CUSEPV1YW0Y2JL9"	"Joseph Martinez"	    131	                693994.73
"CUSKHXM7VPMNF2X"	"Erika Fischer"	        113	                587089.04
"CUS50SZY6T73XEG"	"Emma Franklin"	        113	                578780.37
"CUSX6HSLBPUJLD4"	"Kimberly Sparks"	    107	                528347.26
"CUSVCOXNCJT7F8S"	"Misty Alexander"	    107             	461989.06
"CUSBDNL0DMP5FEB"	"Christopher Acevedo"	106	                532434.45
"CUSDXB36LXZGGHA"	"Michael Clay"	        105	                517024.72
"CUS13T7YKV7KG3X"	"Janet Moore"	        104	                541817.66
"CUSHMODKKCZTNRF"	"Jennifer Brown"	    104	                524289.11
"CUS8NO7NQOTSVFK"	"James Bryant"	        104                	522204.86
*/




-- Frage 7: Kontostandanalyse & Negative Salden
SELECT  account_id, 
        account_type, 
        balance_usd 
FROM accounts 
ORDER BY balance_usd DESC 
LIMIT 20;


SELECT COUNT(*) AS anzahl_negative_konten 
FROM accounts 
WHERE balance_usd < 0; -- Kein negative konten


-- Frage 8: Zeitliche Muster & Quartalsweises Wachstum (QoQ Growth)

WITH quarterly_transaktion AS (
    SELECT 
        TO_CHAR(transaction_date, 'YYYY-"Q"Q') AS quartile,
        COUNT(transaction_id) AS anzahl_transaktionen,
        SUM(amount_usd) AS transaktion_umsatz
    FROM transactions
    GROUP BY TO_CHAR(transaction_date, 'YYYY-"Q"Q')
)
SELECT 
    quartile,
    transaktion_umsatz AS distinct_quartal_umsatz,
    LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC) AS letze_quartile_umsatz,
    ROUND(
        (
            (transaktion_umsatz - LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC)) * 100.0
        ) / NULLIF(LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC), 0), 
        2
    ) AS qoq_growth_percent
FROM quarterly_transaktion
ORDER BY quartile DESC;



-- Frage 9 & 11: Kartentypen vs. Guthaben & Transaktionsvolumen
SELECT 
    COALESCE(c.card_type, 'Keine Karte') AS karten_typ,
    COUNT(DISTINCT a.account_id) AS anzahl_konten,
    ROUND(AVG(a.balance_usd), 2) AS avg_kontostand_usd,
    ROUND(COALESCE(SUM(t.amount_usd), 0), 2) AS gesamt_transaktionsvolumen_usd,
    ROUND(COALESCE(AVG(t.amount_usd), 0), 2) AS avg_einzeltransaktion_usd
FROM accounts a
LEFT JOIN cards c 
    ON a.account_id = c.account_id
LEFT JOIN transactions t 
    ON a.account_id = t.account_id
GROUP BY c.card_type
ORDER BY gesamt_transaktionsvolumen_usd DESC;


/*
"karten_typ"	"anzahl_konten"	"avg_kontostand_usd"	"gesamt_transaktionsvolumen_usd"	"avg_einzeltransaktion_usd"
"Debit"         	36757	            100593.39	               3353629603.74	                  4994.74
"Credit"	        36254	            99879.61	                3311621291.05	                  5002.45
"Keine Karte"	    19802	            99954.94	               1321005600.57	                  5002.79

*/



--risiko analyse
WITH kunden_guthaben AS (
    SELECT 
        customer_id, 
        SUM(balance_usd) AS guthaben
    FROM accounts
    GROUP BY customer_id
),
kunden_kredite AS (
    SELECT 
        customer_id, 
        SUM(loan_amount) AS darlehen
    FROM loans
    GROUP BY customer_id
),
kunden_guthaben_darhlehen AS (
    SELECT 
        c.customer_id,
        COALESCE(g.guthaben, 0) AS guthaben,
        COALESCE(k.darlehen, 0) AS darlehen
    FROM customers c
    LEFT JOIN kunden_guthaben g ON c.customer_id = g.customer_id
    LEFT JOIN kunden_kredite k ON c.customer_id = k.customer_id
)
SELECT 
    ROUND(SUM(guthaben), 2) AS gesamtes_guthaben_bank,
    ROUND(SUM(CASE WHEN darlehen = 0 THEN guthaben ELSE 0 END), 2) AS guthaben_ohne_kredit,
    ROUND(SUM(CASE WHEN darlehen > 0 THEN guthaben ELSE 0 END), 2) AS guthaben_kreditnehmer,
    ROUND(SUM(darlehen), 2) AS gesamte_darlehen,
    ROUND(SUM(CASE WHEN darlehen > 0 THEN guthaben ELSE 0 END) - SUM(darlehen), 2) AS netto_kreditueberhang
FROM kunden_guthaben_darhlehen;




-------------------------------------------------------------------------------
-- 7. ANALYSE-VIEWS & STORED PROCEDURES (POWER BI INTEGRATION)
-------------------------------------------------------------------------------
-- „Kontostände nach Kunden“
CREATE VIEW Top_10_kunden AS
SELECT  c.customer_id,
        CONCAT(c.first_name,' ',c.last_name) AS kunden_name,
        c.email,
        c.credit_score,
        c.city,
        COUNT(a.account_id) AS anzahl_konten,
        SUM(a.balance_usd) AS gesamt_guthaben_usd
FROM customers c
LEFT JOIN accounts a 
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.credit_score, c.city
ORDER BY anzahl_konten DESC, gesamt_guthaben_usd DESC
LIMIT 10;


-- View: Top-10 Transaktionskunden
CREATE OR REPLACE VIEW top_10_transaktionskunden AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS kunden_name,
    COUNT(t.transaction_id) AS anzahl_transaktionen,
    SUM(t.amount_usd) AS gesamt_volumen_usd
FROM transactions t
JOIN accounts a 
    ON a.account_id = t.account_id
JOIN customers c 
    ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY anzahl_transaktionen DESC
LIMIT 10;

-- View: Inaktive Kunden ohne Konto (Marketing-Potenzial)
CREATE OR REPLACE VIEW inactive_customers_report AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS kunden_name,
    c.email,
    c.city,
    c.credit_score,
    c.created_at,
    'Kein Konto vorhanden' AS status_grund
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
WHERE a.account_id IS NULL;


-- Kunden Dashboard
CREATE OR REPLACE VIEW Kunden_Dashboard AS 
WITH kunden_kredite AS (
    SELECT 
        customer_id,
        COUNT(loan_id) AS anzahl_kredite,
        SUM(loan_amount) AS gesamt_darlehen
    FROM loans
    GROUP BY customer_id
),
kunden_konten AS (
    SELECT 
        customer_id,
        SUM(balance_usd) AS gesamt_guthaben
    FROM accounts
    GROUP BY customer_id
)
SELECT  
    c.first_name || ' ' || c.last_name AS kunden_name,
    c.email,
    c.city,
    c.credit_score,
    c.created_at,
    COALESCE(k.anzahl_kredite, 0) AS anzahl_kredite,
    COALESCE(k.gesamt_darlehen, 0) AS gesamt_darlehen_pro_kunde,
    COALESCE(a.gesamt_guthaben, 0) AS gesamt_guthaben_pro_kunde
FROM customers c
JOIN kunden_kredite k 
    ON c.customer_id = k.customer_id
LEFT JOIN kunden_konten a 
    ON c.customer_id = a.customer_id
ORDER BY gesamt_guthaben_pro_kunde;


-- View für Kartentypen vs. Guthaben & Transaktionsvolumen
CREATE OR REPLACE VIEW kartentype_transaktionen AS
SELECT 
    COALESCE(c.card_type, 'Keine Karte') AS karten_typ,
    COUNT(DISTINCT a.account_id) AS anzahl_konten,
    ROUND(AVG(a.balance_usd), 2) AS avg_kontostand_usd,
    ROUND(COALESCE(SUM(t.amount_usd), 0), 2) AS gesamt_transaktionsvolumen_usd,
    ROUND(COALESCE(AVG(t.amount_usd), 0), 2) AS avg_einzeltransaktion_usd
FROM accounts a
LEFT JOIN cards c 
    ON a.account_id = c.account_id
LEFT JOIN transactions t 
    ON a.account_id = t.account_id
GROUP BY c.card_type
ORDER BY gesamt_transaktionsvolumen_usd DESC;


-- quartile wachstum
CREATE OR REPLACE VIEW quartarl_wachstum AS
WITH quarterly_transaktion AS (
    SELECT 
        TO_CHAR(transaction_date, 'YYYY-"Q"Q') AS quartile,
        COUNT(transaction_id) AS anzahl_transaktionen,
        SUM(amount_usd) AS transaktion_umsatz
    FROM transactions
    GROUP BY TO_CHAR(transaction_date, 'YYYY-"Q"Q')
)
SELECT 
    quartile,
    transaktion_umsatz AS distinct_quartal_umsatz,
    LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC) AS letze_quartile_umsatz,
    ROUND(
        (
            (transaktion_umsatz - LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC)) * 100.0
        ) / NULLIF(LAG(transaktion_umsatz, 1) OVER (ORDER BY quartile ASC), 0), 
        2
    ) AS qoq_growth_percent
FROM quarterly_transaktion
ORDER BY quartile DESC;



-- Transaktionen trends nach kartentyp
CREATE OR REPLACE VIEW kartentyp_trend AS
WITH daily_summary AS (
    SELECT 
        t.transaction_date,
        COALESCE(c.card_type, 'Keine Karte') AS karten_typ,
        COUNT(t.transaction_id) AS tages_anzahl_transaktionen,
        SUM(t.amount_usd) AS tages_transaktionsvolumen_usd
    FROM transactions t
    JOIN accounts a ON t.account_id = a.account_id
    LEFT JOIN cards c ON a.account_id = c.account_id
    GROUP BY 
        t.transaction_date,
        COALESCE(c.card_type, 'Keine Karte')
)
SELECT 
    transaction_date,
    karten_typ,
    tages_transaktionsvolumen_usd,
    tages_anzahl_transaktionen,
    -- Previous day's volume for this specific card type
    LAG(tages_transaktionsvolumen_usd, 1) OVER (
        PARTITION BY karten_typ 
        ORDER BY transaction_date ASC
    ) AS prev_day_volumen_usd,
    -- Cumulative running total to date per card type
    SUM(tages_transaktionsvolumen_usd) OVER (
        PARTITION BY karten_typ 
        ORDER BY transaction_date ASC
    ) AS cumulative_transaktionsvolumen_usd
FROM daily_summary
ORDER BY 
    transaction_date DESC, 
    karten_typ;

-- risiko analyse
CREATE OR REPLACE VIEW risiko_analyse AS
WITH kunden_guthaben AS (
    SELECT 
        customer_id, 
        SUM(balance_usd) AS guthaben
    FROM accounts
    GROUP BY customer_id
),
kunden_kredite AS (
    SELECT 
        customer_id, 
        SUM(loan_amount) AS darlehen
    FROM loans
    GROUP BY customer_id
),
kunden_guthaben_darhlehen AS (
    SELECT 
        c.customer_id,
        COALESCE(g.guthaben, 0) AS guthaben,
        COALESCE(k.darlehen, 0) AS darlehen
    FROM customers c
    LEFT JOIN kunden_guthaben g ON c.customer_id = g.customer_id
    LEFT JOIN kunden_kredite k ON c.customer_id = k.customer_id
)
SELECT 
    ROUND(SUM(guthaben), 2) AS gesamtes_guthaben_bank,
    ROUND(SUM(CASE WHEN darlehen = 0 THEN guthaben ELSE 0 END), 2) AS guthaben_ohne_kredit,
    ROUND(SUM(CASE WHEN darlehen > 0 THEN guthaben ELSE 0 END), 2) AS guthaben_kreditnehmer,
    ROUND(SUM(darlehen), 2) AS gesamte_darlehen,
    ROUND(SUM(CASE WHEN darlehen > 0 THEN guthaben ELSE 0 END) - SUM(darlehen), 2) AS netto_kreditueberhang
FROM kunden_guthaben_darhlehen;


-----------------------------------------------------------------------------------------------------------
/*
Eine Tabelle wurde erzeugt bank_monthly_snapshots. 
        --Alle zeitliche trends in gesamte bank wurde berechnet und dort gespeichert.
        -- die inhalt des dokuments betract DER GLOBALE ÜBERBLICK 
        -- Analyse von verschiedene kartentypen
        -- Neuzugänge und entwiklung in jedem Monat
        
Ein prozedur erstellt - generate_montly_snapshots. 
-- diese prozedur nehmt das Jahr und den Monat als inout, und liefert 3 wichtigste kennzahlen für unsere anaylse
-- Die berechnete informationen werden in bank_monthly_snapshots gespeichert zum bearbeitung in power bi.
*/
----------------------------------------------------------------------------------------------------------
-- Snapshot-Tabelle & Prozedur für monatliche KPIs
CREATE TABLE IF NOT EXISTS bank_monthly_snapshots (
    snapshot_id   SERIAL PRIMARY KEY,
    jahr          INT NOT NULL,
    monat         INT NOT NULL,
    monats_label  VARCHAR(7),
    generiert_am  TIMESTAMP DEFAULT NOW(),
    metrics_json  JSONB
);


CREATE OR REPLACE PROCEDURE generate_monthly_snapshot(p_jahr INT, p_monat INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_monats_start TIMESTAMP;
    v_monats_ende TIMESTAMP;
    v_monats_label VARCHAR(7);
BEGIN
    v_monats_start := TO_TIMESTAMP(p_jahr || '-' || LPAD(p_monat::text, 2, '0') || '-01', 'YYYY-MM-DD');
    v_monats_ende := v_monats_start + INTERVAL '1 month';
    v_monats_label := p_jahr || '-' || LPAD(p_monat::text, 2, '0');

    INSERT INTO bank_monthly_snapshots (jahr, monat, monats_label, metrics_json)
    SELECT 
        p_jahr,
        p_monat,
        v_monats_label,
        jsonb_build_object(
            'snapshot_info', jsonb_build_object(
                'jahr', p_jahr,
                'monat', p_monat,
                'label', TO_CHAR(v_monats_start, 'TMMonth YYYY') 
            ),
            'global_kpis', jsonb_build_object(
                'anzahl_kunden_total', (SELECT COUNT(*) FROM customers),
                'anzahl_konten_total', (SELECT COUNT(*) FROM accounts),
                'anzahl_karten_total', (SELECT COUNT(*) FROM cards),
                'anzahl_loans_total', (SELECT COUNT(*) FROM loans),
                'gesamt_guthaben_bank_usd', (SELECT ROUND(SUM(balance_usd), 2) FROM accounts)
            ),
            'kartentyp_analyse', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'karten_typ', karten_typ,
                        'anzahl_konten', anzahl_konten,
                        'avg_kontostand_usd', avg_kontostand_usd,
                        'gesamt_transaktionsvolumen_monat_usd', gesamt_transaktionsvolumen_usd,
                        'avg_einzeltransaktion_monat_usd', avg_einzeltransaktion_usd
                    )
                )
                FROM (
                    SELECT 
                        COALESCE(c.card_type, 'Keine Karte') AS karten_typ,
                        COUNT(DISTINCT a.account_id) AS anzahl_konten,
                        ROUND(AVG(a.balance_usd), 2) AS avg_kontostand_usd,
                        ROUND(COALESCE(SUM(t.amount_usd), 0), 2) AS gesamt_transaktionsvolumen_usd,
                        ROUND(COALESCE(AVG(t.amount_usd), 0), 2) AS avg_einzeltransaktion_usd
                    FROM accounts a
                    LEFT JOIN cards c ON a.account_id = c.account_id
                    LEFT JOIN transactions t ON a.account_id = t.account_id 
                        AND t.transaction_date >= v_monats_start 
                        AND t.transaction_date < v_monats_ende
                    GROUP BY c.card_type
                ) as sub
            ),
            'monatliche_trends', jsonb_build_object(
                'transaktions_volumen_monat_gesamt', (
                    SELECT ROUND(COALESCE(SUM(amount_usd), 0), 2) FROM transactions 
                    WHERE transaction_date >= v_monats_start AND transaction_date < v_monats_ende
                ),
                'anzahl_transaktionen_monat_gesamt', (
                    SELECT COUNT(*) FROM transactions 
                    WHERE transaction_date >= v_monats_start AND transaction_date < v_monats_ende
                )
            )
        );
END;
$$;

---------------------------------------------------------------------------------------------------------
/*
-- HINWEIS:
--prozedur generate_monthly_snapshots wurde aufgerufen um die Tabelle bank_montly_snapshots aufzufüllen. 
-- diese Befehl führt die ganze prozedur für die ganze zeitraum unsere bank.

DO $$
DECLARE
    v_jahr INT;
    v_monat INT;
BEGIN
    -- Schleife durch alle Jahre von 2019 bis 2025
    FOR v_jahr IN 2019..2025 LOOP
        -- Schleife durch alle 12 Monate des jeweiligen Jahres
        FOR v_monat IN 1..12 LOOP
            
            -- Ruft deine bestehende Prozedur für die jeweilige Kombination auf
            CALL generate_monthly_snapshot(v_jahr, v_monat);
            
        END LOOP;
    END LOOP;
END $$;

*/
----------------------------------------------------------------------------------------------------------

