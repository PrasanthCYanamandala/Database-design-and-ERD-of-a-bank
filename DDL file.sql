/*
 Group Project 4 BAUN 6320 - UTD
*/


/* DROP statements to clean up objects from previous run */
-- Triggers
DROP TRIGGER TRG_Customer on Customer;
DROP TRIGGER TRG_Account on Account;
DROP TRIGGER TRG_DebitCard on DebitCard;

-- Sequences
DROP SEQUENCE SEQ_Customer_cust_id;
DROP SEQUENCE SEQ_Account_acc_number;
DROP SEQUENCE SEQ_DebitCard_card_number;

-- Views
DROP VIEW CustomerDetails;
DROP VIEW AccountInfo;
DROP VIEW DebitInfo;

-- Indices
DROP INDEX IDX_Auditor_aud_contact;

DROP INDEX IDX_Bank_bank_name;

DROP INDEX IDX_Customer_cust_contact;

DROP INDEX IDX_Account_cust_id_FK;
DROP INDEX IDX_Account_bank_code_FK;
DROP INDEX IDX_Account_acc_balance;
DROP INDEX IDX_Account_acc_status;

DROP INDEX IDX_DebitCard_acc_number_FK;
DROP INDEX IDX_DebitCard_card_type;
DROP INDEX IDX_DebitCard_card_expiry;

-- Tables
DROP TABLE DebitCard;
DROP TABLE Account;
DROP TABLE Customer;
DROP TABLE Auditor;
DROP TABLE Bank;


/* Create tables based on entities */
CREATE TABLE Bank (
    bank_code           VARCHAR(30)  NOT NULL,
    bank_name           VARCHAR(30)  NOT NULL,
    contact             VARCHAR(30)  NOT NULL,
    timings             VARCHAR(30)  NOT NULL,
    address             VARCHAR(512) NOT NULL,
    
    CONSTRAINT PK_Bank PRIMARY KEY (bank_code)
);

CREATE TABLE Auditor (
    aud_id          VARCHAR(30)  NOT NULL,
    fname           VARCHAR(30)  NOT NULL,
    lname           VARCHAR(30)  NOT NULL,
    contact         VARCHAR(30)  NOT NULL,
    address         VARCHAR(512) NOT NULL,
    bank_code       VARCHAR(30)  NOT NULL,

    CONSTRAINT PK_Auditor           PRIMARY KEY (aud_id),
    CONSTRAINT FK_Auditor_bank_code FOREIGN KEY (bank_code) REFERENCES Bank
);

CREATE TABLE Customer (
    cust_id      INTEGER      NOT NULL,
    fname        VARCHAR(30)  NOT NULL,
    lname        VARCHAR(30)  NOT NULL,
    contact      VARCHAR(30)  NOT NULL,
    address      VARCHAR(512) NOT NULL,

    CONSTRAINT PK_Customer PRIMARY KEY (cust_id)
);

CREATE TABLE Account (
    acc_number      INTEGER             NOT NULL,
    cust_id         INTEGER             NOT NULL,
    bank_code       VARCHAR(30)         NOT NULL,
    acc_type        VARCHAR(30),
    acc_balance     DECIMAL(13,4),
    acc_validity    DATE                NOT NULL,
    acc_status      VARCHAR(30)         NOT NULL,

    CONSTRAINT PK_Account           PRIMARY KEY (acc_number, cust_id, bank_code),
    CONSTRAINT FK_Account_cust_id   FOREIGN KEY (cust_id)   REFERENCES Customer,
    CONSTRAINT FK_Account_bank_code FOREIGN KEY (bank_code) REFERENCES Bank
);

CREATE TABLE DebitCard (
    card_number   INTEGER          NOT NULL,
    acc_number    INTEGER          NOT NULL,
    card_type     VARCHAR(30)      NOT NULL,
    card_provider VARCHAR(30),
    expiry        DATE,
    cvv           VARCHAR(30),

-- Attributes belonging to Platinum Card subtype
    carholder_name         VARCHAR(30),
    atm_withdrawal         DECIMAL(13,4),
    reward_points          INTEGER,
    

    CONSTRAINT PK_DebitCard PRIMARY KEY (card_number, acc_number)
);

/* Create indices for natural keys, foreign keys, and frequently-queried columns */
-- Auditor
-- Natural Keys
CREATE INDEX IDX_Auditor_aud_contact ON Auditor (contact);

-- Bank
--  Natural Keys
CREATE UNIQUE INDEX IDX_Bank_bank_name ON Bank (bank_name);

-- Customer
--  Frequently-queried columns
CREATE INDEX IDX_Customer_cust_contact ON Customer (contact);

-- Account
--  Foreign Keys
CREATE INDEX IDX_Account_cust_id_FK    ON Account (cust_id);
CREATE INDEX IDX_Account_bank_code_FK  ON Account (bank_code);
--  Frequently-queried columns
CREATE INDEX IDX_Account_acc_balance ON Account (acc_balance);
CREATE INDEX IDX_Account_acc_status  ON Account (acc_status);

