
PRAGMA foreign_keys = OFF;

-- Tabellen umbennen als backup
-- 2. Rename all original tables to act as data backups
ALTER TABLE customers RENAME TO old_customers;
ALTER TABLE accounts RENAME TO old_accounts;
ALTER TABLE cards RENAME TO old_cards;
ALTER TABLE merchants RENAME TO old_merchants;
ALTER TABLE branches RENAME TO old_branches;
ALTER TABLE loans RENAME TO old_loans;
ALTER TABLE transactions RENAME TO old_transactions;



-- 3.Neue Tabellen erstellen mit PKs, FKs, and Data Quality constraints

CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) NOT NULL,   
    city VARCHAR(50) NOT NULL,  
    credit_score INT NOT NULL, 
    created_at DATE
);

CREATE TABLE accounts (
    account_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    account_type VARCHAR(20),
    balance_usd DECIMAL(12,2),
    open_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE cards (
    card_id VARCHAR(20) PRIMARY KEY,
    account_id VARCHAR(20),
    card_type VARCHAR(20),
    expiration_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

CREATE TABLE merchants (
    merchant_id VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100),
    city VARCHAR(50) NOT NULL   
);


CREATE TABLE branches (
    branch_id VARCHAR(20) PRIMARY KEY,
    branch_name VARCHAR(100),
    city VARCHAR(50) NOT NULL,
     country VARCHAR(50),
    manager_name VARCHAR(100)
);

CREATE TABLE loans (
    loan_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    loan_amount DECIMAL(12,2),
    interest_rate DECIMAL(5,2),
    start_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE transactions (
    transaction_id VARCHAR(25) PRIMARY KEY,
    account_id VARCHAR(20),
    merchant_id VARCHAR(20),
    amount_usd DECIMAL(12,2),
    transaction_date DATE,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE RESTRICT
);


-- 4. Daten vom Altere Tabellen importieren

INSERT INTO customers SELECT * FROM old_customers;

INSERT INTO accounts 
SELECT o.* FROM old_accounts o
INNER JOIN customers c ON o.customer_id = c.customer_id;

INSERT INTO cards 
SELECT o.* FROM old_cards o
INNER JOIN accounts a ON o.account_id = a.account_id;

INSERT INTO merchants 
SELECT * FROM old_merchants WHERE city IS NOT NULL AND city != '';

INSERT INTO branches 
SELECT * FROM old_branches WHERE city IS NOT NULL AND city != '';

INSERT INTO loans 
SELECT o.* FROM old_loans o
INNER JOIN customers c ON o.customer_id = c.customer_id;

INSERT INTO transactions 
SELECT o.* FROM old_transactions o
INNER JOIN accounts a ON o.account_id = a.account_id
INNER JOIN merchants m ON o.merchant_id = m.merchant_id;

--Daten import testen 
SELECT 
    'Customers' AS table_name,
    (SELECT COUNT(*) FROM customers) AS new_count,
    (SELECT COUNT(*) FROM old_customers) AS old_count
UNION ALL
SELECT 'Accounts', (SELECT COUNT(*) FROM accounts), (SELECT COUNT(*) FROM old_accounts)
UNION ALL
SELECT 'Cards', (SELECT COUNT(*) FROM cards), (SELECT COUNT(*) FROM old_cards)
UNION ALL
SELECT 'Loans', (SELECT COUNT(*) FROM loans), (SELECT COUNT(*) FROM old_loans)
UNION ALL
SELECT 'Transactions', (SELECT COUNT(*) FROM transactions), (SELECT COUNT(*) FROM old_transactions);

-- daten erfolgreich importiert. 

-- 5. Altere Tabellen entfernen
DROP TABLE old_cards;
DROP TABLE old_transactions;
DROP TABLE old_loans;
DROP TABLE old_accounts;
DROP TABLE old_customers;
DROP TABLE old_merchants;
DROP TABLE branches;



-- 6. Foreign Keys anschalten
PRAGMA foreign_keys = ON;

-- foreign key constraints testen
INSERT INTO accounts (account_id, customer_id, account_type, balance_usd, open_date)
VALUES ('ACC-99999', 'erroneous', 'CHECKING', 100.00, '2026-01-01');
--fehlermeldung, foreign key constraint


--Indexing und performance 
CREATE INDEX idx_customers_email ON customers(email);
CREATE INDEX idx_customers_city ON customers(city);
CREATE INDEX idx_accounts_customer_id ON accounts(customer_id);
CREATE INDEX idx_accounts_type ON accounts(account_type);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_loans_customer_id ON loans(customer_id);
CREATE INDEX idx_branches_city ON branches(city);

