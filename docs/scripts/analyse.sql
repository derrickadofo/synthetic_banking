
SELECT DISTINCT customer_id
FROM accounts
;

SELECT DISTINCT customer_id
FROM customers
;


SELECT *
FROM branches
limit 50;

SELECT *
FROM loans;


SELECT *
FROM merchants
;

SELECT *
FROM transactions
LIMIT 50;

SELECT *
FROM cards
LIMIT 50;

-- befehle zum fragestellung

-- Wie viele Kunden bzw. Kontoinhaber enthält der Datensatz insgesamt?

SELECT CONCAT(first_name,' ',last_name) AS kunden_name, COUNT(customer_id)
FROM customers
GROUP BY kunden_name, city
-- HAVING COUNT(customer_id) > 1
ORDER BY COUNT(customer_id) DESC;

SELECT CONCAT(first_name,' ',last_name) AS kunden_name, email, COUNT(customer_id)
FROM customers
GROUP BY kunden_name, email, city
ORDER BY kunden_name;



-- 50000 kunden in der Datensatz insgesamt.
-- es gibt 39560 verschiedene kunden.
-- eine menge von 6300 kunden name kommen mehr mals vor
-- man kann nicht als duplikate umgehen weil die haben alle verschiedene email addrese, bzw die gar nicht mit der name zu tun hatten
-- Die sind auch von vershciedene städte 



-- 4.Wie viele Bankkonten sind im Datensatz vorhanden und wie verteilen sie sich nach Kontotypen (z.B. Girokonto, Sparkonto, Kreditkonto)?
SELECT DISTINCT COUNT(account_id), account_type, 
       ROUND(COUNT(account_id) * 100.0 / SUM(COUNT(*)) OVER (),2)  AS percentage_of_total
FROM accounts 
GROUP BY account_type;

-- 5.Wie viele Transaktionen wurden insgesamt durchgeführt und wie verteilen sie sich nach Transaktionstypen 
--(z.B. Einzahlung, Auszahlung, Überweisung)?
SELECT COUNT(transaction_id)
FROM transactions
; --1000000 transaktionen wurden insgesamt durchgeführt. es gibt kein infos zum transaktionstypen


-- 6.Welche Kunden generieren den höchsten Transaktionswert (Summe aller Transaktionsbeträge)?


WITH transactionswert AS (
                            SELECT  SUM(amount_usd) AS transactionswert_nach_kunden, 
                                    a.customer_id AS kunden_id
                            FROM transactions t
                            LEFT JOIN accounts a
                                ON a.account_id = t.account_id
                            GROUP BY  a.customer_id
                            ORDER BY transactionswert_nach_kunden DESC)
SELECT kunden_id, transactionswert_nach_kunden, CONCAT(first_name,' ',last_name) AS kunden_name
FROM transactionswert t
JOIN customers c
ON t.kunden_id = c.customer_id
ORDER BY transactionswert_nach_kunden DESC;

--Welche Kunden haben die höchste Anzahl an Transaktionen?
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
ORDER BY transactionsanzahl DESC;


--.Analysiere Kontostände:
--•Welche Konten haben die höchsten Guthaben?
SELECT balance_usd, account_id
FROM accounts
GROUP BY account_id
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
LIMIT 10;


SELECT sum(balance_usd), customer_id
FROM accounts
GROUP BY customer_id
ORDER BY balance_usd DESC;

--•Welche Konten weisen negative Salden auf (falls vorhanden)?

 SELECT account_id
 FROM accounts
 WHERE balance_usd < 0;
 --keine konten weisen negative salden



--8.Untersuche das Transaktionsverhalten über die Zeit:
--•Gibt es zeitliche Muster (z.B. nach Monat, Quartal oder Jahr)?

-- Monatlische transaktionsverhalten
SELECT 
    strftime('%Y-%m', transaction_date) AS month,
    COUNT(transaction_id) as transaction_count,
    SUM(amount_usd) as total_amount,
    ROUND(AVG(amount_usd), 2) AS avg_transaction_usd
