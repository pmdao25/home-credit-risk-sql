--USE home_credit;
----Upload raw_application_train by import flat files
----Create application_train (choose 23 columns that will be used)
--SELECT SK_ID_CURR, TARGET,
--       AMT_CREDIT, AMT_ANNUITY, AMT_GOODS_PRICE, NAME_CONTRACT_TYPE,
--       AMT_INCOME_TOTAL, NAME_INCOME_TYPE, DAYS_EMPLOYED, OCCUPATION_TYPE, ORGANIZATION_TYPE,
--       DAYS_BIRTH, CODE_GENDER, NAME_EDUCATION_TYPE, NAME_FAMILY_STATUS, CNT_CHILDREN, CNT_FAM_MEMBERS,
--       FLAG_OWN_CAR, FLAG_OWN_REALTY,
--       EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3,
--       REGION_RATING_CLIENT
--INTO application_train
--FROM raw_application_train;

---- Kiểm tra dữ liệu:
--SELECT count(*) as so_dong FROM application_train;
---- Kiểm tra tỷ lệ target = 1:
--SELECT 
--    COUNT(CASE WHEN target = 1 THEN 1 END) * 1.0 / COUNT(*) AS tỷ_lệ_target_1
--FROM application_train;

---- Bảng tạm:
----DROP TABLE IF EXISTS installments_payments;
--CREATE TABLE installments_payments (
--  SK_ID_PREV INT, SK_ID_CURR INT,
--  NUM_INSTALMENT_VERSION FLOAT, NUM_INSTALMENT_NUMBER FLOAT,
--  DAYS_INSTALMENT FLOAT, DAYS_ENTRY_PAYMENT FLOAT,
--  AMT_INSTALMENT DECIMAL(18,3), AMT_PAYMENT DECIMAL(18,3)
--);
---- Bảng sẽ dùng:
--BULK INSERT installments_payments
--FROM 'D:\home credit\installments_payments.csv'
--WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0a', TABLOCK);

--CREATE INDEX idx_inst_prev_num ON installments_payments (SK_ID_PREV, NUM_INSTALMENT_NUMBER);
--CREATE INDEX idx_inst_curr     ON installments_payments (SK_ID_CURR);

---- Kiểm tra: 13.605.401 dòng
--SELECT COUNT(*) AS so_dong,
--       SUM(CASE WHEN DAYS_ENTRY_PAYMENT IS NULL THEN 1 ELSE 0 END) AS null_days_entry,
--       SUM(CASE WHEN AMT_PAYMENT        IS NULL THEN 1 ELSE 0 END) AS null_amt_payment
--FROM installments_payments;

select top 5 * from application_train;