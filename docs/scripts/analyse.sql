-- Active: 1786951702397@@127.0.0.1@5432@synthetic_bank


SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM branches;
SELECT * FROM merchants;
SELECT * FROM cards;
SELECT * FROM loans;
SELECT * FROM transactions;
SELECT DISTINCT customer_id
FROM accounts
;


-- befehle zum fragestellung

-- Wie viele Kunden bzw. Kontoinhaber enthält der Datensatz insgesamt?

SELECT DISTINCT COUNT(customer_id) AS kunden_anzahl
FROM customers
;
-- 50000 kunden insgesamt


--
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
HAVING COUNT(a.account_id) > 0
ORDER BY anzahl_konten DESC, gesamt_guthaben_usd DESC
;

--kunden die kein konto besitzen

SELECT COUNT(c.customer_id)
FROM accounts a
RIGHT JOIN customers c 
    ON c.customer_id = a.customer_id
WHERE a.customer_id IS NULL; --- die menge aggregiert


---hier sieht man die kunden informationen . Kann eine gute hinweis für die Marketing Abteilung sein.
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS kunden_name,
    c.email,
    c.city,
    c.credit_score,
    c.created_at
FROM customers c
LEFT JOIN accounts a 
    ON c.customer_id = a.customer_id
WHERE a.account_id IS NULL; -- Filtert alle Kunden heraus, die KEIN Konto besitzen

------------------------------------------------------------------------------------------------------------------------------
-- 50000 kunden in der Datensatz insgesamt.
-- es gibt eine menge im höhe von 38838 die mindestens 1 konto besitzen.
-- eine menge von 11162 kunden besitzen kein konto
--------------------------------------------------------------------------------------------------------------------------------






----------------------------------------------------------------------------------------------------------------------------------
-- ANALYSE VON KONTOSTÄNDE
-----------------------------------------------------------------------------------------------------------------------------------

--.Analysiere Kontostände:
--•Welche Konten haben die höchsten Guthaben?
SELECT  account_id,
        account_type,
        balance_usd
FROM accounts
ORDER BY balance_usd DESC;

SELECT 
    a.account_id,
    a.account_type,
    a.balance_usd,
    c.customer_id,
    c.first_name || ' ' || c.last_name AS owner_name
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY a.balance_usd DESC
LIMIT 20;



-- Wie viele Bankkonten sind im Datensatz vorhanden und wie verteilen sie sich nach Kontotypen (z.B. Girokonto, Sparkonto, Kreditkonto)?
SELECT DISTINCT COUNT(account_id) AS konto_anzahl, 
                account_type AS kontotyp, 
                ROUND(COUNT(account_id) * 100.0 / SUM(COUNT(*)) OVER (),2)  AS prozent_anteil
FROM accounts 
GROUP BY account_type;


--•Welche Konten weisen negative Salden auf (falls vorhanden)?

 SELECT account_id
 FROM accounts
 WHERE balance_usd < 0;
 --keine konten weisen negative salden






-----------------------------------------------------------------------------------------------------
.--TRANSAKTIONEN


-- 5.Wie viele Transaktionen wurden insgesamt durchgeführt und wie verteilen sie sich nach Transaktionstypen 
--(z.B. Einzahlung, Auszahlung, Überweisung)?
SELECT COUNT(transaction_id)
FROM transactions; --1000000 transaktionen wurden insgesamt durchgeführt. es gibt kein infos zum transaktionstypen


-- 6.Welche Kunden generieren den höchsten Transaktionswert (Summe aller Transaktionsbeträge)?
--Welche Kunden haben die höchste Anzahl an Transaktionen?
WITH transactionsanzal_tabelle AS (
                            SELECT  COUNT(transaction_id) AS transactionsanzahl,
                                    SUM(amount_usd) AS transactionswert_nach_kunden,
                                    a.customer_id AS kunden_id
                            FROM transactions t
                            LEFT JOIN accounts a
                                ON a.account_id = t.account_id
                            GROUP BY  a.customer_id
                            ORDER BY transactionsanzahl DESC)