-- Debit Card
--  Foreign Keys
CREATE INDEX IDX_DebitCard_acc_number_FK  ON DebitCard (acc_number);
--  Frequently-queried columns
CREATE INDEX IDX_DebitCard_card_type      ON DebitCard (card_type);
CREATE INDEX IDX_DebitCard_card_expiry    ON DebitCard (expiry);

/* Alter Tables by adding Audit Columns */
ALTER TABLE Customer  
    ADD created_by    VARCHAR(30),
    ADD date_created  DATE,
    ADD modified_by   VARCHAR(30),
    ADD date_modified DATE;

ALTER TABLE Account 
    ADD created_by    VARCHAR(30),
    ADD date_created  DATE,
    ADD modified_by   VARCHAR(30),
    ADD date_modified DATE;

ALTER TABLE DebitCard  
    ADD created_by    VARCHAR(30),
    ADD date_created  DATE,
    ADD modified_by   VARCHAR(30),
    ADD date_modified DATE;

/* Create Views */
-- Business purpose: The CustomerDetails view will be used for fetching contact details of customers.
CREATE OR REPLACE VIEW CustomerDetails AS
SELECT cust_id, fname, contact
FROM Customer;

-- Business purpose: The AccountInfo view will be used to fetch information about account balance and account status.
CREATE OR REPLACE VIEW AccountInfo AS
SELECT acc_number, cust_id, bank_code, acc_balance, acc_status
FROM Account;

-- Business purpose: The DebitInfo view will be used to find expired cards.
CREATE OR REPLACE VIEW DebitInfo AS
SELECT card_number, card_type, expiry
FROM DebitCard
WHERE expiry IS NOT NULL AND expiry > CURRENT_DATE;


/* Create Sequences */
CREATE SEQUENCE SEQ_Customer_cust_id
    INCREMENT BY 1
    START WITH 0
    NO MAXVALUE
    MINVALUE 0
    NO CYCLE;

CREATE SEQUENCE SEQ_Account_acc_number
    INCREMENT BY 10
    START WITH 0
    NO MAXVALUE
    MINVALUE 0
    NO CYCLE;

CREATE SEQUENCE SEQ_DebitCard_card_number
    INCREMENT BY 100
    START WITH 0
    NO MAXVALUE
    MINVALUE 0
    NO CYCLE;

/* Create Triggers */
-- Business purpose: The TRG_Customer trigger automatically assigns a sequential customer ID to a newly-inserted row in the customer table and assigning appropriate values to the created_by and date_created fields. If the record is being inserted or updated, appropriate values are assigned to the modified_by and modified_date fields.
CREATE OR REPLACE FUNCTION trg_Customer() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cust_id IS NULL THEN
        NEW.cust_id := nextval('SEQ_Customer_cust_id');
    END IF;
    IF NEW.created_by IS NULL THEN
        NEW.created_by := current_user;
    END IF;
    IF NEW.date_created IS NULL THEN
        NEW.date_created := NOW();
    END IF;
    
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        NEW.modified_by := current_user;
        NEW.date_modified := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

 

CREATE TRIGGER TRG_Customer
    BEFORE INSERT OR UPDATE ON Customer
    FOR EACH ROW
    EXECUTE FUNCTION trg_Customer();


-- Business purpose: The TRG_Account trigger automatically assigns a sequential account number to a newly-inserted row in the Account table and assigning appropriate values to the created_by and date_created fields. If the record is being inserted or updated, appropriate values are assigned to the modified_by and modified_date fields.
CREATE OR REPLACE FUNCTION trg_Account() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.acc_number IS NULL THEN
        NEW.acc_number := nextval('SEQ_Account_acc_number');
    END IF;
    IF NEW.created_by IS NULL THEN
        NEW.created_by := current_user;
    END IF;
    IF NEW.date_created IS NULL THEN
        NEW.date_created := NOW();
    END IF;
    
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        NEW.modified_by := current_user;
        NEW.date_modified := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

 

CREATE TRIGGER TRG_Account
    BEFORE INSERT OR UPDATE ON Account
    FOR EACH ROW
    EXECUTE FUNCTION trg_Account();


-- Business purpose: The TRG_DebitCard trigger automatically assigns a sequential card number to a newly-inserted row in the DebitCard table, as well as setting the join date to the current system date and assigning appropriate values to the created_by and date_created fields. If the record is being inserted or updated, appropriate values are assigned to the modified_by and modified_date fields.
CREATE OR REPLACE FUNCTION trg_Debit() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.card_number IS NULL THEN
        NEW.card_number := nextval('SEQ_DebitCard_card_number');
    END IF;
    IF NEW.created_by IS NULL THEN
        NEW.created_by := current_user;
    END IF;
    IF NEW.date_created IS NULL THEN
        NEW.date_created := NOW();
    END IF;
    
    IF TG_OP = 'INSERT' OR TG_OP = 'UPDATE' THEN
        NEW.modified_by := current_user;
        NEW.date_modified := NOW();
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

 CREATE TRIGGER TRG_DebitCard
    BEFORE INSERT OR UPDATE ON DebitCard
    FOR EACH ROW
    EXECUTE FUNCTION trg_Debit();


