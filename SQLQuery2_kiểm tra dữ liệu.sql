--use home_credit;
-------- 1. Dữ liệu thiếu: thiếu bao nhiêu, và thiếu có liên quan đến rủi ro không?
---- Tính % NULL của 23 cột:
--select 
--	  cast(avg(case when TARGET is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_TARGET,
--	  cast(avg(case when AMT_CREDIT is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_AMT_CREDIT, 
--	  cast(avg(case when AMT_ANNUITY is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_AMT_ANNUITY, 
--	  cast(avg(case when AMT_GOODS_PRICE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_AMT_GOODS_PRICE, 
--	  cast(avg(case when NAME_CONTRACT_TYPE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_NAME_CONTRACT_TYPE,
--	  cast(avg(case when AMT_INCOME_TOTAL is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_AMT_INCOME_TOTAL, 
--	  cast(avg(case when NAME_INCOME_TYPE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_NAME_INCOME_TYPE, 
--	  cast(avg(case when DAYS_EMPLOYED is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_DAYS_EMPLOYED, 
--	  cast(avg(case when OCCUPATION_TYPE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_OCCUPATION_TYPE, 
--	  cast(avg(case when ORGANIZATION_TYPE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_ORGANIZATION_TYPE,
--	  cast(avg(case when DAYS_BIRTH is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_DAYS_BIRTH, 
--	  cast(avg(case when CODE_GENDER is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_CODE_GENDER, 
--	  cast(avg(case when NAME_EDUCATION_TYPE is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_NAME_EDUCATION_TYPE, 
--	  cast(avg(case when NAME_FAMILY_STATUS is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_NAME_FAMILY_STATUS, 
--	  cast(avg(case when CNT_CHILDREN is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_CNT_CHILDREN, 
--	  cast(avg(case when CNT_FAM_MEMBERS is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_CNT_FAM_MEMBERS,
--	  cast(avg(case when FLAG_OWN_CAR is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_FLAG_OWN_CAR, 
--	  cast(avg(case when FLAG_OWN_REALTY is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_FLAG_OWN_REALTY,
--	  cast(avg(case when EXT_SOURCE_1 is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_EXT_SOURCE_1, 
--	  cast(avg(case when EXT_SOURCE_2 is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_EXT_SOURCE_2, 
--	  cast(avg(case when EXT_SOURCE_3 is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_EXT_SOURCE_3,
--	  cast(avg(case when REGION_RATING_CLIENT is null then 100.0 else 0 end) AS DECIMAL(10, 4)) as NULL_REGION_RATING_CLIENT 
--from application_train;


------2. Các cột số: phân bổ và giá trị ngoại lai
----với các cột AMT_*, DAYS_*, CNT_*, tính min, P1, P25, trung vị, P75, P99, max.
---Lưu ý:
---AMT_INCOME_TOTAL có max khoảng 117 triệu, trong khi P99 chỉ khoảng 470 nghìn. Đây là ngoại lai cực đoan.
---DAYS_EMPLOYED có giá trị dương 365243. Xem tỷ lệ default của nhóm này so với phần còn lại.
---CNT_CHILDREN có giá trị tới 19. Giá trị này có thật, hay là lỗi?

--with doc as (
--	 select v.ten_cot, v.gia_tri
--	 from application_train
--	 cross apply (values
--		   ('AMT_INCOME_TOTAL', cast(AMT_INCOME_TOTAL as float)),
--		   ('AMT_CREDIT', cast(AMT_CREDIT as float)),
--		   ('AMT_ANNUITY', cast(AMT_ANNUITY as float)),
--		   ('AMT_GOODS_PRICE', cast(AMT_GOODS_PRICE as float)),
--		   ('DAYS_BIRTH', cast(DAYS_BIRTH as float)),
--		   ('DAYS_EMPLOYED', cast(DAYS_EMPLOYED as float)),
--		   ('CNT_CHILDREN', cast(CNT_CHILDREN as float)),
--		   ('CNT_FAM_MEMBERS', cast(CNT_FAM_MEMBERS as float))
--		   ) v(ten_cot, gia_tri)
--	where v.gia_tri is not null)

--select ten_cot,
--	   min(gia_tri) as min_,
--	   APPROX_PERCENTILE_CONT(0.01) within group (order by gia_tri) as p01,
--	   APPROX_PERCENTILE_CONT(0.25) within group (order by gia_tri) as p25,
--	   APPROX_PERCENTILE_CONT(0.50) within group (order by gia_tri) as median,
--	   APPROX_PERCENTILE_CONT(0.75) within group (order by gia_tri) as p75,
--	   APPROX_PERCENTILE_CONT(0.99) within group (order by gia_tri) as p99,
--	   max(gia_tri) as max_
--from doc
--group by ten_cot 
--order by ten_cot;

---AMT_INCOME_TOTAL có max khoảng 117 triệu, trong khi P99 chỉ khoảng 470 nghìn. Đây là ngoại lai cực đoan.
---Cần check xem đây là lỗi nhập liệu hay thực tế. 
--select top 10 SK_ID_CURR, AMT_INCOME_TOTAL, AMT_CREDIT, AMT_ANNUITY, NAME_INCOME_TYPE, OCCUPATION_TYPE, TARGET
--from application_train 
--order by AMT_INCOME_TOTAL desc;

--- xác định nhóm khách hàng có day_employed = 365243 là ai? rủi ro của nhóm này so với phần còn lại?
--select NAME_INCOME_TYPE
--from application_train
--where DAYS_EMPLOYED = 365243
--group by NAME_INCOME_TYPE;

--select case when DAYS_EMPLOYED = 365243 then 'Ma 365243' else 'Con lai' end,
--       count(*) as so_khach,
--       round(avg(TARGET * 100.0), 2) as ty_le_default
--from application_train
--group by case when DAYS_EMPLOYED = 365243 then 'Ma 365243' else 'Con lai' end;


--- xem số lượng con mà mỗi gia đình có, và số con ảnh hưởng như nào để tỷ lệ default
--select CNT_CHILDREN, count(*) as so_khach, round(avg(target * 100.0), 2) as ty_le_default
--from application_train
--group by CNT_CHILDREN
--order by CNT_CHILDREN desc;
--- kiểm tra số lượng con cái có đúng với các cột các không?
--select SK_ID_CURR,
--	   -DAYS_BIRTH/365 as 'tuoi',
--	   NAME_FAMILY_STATUS, CNT_CHILDREN, CNT_FAM_MEMBERS, TARGET
--from application_train
--where CNT_CHILDREN >= 6
--order by CNT_CHILDREN desc;
---Chia children's ra làm 3 nhóm: 0, 1-2, >3 và so sánh tỷ lệ default:
--select case when CNT_CHILDREN = 0 then '0'
--			when CNT_CHILDREN <= 2 then '1-2'
--			else '3+' end as child_type,
--	   count(*) as so_luong,
--	   cast(100.0 * count(*)/sum(count(*)) over () as decimal(5,2)) as ty_trong,
--	   round(avg(target * 100.0), 2) as default_rate
--from application_train
--group by case when CNT_CHILDREN = 0 then '0'
--			  when CNT_CHILDREN <= 2 then '1-2'
--			  else '3+' end
--order by child_type;


-------3. Các cột chữ: giá trị lạ và tỷ lệ default theo nhóm
----với mỗi cột chữ, đếm số khách và tính tỷ lệ default theo từng nhóm (vd: OCCUPATION_TYPE).
---Lưu ý: Giá trị lạ: CODE_GENDER = 'XNA', NAME_FAMILY_STATUS = 'Unknown', ORGANIZATION_TYPE = 'XNA'.

----so sánh tỷ lệ default của từng loại OCCUPATION_TYPE 
--select OCCUPATION_TYPE, 
--	     count(*) as so_khach,
--		 cast(100.0 * count(*)/sum(count(*)) over () as decimal(5,2)) as ty_trong,
--	     avg(target * 100.0) as ty_le_default
--from application_train
--group by OCCUPATION_TYPE
--order by ty_le_default desc;


----- so sánh tỷ lệ default của các cột chữ còn lại
--select v.ten_cot, v.gia_tri,
--	   count(*) as so_khach,
--	   cast(100.0 * count(*)/sum(count(*)) over(partition by ten_cot) as decimal(5,2)) as ty_trong_pct,
--	   round(avg(target * 100.0),2) as default_rate
--from application_train
--cross apply (values
--		    ('NAME_INCOME_TYPE', NAME_INCOME_TYPE),
--		    ('NAME_CONTRACT_TYPE', NAME_CONTRACT_TYPE),
--		    ('NAME_EDUCATION_TYPE', NAME_EDUCATION_TYPE),
--		    ('NAME_FAMILY_STATUS', NAME_FAMILY_STATUS),
--		    ('CODE_GENDER', CODE_GENDER),
--		    ('FLAG_OWN_CAR', FLAG_OWN_CAR),
--		    ('FLAG_OWN_REALTY', FLAG_OWN_REALTY),
--			('ORGANIZATION_TYPE', ORGANIZATION_TYPE),
--			('OCCUPATION_TYPE', OCCUPATION_TYPE)
--		    ) v(ten_cot, gia_tri)
--group by ten_cot, gia_tri
--order by ten_cot, default_rate desc;

----------check xem nhóm ORGANIZATION_TYPE = 'XNA' có phải chính là nhóm DAYS_EMPLOYED = 365243 (người hưu trí) không?
--select case when ORGANIZATION_TYPE = 'XNA' then 'XNA' else 'Other' end as organization_type,
--	   case when DAYS_EMPLOYED = 365243 then '365243' else 'Other' end as days_employed,
--	   count(*) as so_khach
--from application_train
--group by case when ORGANIZATION_TYPE = 'XNA' then 'XNA' else 'Other' end,
--	     case when DAYS_EMPLOYED = 365243 then '365243' else 'Other' end;

------4. Các cột số chia thành khoảng: rủi ro thay đổi thế nào?
----chia khách thành nhóm rồi tính tỷ lệ default từng nhóm:
---Tuổi: -DAYS_BIRTH / 365, chia các khoảng 20–30, 30–40…
--- /3650 * 10: chia số nguyên và bỏ phần lẻ ngay tại bước chia, trước khi nhân 10.
--select -DAYS_BIRTH /3650 * 10 as nhom_tuoi,
--	   count(*) as so_khach,
--	   round(avg(target*100.0),2) as default_rate
--from application_train
--group by -DAYS_BIRTH /3650 * 10
--order by nhom_tuoi;

-----(here)
---Thu nhập: chia 5 nhóm đều nhau bằng NTILE(5).
---EXT_SOURCE_2 và EXT_SOURCE_3: chia 5 nhóm bằng NTILE(5).
---Xem trước DTI: AMT_ANNUITY / AMT_INCOME_TOTAL, chia 5 nhóm.
--with doc1 as (
--	 select v.ten_cot, v.gia_tri, target
--	 from application_train
--	 cross apply (values
--	 ('AMT_INCOME_TOTAL', cast(AMT_INCOME_TOTAL as float)),
--	 ('EXT_SOURCE_1', EXT_SOURCE_1),
--	 ('EXT_SOURCE_2', EXT_SOURCE_2),
--	 ('EXT_SOURCE_3', EXT_SOURCE_3),
--	 ('DTI', cast(AMT_ANNUITY as float)/nullif(AMT_INCOME_TOTAL, 0))
--	 ) v(ten_cot, gia_tri) where v.gia_tri is not null
--	 ),
--chia_nhom as (
--	 select *, ntile(5) over (partition by ten_cot order by gia_tri) as nhom
--	 from doc1
--	 )
--select ten_cot, nhom, 
--	   count(*) as so_khach,
--	   min(gia_tri) as nho_nhat,
--	   max(gia_tri) as lon_nhat,
--	   round(avg(target * 100.0), 2) as default_rate
--from chia_nhom
--group by ten_cot, nhom
--order by ten_cot, nhom;

----- default rate based on ext_source
--with t as (
--	 select TARGET, EXT_SOURCE_1, EXT_SOURCE_2, EXT_SOURCE_3,
--	 case when EXT_SOURCE_1 is null then 0 else 1 end
--	 + case when EXT_SOURCE_2 is null then 0 else 1 end
--	 + case when EXT_SOURCE_3 is null then 0 else 1 end as so_diem
--	 from application_train
--)
--select so_diem,
--	   count(*) as so_khach,
--	   round(avg(target*100.0),2) as default_rate
--from t
--group by so_diem
--order by so_diem desc;


------5. Kiểm tra tính hợp lý giữa các cột
---Đếm số dòng vi phạm từng điều sau:
---AMT_ANNUITY > AMT_CREDIT: tiền trả mỗi kỳ lớn hơn cả khoản vay.
---AMT_CREDIT lớn hơn AMT_GOODS_PRICE quá nhiều: vay vượt xa giá trị hàng hóa.
---CNT_FAM_MEMBERS < CNT_CHILDREN + 1: số thành viên gia đình ít hơn số con cộng bản thân.
---Số năm làm việc lớn hơn (tuổi − 14), sau khi đã loại nhóm 365243.
---Tuổi dưới 18.

--SELECT
--  COUNT(*)                                                                   AS tong_dong,
--  SUM(CASE WHEN AMT_ANNUITY > AMT_CREDIT THEN 1 ELSE 0 END)                  AS tra_moi_ky_lon_hon_khoan_vay,
--  SUM(CASE WHEN AMT_CREDIT > AMT_GOODS_PRICE THEN 1 ELSE 0 END)              AS vay_lon_hon_gia_hang,
--  SUM(CASE WHEN AMT_CREDIT > 1.5 * AMT_GOODS_PRICE THEN 1 ELSE 0 END)        AS vay_gap_1_5_lan_gia_hang,
--  SUM(CASE WHEN AMT_ANNUITY > AMT_INCOME_TOTAL THEN 1 ELSE 0 END)            AS dti_tren_1,
--  SUM(CASE WHEN CNT_FAM_MEMBERS < CNT_CHILDREN + 1 THEN 1 ELSE 0 END)        AS gia_dinh_it_hon_so_con,
--  SUM(CASE WHEN -DAYS_BIRTH / 365 < 18 THEN 1 ELSE 0 END)                    AS duoi_18_tuoi,
--  SUM(CASE WHEN DAYS_EMPLOYED <> 365243
--            AND -DAYS_EMPLOYED > -DAYS_BIRTH - (14 * 365) THEN 1 ELSE 0 END)   AS lam_viec_truoc_14_tuoi,
--  SUM(CASE WHEN DAYS_EMPLOYED > 0 AND DAYS_EMPLOYED <> 365243 THEN 1 ELSE 0 END) AS ngay_lam_viec_duong,
--  SUM(CASE WHEN AMT_INCOME_TOTAL <= 0 OR AMT_CREDIT <= 0 THEN 1 ELSE 0 END)  AS tien_am_hoac_bang_0
--FROM application_train;

--==============================================================================================================
--kiểm tra dữ liệu bảng installments_payments

--select count(*) as so_dong,
--	   count(distinct SK_ID_PREV) as so_khoan_vay,
--	   count(distinct SK_ID_CURR) as so_khach
--from installments_payments;


-----bao nhiêu khách ở application_train có lịch sử trả góp?
--select case when i.SK_ID_CURR is null then 'Khong co lich su tra gop' else 'co lich su tra gop' end as nhom,
--		count (*) as so_khach,
--		round(avg(target*100.0),2) as default_rate
--from application_train a
--left join (select distinct SK_ID_CURR from installments_payments) i 
--on a.SK_ID_CURR = i.SK_ID_CURR
--group by case when i.SK_ID_CURR is null then 'Khong co lich su tra gop' else 'co lich su tra gop' end;


----- Khách trả trễ nhiều hay ít?
--select case when DAYS_ENTRY_PAYMENT is null then 'Chua tra'
--			when DAYS_ENTRY_PAYMENT <= DAYS_INSTALMENT then 'Dung han hoac som'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 10 then 'Nhom 1 - No du tieu chuan'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 90 then 'Nhom 2 - No can chu y'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 180 then 'Nhom 3 - No duoi tieu chuan'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 360 then 'Nhom 4 - No nghi ngo'
--			else 'Nhom 5 - No co kha nang mat von' end as nhom_no,
--			count(*) as so_khach,
--			cast(100.0*count(*)/sum(count(*)) over () as decimal(5,2)) as ty_trong_pct
--from installments_payments
--group by case when DAYS_ENTRY_PAYMENT is null then 'Chua tra'
--			when DAYS_ENTRY_PAYMENT <= DAYS_INSTALMENT then 'Dung han hoac som'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 10 then 'Nhom 1 - No du tieu chuan'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 90 then 'Nhom 2 - No can chu y'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 180 then 'Nhom 3 - No duoi tieu chuan'
--			when DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT < 360 then 'Nhom 4 - No nghi ngo'
--			else 'Nhom 5 - No co kha nang mat von' end
--order by nhom_no;


----- có giá trị bất thường không?
--SELECT
--  SUM(CASE WHEN DAYS_ENTRY_PAYMENT IS NULL THEN 1 ELSE 0 END)       AS chua_tra,
--  SUM(CASE WHEN AMT_INSTALMENT = 0 THEN 1 ELSE 0 END)               AS phai_tra_bang_0,
--  SUM(CASE WHEN AMT_PAYMENT = 0 THEN 1 ELSE 0 END)                  AS thuc_tra_bang_0,
--  SUM(CASE WHEN AMT_PAYMENT < AMT_INSTALMENT THEN 1 ELSE 0 END)     AS dong_tra_thieu,
--  SUM(CASE WHEN AMT_PAYMENT > AMT_INSTALMENT THEN 1 ELSE 0 END)     AS dong_tra_thua,
--  SUM(CASE WHEN DAYS_INSTALMENT > 0 THEN 1 ELSE 0 END)              AS han_tra_trong_tuong_lai,
--  SUM(CASE WHEN NUM_INSTALMENT_VERSION = 0 THEN 1 ELSE 0 END)       AS version_0, -- credit card
--  MAX(DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT)                         AS tre_nhieu_nhat,
--  MIN(DAYS_ENTRY_PAYMENT - DAYS_INSTALMENT)                         AS som_nhieu_nhat
--FROM installments_payments;

