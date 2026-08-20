# 📊 Banking SQL Analytics

Analyse eines synthetischen Bankdatensatzes mit 1,26 Mio. Datensätzen zur praktischen Anwendung von SQL, relationaler Datenmodellierung, PostgreSQL, Exploratory Data Analysis (EDA) und Power BI. Dieses Projekt analysiert das Verhalten von Bankkunden auf Basis ihrer Kartennutzung (`Debit`, `Credit`, `Keine Karte`). Das Ziel ist es, Unterschiede im Kontostand, Transaktionsvolumen und Ausgabeverhalten zu identifizieren, um datengestützte Entscheidungen für Marketing und Produktentwicklung zu treffen.

---

## 📌 Inhaltsverzeichnis
- [Projektübersicht](#projektübersicht)
- [Wichtigste Erkenntnisse (Key Findings)](#wichtigste-erkenntnisse-key-findings)
- [SQL Analysen & Queries](#sql-analysen--queries)
  - [1. Haupt-Aggregation nach Kartentyp](#1-haupt-aggregation-nach-kartentyp)
  - [2. Transaktionsfrequenz pro Konto](#2-transaktionsfrequenz-pro-konto)
  - [3. Identifikation von High-Value-Kunden ohne Karte](#3-identifikation-von-high-value-kunden-ohne-karte)
  - [4. Volumen-Verteilung & Marktanteile](#4-volumen-verteilung--marktanteile)
- [Power BI Dashboard (Vorschau / Integration)](#power-bi-dashboard-vorschau--integration)
- [Nächste Schritte & Empfehlungen](#nächste-schritte--empfehlungen)

---

## 💡 Wichtigste Erkenntnisse (Key Findings)

* **Homogenes Ausgabeverhalten:** Der durchschnittliche Kontostand (~100.000 USD) und die durchschnittliche Einzeltransaktion (~5.000 USD) sind über alle Gruppen hinweg nahezu identisch. Der Kartentyp hat keinen Einfluss auf die Bonität oder die Höhe der einzelnen Transaktion.
* **Karten als Volumen-Treiber:** Kunden mit Kredit- oder Debitkarte generieren ein mehr als **2,5-fach höheres Gesamtvolumen** (~3,3 Mrd. USD) als Kunden ohne Karte (~1,3 Mrd. USD). Dies korreliert direkt mit der doppelt so hohen Kundenanzahl in den Kartengruppen.
* **Symmetrische Verteilung:** Debit- und Kreditkarten halten sich sowohl bei den Kontozahlen (ca. 36.500 Konten) als auch beim Gesamtvolumen exakt die Waage.

---

## 🛠️ SQL Analysen & Queries

Die folgenden SQL-Skripte wurden verwendet, um die Daten aufzubereiten und die Analysewerte zu generieren.

### 1. Haupt-Aggregation nach Kartentyp
Diese Abfrage erzeugt die primäre Übersichtstabelle über Konten, Salden und Transaktionsvolumina.

```sql
SELECT 
    COALESCE(k.karten_typ, 'Keine Karte') AS karten_typ,
    COUNT(DISTINCT kt.konto_id) AS anzahl_konten,
    ROUND(AVG(kt.kontostand_usd), 2) AS avg_kontostand_usd,
    ROUND(SUM(t.betrag_usd), 2) AS gesamt_transaktionsvolumen_usd,
    ROUND(AVG(t.betrag_usd), 2) AS avg_einzeltransaktion_usd
FROM konten kt
LEFT JOIN karten k 
    ON kt.konto_id = k.konto_id
LEFT JOIN transaktionen t 
    ON kt.konto_id = t.konto_id
GROUP BY 1
ORDER BY gesamt_transaktionsvolumen_usd DESC;

```
### 2. Transaktionsfrequenz pro Konto
Um zu prüfen, ob Karteninhaber häufiger bertagen als kartenlose Kunden:

```sql
SELECT 
    COALESCE(k.karten_typ, 'Keine Karte') AS karten_typ,
    COUNT(t.transaktions_id) AS anzahl_transaktionen,
    ROUND(COUNT(t.transaktions_id) * 1.0 / COUNT(DISTINCT kt.konto_id), 2) AS avg_transaktionen_pro_konto
FROM konten kt
LEFT JOIN karten k ON kt.konto_id = k.konto_id
LEFT JOIN transaktionen t ON kt.konto_id = t.konto_id
GROUP BY 1;

```
### 3. Identifikation von High-Value-Kunden ohne Karte
Identifiziert kartenlose Kunden mit hohem Kontostand (> $100.000) für Upselling-Kampagnen:

```sql
SELECT 
    kt.konto_id,
    kt.kunden_id,
    kt.kontostand_usd
FROM konten kt
LEFT JOIN karten k ON kt.konto_id = k.konto_id
WHERE k.karten_id IS NULL
  AND kt.kontostand_usd >= 100000
ORDER BY kt.kontostand_usd DESC;

```
### 4. Volumen-Verteilung & Marktanteile (Prozentual)
Berechnet den prozentualen Anteil am Gesamtumsatz pro Segment:


```sql
WITH SegmentStats AS (
    SELECT 
        COALESCE(k.karten_typ, 'Keine Karte') AS karten_typ,
        SUM(t.betrag_usd) AS segment_volumen
    FROM konten kt
    LEFT JOIN karten k ON kt.konto_id = k.konto_id
    LEFT JOIN transaktionen t ON kt.konto_id = t.konto_id
    GROUP BY 1
)
SELECT 
    karten_typ,
    segment_volumen,
    ROUND((segment_volumen / SUM(segment_volumen) OVER ()) * 100, 2) AS prozent_gesamtvolumen
FROM SegmentStats
ORDER BY segment_volumen DESC;

```
# 1. 📊 Power BI Dashboard (Vorschau & Ergebnisse)

(In Kürze verfügbar – Hier werden nach Fertigstellung des Power BI Dashboards die Ergebnisse visualisiert)


Geplante Visualisierungen:
KPI-Karten: Gesamtvolumen ($7,98 Mrd.), Aktive Konten (92.813), Avg. Transaktion ($5.000).

Donut-Chart: Marktanteil am Transaktionsvolumen nach karten_typ (Debit vs. Credit vs. Keine Karte).

Balkendiagramm: Vergleich der Kundenanzahl vs. Gesamtertrag je Segment.

Interactive Slicers: Filterung nach Region, Kundenalter und Konto-Erstellungsdatum.


