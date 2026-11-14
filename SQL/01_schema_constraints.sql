USE BerkaBankDB;
GO

-- 1. Align all Foreign Key columns to INT (matching the Primary Keys)
ALTER TABLE client  ALTER COLUMN district_id INT;
ALTER TABLE account ALTER COLUMN district_id INT;
ALTER TABLE disp    ALTER COLUMN client_id   INT;
ALTER TABLE disp    ALTER COLUMN account_id  INT;
ALTER TABLE card    ALTER COLUMN disp_id     INT;
ALTER TABLE loan    ALTER COLUMN account_id  INT;
ALTER TABLE [order] ALTER COLUMN account_id  INT;
ALTER TABLE trans   ALTER COLUMN account_id  INT;
GO

-- 2. Convert date columns from VARCHAR(MAX) to proper DATE type
ALTER TABLE client  ALTER COLUMN birth_date   DATE;
ALTER TABLE account ALTER COLUMN created_date DATE;
ALTER TABLE card    ALTER COLUMN issued_date  DATE;
ALTER TABLE loan    ALTER COLUMN loan_date    DATE;
ALTER TABLE trans   ALTER COLUMN trans_date   DATE;
GO

-- 3. Add Foreign Keys
ALTER TABLE client  ADD CONSTRAINT FK_client_district  FOREIGN KEY (district_id) REFERENCES district(district_id);
ALTER TABLE account ADD CONSTRAINT FK_account_district FOREIGN KEY (district_id) REFERENCES district(district_id);
ALTER TABLE disp    ADD CONSTRAINT FK_disp_client      FOREIGN KEY (client_id)   REFERENCES client(client_id);
ALTER TABLE disp    ADD CONSTRAINT FK_disp_account     FOREIGN KEY (account_id)  REFERENCES account(account_id);
ALTER TABLE card    ADD CONSTRAINT FK_card_disp        FOREIGN KEY (disp_id)     REFERENCES disp(disp_id);
ALTER TABLE loan    ADD CONSTRAINT FK_loan_account     FOREIGN KEY (account_id)  REFERENCES account(account_id);
ALTER TABLE [order] ADD CONSTRAINT FK_order_account    FOREIGN KEY (account_id)  REFERENCES account(account_id);
ALTER TABLE trans   ADD CONSTRAINT FK_trans_account    FOREIGN KEY (account_id)  REFERENCES account(account_id);
GO

-- 4. Add Covering Index on trans (now that trans_date is DATE)
CREATE INDEX IX_trans_account_date 
ON trans(account_id, trans_date) 
INCLUDE (type, amount, balance, k_symbol);