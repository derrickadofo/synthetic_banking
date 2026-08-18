import os
import sqlite3
import csv
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
CSV_DIR = BASE_DIR / "data" / "raw" / "banking_dataset_kaggle" / "data" / "csv"
DB_PATH = BASE_DIR / "data" / "local_bank.db"


def ensure_sqlite_db():
    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()

    # Drop existing tables to create a clean database
    tables = [
        "cards",
        "accounts",
        "loans",
        "transactions",
        "merchants",
        "branches",
        "customers",
    ]

    for table in tables:
        cur.execute(f"DROP TABLE IF EXISTS {table}")

    # Create tables
    cur.execute(
        """
        CREATE TABLE customers (
            customer_id TEXT PRIMARY KEY,
            first_name TEXT,
            last_name TEXT,
            email TEXT,
            city TEXT,
            credit_score INTEGER,
            created_at TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE accounts (
            account_id TEXT PRIMARY KEY,
            customer_id TEXT,
            account_type TEXT,
            balance_usd REAL,
            open_date TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE cards (
            card_id TEXT PRIMARY KEY,
            account_id TEXT,
            card_type TEXT,
            expiration_date TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE merchants (
            merchant_id TEXT PRIMARY KEY,
            merchant_name TEXT,
            city TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE branches (
            branch_id TEXT PRIMARY KEY,
            branch_name TEXT,
            manager_name TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE loans (
            loan_id TEXT PRIMARY KEY,
            customer_id TEXT,
            loan_amount REAL,
            interest_rate REAL,
            start_date TEXT
        )
        """
    )

    cur.execute(
        """
        CREATE TABLE transactions (
            transaction_id TEXT PRIMARY KEY,
            account_id TEXT,
            merchant_id TEXT,
            amount_usd REAL,
            transaction_date TEXT
        )
        """
    )

    # Load CSVs
    csv_map = {
        "customers": CSV_DIR / "customers.csv",
        "accounts": CSV_DIR / "accounts.csv",
        "cards": CSV_DIR / "cards.csv",
        "merchants": CSV_DIR / "merchants.csv",
        "branches": CSV_DIR / "branches.csv",
        "loans": CSV_DIR / "loans.csv",
    }

    for table_name, csv_path in csv_map.items():
        if not csv_path.exists():
            raise FileNotFoundError(f"CSV file not found: {csv_path}")

        with open(csv_path, newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            rows = list(reader)

        if not rows:
            print(f"No rows found in {csv_path.name}; skipping.")
            continue

        columns = list(rows[0].keys())
        placeholders = ", ".join("?" for _ in columns)
        column_sql = ", ".join(columns)

        for row in rows:
            values = [row.get(col) for col in columns]
            cur.execute(
                f"INSERT INTO {table_name} ({column_sql}) VALUES ({placeholders})",
                values,
            )

    conn.commit()
    conn.close()

    print(f"Database created successfully at: {DB_PATH}")


if __name__ == "__main__":
    ensure_sqlite_db()