SELECT  CONCAT(first_name,' ',last_name) AS kunden_name, 
        transactionsanzahl,
        transactionswert_nach_kunden
FROM transactionsanzal_tabelle t
JOIN customers c
ON t.kunden_id = c.customer_id
ORDER BY transactionsanzahl DESC, transactionswert_nach_kunden DESC; -- kunden mit höchsten transaktionsanzahl haben ebenfalls die höchste transaktionswert. anzegeigt sind top-10


--ransaktionsverhalten über die Zeit:
--•Gibt es zeitliche Muster (z.B. nach Monat, Quartal oder Jahr)?
-- Monatlische transaktionsverhalten
SELECT 
    DATE_TRUNC('MONTH',transaction_date) AS month,
    COUNT(transaction_id) as transaction_count,
    SUM(amount_usd) as total_amount,
    ROUND(AVG(amount_usd), 2) AS avg_transaction_usd
FROM transactions
GROUP BY month
ORDER BY month;

--Transaktionen nach Quartal
SELECT 
    TO_CHAR(transaction_date, 'YYYY-"Q"Q') AS quarter,
    COUNT(transaction_id) AS transaction_count,
    SUM(amount_usd) AS total_amount
FROM transactions
GROUP BY TO_CHAR(transaction_date, 'YYYY-"Q"Q')
ORDER BY quarter DESC;

-- Quartalweise Wachstum
WITH quarterly_transaction AS (
    SELECT 
        TO_CHAR(transaction_date, 'YYYY-"Q"Q') AS quarter,
        COUNT(transaction_id) AS transaction_count,
        SUM(amount_usd) AS total_amount
    FROM transactions
    GROUP BY TO_CHAR(transaction_date, 'YYYY-"Q"Q')
),
quarterly_lag AS (
    SELECT 
        quarter,
        total_amount,
        LAG(total_amount, 1) OVER (ORDER BY quarter ASC) AS prev_quarter_amount
    FROM quarterly_transaction
)
SELECT 
    quarter,
    total_amount,
    prev_quarter_amount,
    ROUND(
        ((total_amount - prev_quarter_amount) * 100.0) / NULLIF(prev_quarter_amount, 0), 
        2
    ) AS qoq_growth_percent
FROM quarterly_lag
ORDER BY quarter DESC;

------------------------------------------------------------------------------------------------------
--9.Analysiere Zusammenhänge zwischen Kontotypen, Transaktionsvolumen und Kundensegmenten
 --(falls Segmentdaten vorhanden)
-- es ist kein segmentdaten vorhanden. 
-- versuch mit karten, kontotypen und transaktionsvolumen zu verknupfen

select count(card_id), card_type
FROM cards
group by card_type
order by count(card_id); -- karten typen überprufen

-- Analyse 1: Zusammenhang zwichen kartentypen ud höheren umsätze im vergleich zu konten 
SELECT 
    COALESCE(c.card_type, 'Keine Karte') AS karten_typ,
    COUNT(DISTINCT a.account_id) AS anzahl_konten,
    ROUND(AVG(a.balance_usd), 2) AS avg_kontostand_usd,
    ROUND(COALESCE(SUM(t.amount_usd), 0), 2) AS gesamt_transaktionsvolumen_usd,
    ROUND(COALESCE(AVG(t.amount_usd), 0), 2) AS avg_einzeltransaktion_usd
FROM accounts a
LEFT JOIN cards c ON a.account_id = c.account_id
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.card_type
ORDER BY gesamt_transaktionsvolumen_usd DESC;

