
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
SELECT DISTINCT COUNT(account_id), account_type
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

--9.Analysiere Zusammenhänge zwischen Kontotypen, Transaktionsvolumen und Kundensegmenten
 --(falls Segmentdaten vorhanden)

--10.Identifiziere typische Risiko-oder Merkmalsmuster:
--•Gibt es Kunden mit ungewöhnlich hohem Transaktionsvolumen bei geringem Kontostand?


--•Gibt es saisonale Peaks in bestimmten Transaktionstypen?



--11.Identifiziere mindestens 3 eigenständige, interessante Erkenntnisse,
-- die über die obenstehenden Fragestellungen hinausgehen 
--(z.B. Muster in Ausgabenverhalten, Merkmale nach Kundengruppen, Vergleich zwischen Kontotypen)

--.(Optional: Erstelle Views für typische Finance-Analysen,

-- z.B. „Top-10 Transaktionskunden“,
-- „Kontostände nach Kundengruppe“, 
--„Transaktionsvolumen nach Monat“.