FROM transactions
GROUP BY month
ORDER BY month;

SELECT 
    strftime('%Y', transaction_date) || '-Q' || 
    ((CAST(strftime('%m', transaction_date) AS INTEGER) + 2) / 3) AS quarter,
    COUNT(transaction_id) AS transaction_count,
    SUM(amount_usd) AS total_amount
FROM transactions
GROUP BY quarter
ORDER BY quarter DESC;

WITH quarterly_transaction AS (SELECT 
                                    strftime('%Y', transaction_date) || '-Q' || 
                                    ((CAST(strftime('%m', transaction_date) AS INTEGER) + 2) / 3) AS quarter,
                                    COUNT(transaction_id) AS transaction_count,
                                    SUM(amount_usd) AS total_amount
                                FROM transactions
                                GROUP BY quarter
                                ORDER BY quarter DESC
),
        quarterly_lag AS (
                        SELECT 
                            quarter,
                            total_amount,
                            LAG(total_amount, 1) OVER (ORDER BY quarter ASC) AS prev_quarter_amount
                        FROM quarterly_transaction)
SELECT 
        quarter,
        total_amount,
        prev_quarter_amount,
        ROUND(
            ((total_amount - prev_quarter_amount) * 100.0) / prev_quarter_amount, 
            2
        ) AS qoq_growth_percent
    FROM quarterly_lag
    ORDER BY quarter DESC;


--9.Analysiere Zusammenhänge zwischen Kontotypen, Transaktionsvolumen und Kundensegmenten
 --(falls Segmentdaten vorhanden)

SELECT 


--10.Identifiziere typische Risiko-oder Merkmalsmuster:
--•Gibt es Kunden mit ungewöhnlich hohem Transaktionsvolumen bei geringem Kontostand?

SELECT COUNT(transaction_id),
        SUM(amount_usd), balance_usd,
        customer_id
FROM transactions t 
JOIN accounts a     
ON t.account_id = a.account_id
GROUP BY customer_id
ORDER BY  COUNT(transaction_id) DESC;

--•Gibt es saisonale Peaks in bestimmten Transaktionstypen?



--11.Identifiziere mindestens 3 eigenständige, interessante Erkenntnisse,
-- die über die obenstehenden Fragestellungen hinausgehen 
--(z.B. Muster in Ausgabenverhalten, Merkmale nach Kundengruppen, Vergleich zwischen Kontotypen)

SELECT 
    TO_CHAR(transaction_date, 'Day') AS day_of_week,
    EXTRACT(ISODOW FROM transaction_date) AS day_num,
    transaction_type,
    COUNT(*) AS transaction_count,
    ROUND(AVG(amount_usd), 2) AS avg_amount
FROM transactions
GROUP BY day_of_week, day_num, transaction_type
ORDER BY day_num, transaction_type;

SELECT 
    a.account_id,
    a.customer_id,
    a.account_type,
    a.balance,
    MAX(t.transaction_date) AS last_transaction_date
FROM accounts a
LEFT JOIN transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.customer_id, a.account_type, a.balance
HAVING MAX(t.transaction_date) < NOW() - INTERVAL '6 months' OR MAX(t.transaction_date) IS NULL
ORDER BY a.balance DESC;


--.(Optional: Erstelle Views für typische Finance-Analysen

-- z.B. „Top-10 Transaktionskunden“,
CREATE VIEW IF NOT EXISTS top_10_transaktionskunden AS
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
ORDER BY transactionsanzahl DESC;

-- „Kontostände nach Kundengruppe“



--„Transaktionsvolumen nach Monat“.
CREATE VIEW IF NOT EXISTS Transaktionsvolumen_nach_Monat AS
SELECT 
    strftime('%Y-%m', transaction_date) AS month,
    COUNT(transaction_id) as transaction_count
FROM transactions
GROUP BY month
ORDER BY month;