/*
1. Die Kern-Erkenntnisse (Key Insights)
Kartenbesitzer dominieren die Bank:Die große Mehrheit deiner Kunden nutzt eine Karte. 
Zusammen machen Debit- und Credit-Konten 73.011 Konten aus, während nur 19.802 Konten (ca. 21 %) ohne Karte geführt werden.
Kartenbesitzer generieren den Umsatz:Konten mit Karten (Debit & Credit) erzeugen jeweils über 3,3 Milliarden USD an Transaktionsvolumen.
Das ist fast dreimal so viel wie die Konten ohne Karte (1,32 Milliarden USD). 
Karten treiben also die finanzielle Aktivität massiv an.

Guthaben ist unabhängig von der Karte:Der durchschnittliche Kontostand 
(avg_kontostand_usd) ist bei allen drei Gruppen fast identisch und liegt extrem stabil bei rund 100.000 USD 
(schwankt nur minimal zwischen 99.879 USD und 100.593 USD). Das bedeutet: Kunden lassen nicht mehr Geld auf dem Konto liegen, 
nur weil sie eine Kreditkarte haben.Die "Einzeltransaktions-Konstante":Egal ob Debit, Credit oder Keine Karte – 
der durchschnittliche Wert einer einzelnen Transaktion (`avg_einzeltransaktion_") liegt wie festgemauert bei knapp 5.000 USD. 
Das ist ein sehr hoher Schnitt für Einzelbuchungen und deutet darauf hin, dass hier entweder synthetische Testdaten vorliegen 
oder viele Großtransaktionen (wie Gehalt/Miete) einfließen.2. Strategische Empfehlungen für das Bankgeschäft (Business Actions)

Potenzial bei "Keine Karte"-Kunden:Du hast fast 20.000 Kunden ohne Karte, die aber im Schnitt 100.000 USD auf dem Konto liegen haben (hohe Liquidität!). 
Diese Gruppe ist extrem wertvoll. 
Maßnahme: Gezielte Marketingkampagnen starten, um diesen Kunden eine Credit- oder Debit-Karte anzubieten, 
da sie sofort zusätzlichen Transaktionsumsatz bringen würden.
Gleichgewicht zwischen Debit und Credit:Debit (36.757) und Credit (36.254) halten sich fast perfekt die Waage. 
Da Kreditkarten für Banken durch Gebühren (Interchange Fees) oft profitabler sind, könnte man versuchen,
 Debit-Nutzer zu Credit-Nutzern hochzustufen (Upselling).*/


-------------------------------------------------------------------------------------------------------



--Identifiziere mindestens 3 eigenständige, interessante Erkenntnisse,
-- die über die obenstehenden Fragestellungen hinausgehen 
--(z.B. Muster in Ausgabenverhalten, Merkmale nach Kundengruppen, Vergleich zwischen Kontotypen)


-- kontostände nach der letze transaktions_datum
SELECT 
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance_usd,
    MAX(t.transaction_date) AS last_transaction_date
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.customer_id, a.account_type, a.balance_usd
HAVING MAX(t.transaction_date) < NOW() - INTERVAL '6 months' OR MAX(t.transaction_date) IS NULL
ORDER BY a.balance_usd DESC;



--top-10 kunden mit der höchsten karteneinzatz im verhältnis zum kontostand

SELECT 
    a.account_id,
    a.account_type,
    a.balance_usd AS aktueller_kontostand_usd,
    c.card_type,
    COUNT(t.transaction_id) AS anzahl_transaktionen,
    SUM(t.amount_usd) AS gesamt_umsatz_usd,
    -- Berechnung: Wie oft wurde das aktuelle Guthaben theoretisch umgesetzt?
    ROUND(SUM(t.amount_usd) / NULLIF(a.balance_usd, 0), 2) AS umsatz_zu_guthaben_ratio
FROM accounts a
INNER JOIN cards c ON a.account_id = c.account_id
INNER JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_type, a.balance_usd, c.card_type
ORDER BY gesamt_umsatz_usd DESC
LIMIT 10;






