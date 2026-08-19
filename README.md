Banking SQL Analytics

Analyse eines synthetischen Bankdatensatzes mit 1,26 Mio. Datensätzen zur praktischen Anwendung von SQL, relationaler Datenmodellierung, PostgreSQL, Exploratory Data Analysis (EDA) und Power BI.

Projektstatus: In Entwicklung
Aktueller Stand: Datenquelle identifiziert und Datensatz heruntergeladen
Projektsprache: Deutsch

⸻

1. Projektübersicht

Dieses Projekt dient als praxisorientiertes SQL- und Data-Analytics-Projekt auf Basis eines synthetischen Bankdatensatzes.

Der Datensatz simuliert typische Geschäftsprozesse einer Bank und umfasst Kunden, Konten, Karten, Händler, Filialen, Kredite und Transaktionen.

Ziel des Projekts ist es, einen vollständigen analytischen Workflow abzubilden:

Datenquelle
    ↓
Datenbeschaffung
    ↓
PostgreSQL
    ↓
Relationales Datenmodell
    ↓
Datenvalidierung
    ↓
Datenbereinigung & Transformation
    ↓
SQL-Analysen
    ↓
Explorative Datenanalyse
    ↓
Analytische Views
    ↓
Power BI
    ↓
Business Insights


22. Technischer Stack

PostgreSQL	Relationale Datenbank
SQL	Datenmodellierung, Transformation und Analyse
VS Code	Entwicklung
Git	Versionskontrolle
GitHub	Repository und Dokumentation
Python	Daten extrahrieren
Excel	Datenvalidierung
Power BI	Dashboarding und Visualisierung
copilot 

⸻






⸻

3. Datensatz

3.1 Datenquelle

Synthetic Banking Dataset (CSV + SQL + SQLite)

Quelle:

https://www.kaggle.com/datasets/akrambelha/synthetic-banking-dataset-csv-sql-sqlite

Der Datensatz ist synthetisch und dient zu Lern-, Analyse- und Forschungszwecken.

3.2 Datensatzumfang

Der Datensatz umfasst insgesamt ca. 1,26 Millionen Datensätze.

Tabelle	Datensätze
Customers	50.000
Accounts	75.000
Cards	100.000
Merchants	5.000
Branches	500
Loans	30.000
Transactions	1.000.000
Gesamt	1.260.500



4. Datenbeschaffung

4.1 Download

Der Datensatz wurde vom Kaggle mit kaggleAPI heruntergeladen. python sript im docs ordner unter [Python skript](C:\Users\Admin\Documents\GitHub\synthetic_banking\docs\scripts\extract_data.py) 

data/raw/ enthält die ursprünglichen Quelldateien.

data/processed/ ist für später erzeugte bzw. transformierte Dateien vorgesehen.

4.3 Dateninventar

Nach dem Download werden folgende Eigenschaften der einzelnen Dateien dokumentiert:


5. Datenmodell
5.2 Entity Relationship Model
Das relationale Datenmodell wurde auf Basis der tatsächlich vorhandenen Spalten und Beziehungen entwickelt.
[ER Diagram](docs\er_diagram.png)


8.2 Eindeutigkeit

Überprüfung auf:

* doppelte Customer IDs
* doppelte Account IDs
* doppelte Transaction IDs
* doppelte Loan IDs
* weitere Schlüsselverletzungen

Ergebnisse

Wird ergänzt.

8.3 Referenzielle Integrität

Überprüfung aller definierten Beziehungen zwischen den Tabellen.

Ergebnisse

Wird ergänzt.

8.4 Wertebereiche

Überprüfung unter anderem von:

* Credit Scores
* Kontoständen
* Transaktionsbeträgen
* Kreditbeträgen
* Zinssätzen
* Datumswerten

Ergebnisse

Wird ergänzt.

8.5 Ausreißer

Identifikation und Untersuchung ungewöhnlicher Werte.

Dabei wird zwischen echten fachlichen Ausreißern und möglichen Datenfehlern unterschieden.

Ergebnisse

Wird ergänzt.

⸻

9. Data Dictionary

Für jede Tabelle wird ein Data Dictionary erstellt.

Dokumentiert werden:

Attribut	Beschreibung
Spaltenname	Name des Feldes
Datentyp	PostgreSQL-Datentyp
Primary Key	Ja/Nein
Foreign Key	Ja/Nein
NULL erlaubt	Ja/Nein
Beschreibung	Fachliche Bedeutung
Wertebereich	Erwarteter Wertebereich

Das vollständige Data Dictionary wird unter docs/data_dictionary.md geführt.

⸻

10. Datenmodellierung und Normalisierung

Das Datenmodell wird hinsichtlich der Normalformen untersucht.

Im Fokus stehen:

