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

⸻

10. Datenmodellierung und Normalisierung



⸻

13. Transaction Anomaly Analysis

Ungewöhnliche Transaktionsmuster sollen untersucht werden.

Mögliche Kriterien:

* ungewöhnlich hohe Transaktionsbeträge
* ungewöhnlich hohe Transaktionsfrequenz
* ungewöhnliche zeitliche Muster



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


⸻

16. Analytical Views

Für Power BI werden wiederverwendbare analytische Views erstellt.

Geplant sind unter anderem:

vw_customer_analytics
vw_transaction_analytics
vw_credit_risk
vw_branch_performance
vw_merchant_analysis


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



17.2 Customer Analytics

Geplante Visualisierungen:

* Kundenstruktur
* Credit Score Distribution
* Kundensegmente
* Guthabenverteilung
* geografische Verteilung



17.3 Transaction Analytics

Geplante Visualisierungen:

* Transaktionsvolumen
* Transaktionsanzahl
* zeitliche Entwicklung
* Transaktionsarten
* Händler
* Top-Kunden



17.4 Credit Risk

Geplante Visualisierungen:

* Kreditexposure
* Credit Score
* Risikosegmente
* Exposure nach Kundengruppe
* Exposure nach Filiale

⸻

18. Excel Validation


⸻

19. Business Insights


⸻

20. Handlungsempfehlungen


⸻

21. Limitationen

Die Ergebnisse müssen im Kontext des Datensatzes interpretiert werden.

Der verwendete Datensatz ist synthetisch und stellt keine reale Bankpopulation dar.


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