--.(Optional: Erstelle Views für typische Finance-Analysen

-- z.B. „Top-10 Transaktionskunden“,

CREATE VIEW top_10_transaktionskunden AS
WITH transactionsanzal_tabelle AS (
                            SELECT  COUNT(transaction_id) AS transactionsanzahl, 
                                    a.customer_id AS kunden_id
                            FROM transactions t
                            LEFT JOIN accounts a
                                ON a.account_id = t.account_id
                            GROUP BY  a.customer_id
                            ORDER BY transactionsanzahl DESC)
SELECT  CONCAT(first_name,' ',last_name) AS kunden_name, 
        transactionsanzahl
FROM transactionsanzal_tabelle t
JOIN customers c
ON t.kunden_id = c.customer_id
ORDER BY transactionsanzahl DESC
LIMIT 10;

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



--„Transaktionsvolumen nach Monat“.
CREATE VIEW Transaktionsvolumen_nach_Monat AS
SELECT 
    date_trunc('month', transaction_date) AS month,
    COUNT(transaction_id) as transaction_count
FROM transactions
GROUP BY month
ORDER BY month;



-- Kunden die kein aktiven konto bisitzen

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
WHERE a.account_id IS NULL; -- Filtert alle Kunden heraus, die KEIN Konto besitzen

-----------------------------------------------------------------------------------------------------------------
-- BRANCH PERFORMANCE
-- Diese Ansicht berechnet für jede Filiale, wie viele Kunden in ihrer Stadt wohnen, 
-- wie hoch das dortige Sparguthaben ist und wie viel Umsatz die Händler (merchants) in dieser Stadt machen.
--------------------------------------------------------------------------------------------------------



-- Check A: Welche Städte gibt es überhaupt bei den Filialen?
SELECT city, COUNT(*) FROM branches GROUP BY city;

-- Check B: Tauchen genau DIESE Städte auch bei den Kunden auf?

SELECT city, COUNT(*) FROM customers WHERE city IN (SELECT city FROM branches) GROUP BY city;

-- Die Daten sind extrem stark gestreut. Fast jede Stadt in deiner customers-Tabelle hat nur 1 bis 5 Kunden 
--(manche Ausnahmen wie Lake Michael haben 35, West James 23).
--Gleichzeitig gibts insgesamt 75.000 Konten, was bedeutet, dass 50.000 Kunden auf Tausende von solchen winzigen, generierten Städten aufgeteilt sind.






-----------------------------------------------------------------------------------------------------------
/*
Eine Tabelle wurde erzeugt bank_monthly_snapshots. 
        --Alle zeitliche trends in gesamte bank wurde berechnet und dort gespeichert.
        -- die inhalt des dokuments betract DER GLOBALE ÜBERBLICK 
        -- Analyse von verschiedene kartentypen
        -- Neuzugänge und entwiklung in jedem Monat
        
Um die datei schnell reinzukreigen, wurde eine prozedur erstellt - generate_montly_snapshots. 
-- diese prozedur nehmt das Jahr und den Monat als inout, und liefert 3 wichtigste kennzahlen für unsere anaylse
-- Die berechnete informationen werden in bank_monthly_snapshots gespeichert zum bearbeitung in power bi.
*/
----------------------------------------------------------------------------------------------------------

-- unsere uberblicke Tabelle 
DROP TABLE IF EXISTS bank_monthly_snapshots;
CREATE TABLE IF NOT EXISTS bank_monthly_snapshots (
    snapshot_id SERIAL PRIMARY KEY,
    jahr INT NOT NULL,
    monat INT NOT NULL,
    monats_label VARCHAR(7), -- Format: '2026-08'
    generiert_am TIMESTAMP DEFAULT NOW(),
    metrics_json JSONB
);


-- Prezedur zum automatisierten daten auffüllen 
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


*/
-- tabelle bank_monthly_snapshots uberprüfen

SELECT * 
FROM bank_monthly_snapshots;