* First Normal Form (1NF)
* Second Normal Form (2NF)
* Third Normal Form (3NF)

Dabei wird insbesondere untersucht:

* Redundanzen
* funktionale Abhängigkeiten
* Primärschlüssel
* Fremdschlüssel
* Abhängigkeiten zwischen Attributen

Ergebnis

Wird nach Abschluss der Modellierung ergänzt.

⸻

11. Explorative Datenanalyse

11.1 Customer Analytics

Untersucht werden:

* Kundenanzahl
* Altersstruktur
* geografische Verteilung
* Kredit-Score-Verteilung
* Kundensegmente
* Anzahl der Konten pro Kunde
* Guthaben pro Kunde
* Transaktionsaktivität pro Kunde

Ergebnisse

Wird nach Durchführung der EDA ergänzt.

11.2 Account Analytics

Untersucht werden:

* Kontentypen
* Anzahl der Konten
* durchschnittliches Guthaben
* Median des Guthabens
* Guthabenverteilung
* Konten pro Kunde
* Konten pro Filiale

Ergebnisse

Wird ergänzt.

11.3 Transaction Analytics

Untersucht werden:

* Anzahl der Transaktionen
* Transaktionsvolumen
* durchschnittlicher Transaktionswert
* Median
* Transaktionsarten
* Händler
* zeitliche Entwicklung
* Transaktionskonzentration

Ergebnisse

Wird ergänzt.

11.4 Loan Analytics

Untersucht werden:

* Anzahl der Kredite
* Kreditvolumen
* durchschnittliche Kredithöhe
* Kreditarten
* Kreditstatus
* Kreditvolumen nach Kundensegment
* Kreditvolumen nach Kredit-Score
* Kreditvolumen nach Filiale

Ergebnisse

Wird ergänzt.

11.5 Branch Analytics

Untersucht werden:

* Kunden pro Filiale
* Konten pro Filiale
* Guthaben pro Filiale
* Kreditvolumen
* Transaktionsvolumen
* Transaktionsanzahl
* operative Aktivität

Ergebnisse

Wird ergänzt.

11.6 Merchant Analytics

Untersucht werden:

* Transaktionsvolumen pro Händler
* Transaktionsanzahl
* durchschnittlicher Transaktionswert
* Händlerkonzentration
* Händlerkategorien

Ergebnisse

Wird ergänzt.

⸻

12. Credit Risk Analysis

Ein Schwerpunkt des Projekts liegt auf der Untersuchung des Kreditrisikos.

Analysiert werden insbesondere Zusammenhänge zwischen:

Credit Score
      +
Loan Exposure
      +
Account Balance
      +
Customer Characteristics

Geplante Analysen:

* Kredit-Score-Segmente
* Kreditexposure nach Risikosegment
* Kunden mit niedrigem Credit Score und hohem Exposure
* Konzentration des Kreditportfolios
* Kreditvolumen nach Filiale

Ergebnisse

Wird ergänzt.

Hinweis: Da es sich um synthetische Daten handelt und möglicherweise kein validiertes Default-Label vorhanden ist, werden keine Aussagen über tatsächliche Ausfallwahrscheinlichkeiten getroffen.

⸻

13. Transaction Anomaly Analysis

Ungewöhnliche Transaktionsmuster sollen untersucht werden.

Mögliche Kriterien:

* ungewöhnlich hohe Transaktionsbeträge
* ungewöhnlich hohe Transaktionsfrequenz
* ungewöhnliche zeitliche Muster
* Konzentration bestimmter Transaktionen
* starke Abweichungen vom Kundenprofil

Ergebnisse

Wird ergänzt.

Eine erkannte Anomalie wird nicht automatisch als Betrug interpretiert.

⸻

14. Advanced SQL

Das Projekt soll SQL-Techniken auf unterschiedlichen Kompetenzstufen demonstrieren.

14.1 SQL Fundamentals

* SELECT
* WHERE
* ORDER BY
* GROUP BY
* HAVING
* CASE

14.2 SQL Joins

* INNER JOIN
* LEFT JOIN
* RIGHT JOIN
* FULL OUTER JOIN

14.3 Intermediate SQL

* Subqueries
* CTEs
* UNION
* Conditional Aggregation
* COALESCE
* NULLIF

14.4 Advanced SQL

* Window Functions
* ROW_NUMBER
* RANK
* DENSE_RANK
* NTILE
* LAG
* LEAD
* PERCENT_RANK
* Running Totals
* Rolling Averages

14.5 PostgreSQL

* DATE_TRUNC
* FILTER
* STRING_AGG
* GENERATE_SERIES
* Views
* Materialized Views
* EXPLAIN ANALYZE

⸻

15. Performance Analysis

Da die Transaktionstabelle 1 Million Datensätze enthält, wird auch die Query-Performance untersucht.

Analysiert werden unter anderem:

* Sequential Scans
* Index Scans
* Bitmap Scans
* Join-Strategien
* Aggregationen
* Query Execution Time

Für ausgewählte Queries wird verwendet:

EXPLAIN ANALYZE

Ergebnisse

Wird ergänzt.

⸻

16. Analytical Views

Für Power BI werden wiederverwendbare analytische Views erstellt.

Geplant sind unter anderem:

vw_customer_analytics
vw_transaction_analytics
vw_credit_risk
vw_branch_performance
vw_merchant_analysis

Die Views sollen komplexe SQL-Logik zentralisieren und eine konsistente Datenbasis für die Visualisierung bereitstellen.

⸻

17. Power BI Dashboard

Die validierten analytischen Views aus PostgreSQL werden anschließend für Power BI verwendet.

17.1 Management Overview

Geplante KPIs:

* Anzahl Kunden
* Anzahl Konten
* Transaktionsvolumen
* Kreditexposure
* durchschnittlicher Credit Score
* durchschnittliches Guthaben

Ergebnisse

Wird ergänzt.

17.2 Customer Analytics

Geplante Visualisierungen:

* Kundenstruktur
* Credit Score Distribution
* Kundensegmente
* Guthabenverteilung
* geografische Verteilung

Ergebnisse

Wird ergänzt.

17.3 Transaction Analytics

Geplante Visualisierungen:

* Transaktionsvolumen
* Transaktionsanzahl
* zeitliche Entwicklung
* Transaktionsarten
* Händler
* Top-Kunden

Ergebnisse

Wird ergänzt.

17.4 Credit Risk

Geplante Visualisierungen:

* Kreditexposure
* Credit Score
* Risikosegmente
* Exposure nach Kundengruppe
* Exposure nach Filiale

Ergebnisse

Wird ergänzt.

⸻

18. Excel Validation

Excel wird ergänzend zur unabhängigen Validierung ausgewählter Kennzahlen eingesetzt.

Beispiele:

* Row Counts
* Summen
* Durchschnittswerte
* Stichproben
* Pivot-Tabellen

Ziel ist es, ausgewählte PostgreSQL-Ergebnisse unabhängig zu überprüfen.

⸻

19. Business Insights

Die finale Analyse soll nicht ausschließlich technische SQL-Ergebnisse präsentieren.

Aus den Ergebnissen sollen relevante Business Insights abgeleitet werden.

Geplante Bereiche:

Kunden

Wird ergänzt.

Transaktionen

Wird ergänzt.

Kreditportfolio

Wird ergänzt.

Filialen

Wird ergänzt.

Risiken

Wird ergänzt.

⸻

20. Handlungsempfehlungen

Auf Basis der validierten Analyseergebnisse sollen Handlungsempfehlungen entwickelt werden.

Ergebnisse

Wird ergänzt.

⸻

21. Limitationen

Die Ergebnisse müssen im Kontext des Datensatzes interpretiert werden.

Der verwendete Datensatz ist synthetisch und stellt keine reale Bankpopulation dar.

Daraus ergeben sich unter anderem folgende Einschränkungen:

* keine Übertragbarkeit auf reale Bankkunden
* keine Aussage über tatsächliche Marktverhältnisse
* keine automatische Aussage über reale Kreditrisiken
* mögliche vereinfachte Geschäftslogik
* mögliche künstliche Verteilungen
* keine Validierung gegen reale Bankdaten

Weitere Limitationen werden nach Abschluss der Analyse dokumentiert.

⸻



⸻

25. Projektfortschritt

Phase	Status
Projektdefinition	Abgeschlossen
Datensatz ausgewählt	Abgeschlossen
Datensatz heruntergeladen	Abgeschlossen
Dateninspektion	Offen
Data Dictionary	Offen
ER-Modell	Offen
PostgreSQL Setup	Offen
Raw/Staging Layer	Offen
Datenimport	Offen
Data Quality	Offen
Core Data Model	Offen
Transformationen	Offen
SQL Analytics	Offen
EDA	Offen
Analytical Views	Offen
Performance Analysis	Offen
Power BI Dashboard	Offen
Business Insights	Offen
Dokumentation	In Bearbeitung

⸻

26. Ziel des Projekts

Das Projekt soll zeigen, wie aus einem umfangreichen relationalen Datensatz eine strukturierte analytische Lösung entwickelt werden kann.

Der Fokus liegt auf:

Relational Database Design
        +
SQL
        +
Data Quality
        +
Data Analysis
        +
Business Intelligence

Alle quantitativen Ergebnisse und Business Insights werden erst nach Durchführung und Validierung der jeweiligen Analysen in dieses README aufgenommen.

⸻
