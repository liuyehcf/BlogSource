---
title: Trino-Trial
date: 2022-06-05 15:33:45
tags: 
- 原创
categories: 
- Database
---

**阅读更多**

<!--more-->

# 1 Development

[Trino in a Docker container](https://trino.io/docs/current/installation/containers.html)

```sh
docker run --name trino -d -p 8080:8080 trinodb/trino:449

docker exec -it trino trino
```

```sql
trino> show catalogs;
 Catalog
---------
 jmx
 memory
 system
 tpcds
 tpch
(5 rows)

trino> show schemas from tpch;
       Schema
--------------------
 information_schema
 sf1
 sf100
 sf1000
 sf10000
 sf100000
 sf300
 sf3000
 sf30000
 tiny
(10 rows)

trino> select * from tpch.tiny.customer limit 1;
```

# 2 Generate TPCH/TPCDS into Hive

[Hive connector](https://trino.io/docs/current/connector/hive.html)

Start a hive cluster via docker compose according to [docker-hive](https://github.com/big-data-europe/docker-hive)

* `Hive Metastore`:
    * `Port` (`docker ps`): `9083`
    * `ServiceName` (`docker-compose [ -f xxx.yml ] config --services`): `hive-metastore`
* `Network Name` (`docker network ls`): `docker-hive_default`

Then, add a hive catalog:

```sh
docker run --name trino --network docker-hive_default -d -p 5005:5005 trinodb/trino:449
docker exec -it trino bash -c 'echo -e "connector.name=hive\nhive.metastore.uri=thrift://hive-metastore:9083\nhive.compression-codec=LZ4" > /etc/trino/catalog/hive.properties'

# Execute this if you want to debug trino
docker exec -it trino bash -c 'echo "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" >> /etc/trino/jvm.config'
# Or
docker exec -it trino bash -c 'echo -e "-Xdebug\n-Xrunjdwp:server=y,transport=dt_socket,address=*:5005,suspend=n" >> /etc/trino/jvm.config'

docker restart trino
```

```sql
docker exec -it trino trino --catalog hive

trino> show schemas
```

## 2.1 TPC-DS

### 2.1.1 Create Table Statement for Hive

#### 2.1.1.1 Hive Syntax

```sql
CREATE TABLE `call_center`(
  `cc_call_center_sk` INT,
  `cc_call_center_id` VARCHAR(16),
  `cc_rec_start_date` DATE,
  `cc_rec_end_date` DATE,
  `cc_closed_date_sk` INT,
  `cc_open_date_sk` INT,
  `cc_name` VARCHAR(50),
  `cc_class` VARCHAR(50),
  `cc_employees` INT,
  `cc_sq_ft` INT,
  `cc_hours` VARCHAR(20),
  `cc_manager` VARCHAR(40),
  `cc_mkt_id` INT,
  `cc_mkt_class` VARCHAR(50),
  `cc_mkt_desc` VARCHAR(100),
  `cc_market_manager` VARCHAR(40),
  `cc_division` INT,
  `cc_division_name` VARCHAR(50),
  `cc_company` INT,
  `cc_company_name` VARCHAR(50),
  `cc_street_number` VARCHAR(10),
  `cc_street_name` VARCHAR(60),
  `cc_street_type` VARCHAR(15),
  `cc_suite_number` VARCHAR(10),
  `cc_city` VARCHAR(60),
  `cc_county` VARCHAR(30),
  `cc_state` VARCHAR(2),
  `cc_zip` VARCHAR(10),
  `cc_country` VARCHAR(20),
  `cc_gmt_offset` DECIMAL(5,2),
  `cc_tax_percentage` DECIMAL(5,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `catalog_page`(
  `cp_catalog_page_sk` INT,
  `cp_catalog_page_id` VARCHAR(16),
  `cp_start_date_sk` INT,
  `cp_end_date_sk` INT,
  `cp_department` VARCHAR(50),
  `cp_catalog_number` INT,
  `cp_catalog_page_number` INT,
  `cp_description` VARCHAR(100),
  `cp_type` VARCHAR(100)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `catalog_returns`(
  `cr_returned_date_sk` INT,
  `cr_returned_time_sk` INT,
  `cr_item_sk` INT,
  `cr_refunded_customer_sk` INT,
  `cr_refunded_cdemo_sk` INT,
  `cr_refunded_hdemo_sk` INT,
  `cr_refunded_addr_sk` INT,
  `cr_returning_customer_sk` INT,
  `cr_returning_cdemo_sk` INT,
  `cr_returning_hdemo_sk` INT,
  `cr_returning_addr_sk` INT,
  `cr_call_center_sk` INT,
  `cr_catalog_page_sk` INT,
  `cr_ship_mode_sk` INT,
  `cr_warehouse_sk` INT,
  `cr_reason_sk` INT,
  `cr_order_number` INT,
  `cr_return_quantity` INT,
  `cr_return_amount` DECIMAL(7,2),
  `cr_return_tax` DECIMAL(7,2),
  `cr_return_amt_inc_tax` DECIMAL(7,2),
  `cr_fee` DECIMAL(7,2),
  `cr_return_ship_cost` DECIMAL(7,2),
  `cr_refunded_cash` DECIMAL(7,2),
  `cr_reversed_charge` DECIMAL(7,2),
  `cr_store_credit` DECIMAL(7,2),
  `cr_net_loss` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `catalog_sales`(
  `cs_sold_date_sk` INT,
  `cs_sold_time_sk` INT,
  `cs_ship_date_sk` INT,
  `cs_bill_customer_sk` INT,
  `cs_bill_cdemo_sk` INT,
  `cs_bill_hdemo_sk` INT,
  `cs_bill_addr_sk` INT,
  `cs_ship_customer_sk` INT,
  `cs_ship_cdemo_sk` INT,
  `cs_ship_hdemo_sk` INT,
  `cs_ship_addr_sk` INT,
  `cs_call_center_sk` INT,
  `cs_catalog_page_sk` INT,
  `cs_ship_mode_sk` INT,
  `cs_warehouse_sk` INT,
  `cs_item_sk` INT,
  `cs_promo_sk` INT,
  `cs_order_number` INT,
  `cs_quantity` INT,
  `cs_wholesale_cost` DECIMAL(7,2),
  `cs_list_price` DECIMAL(7,2),
  `cs_sales_price` DECIMAL(7,2),
  `cs_ext_discount_amt` DECIMAL(7,2),
  `cs_ext_sales_price` DECIMAL(7,2),
  `cs_ext_wholesale_cost` DECIMAL(7,2),
  `cs_ext_list_price` DECIMAL(7,2),
  `cs_ext_tax` DECIMAL(7,2),
  `cs_coupon_amt` DECIMAL(7,2),
  `cs_ext_ship_cost` DECIMAL(7,2),
  `cs_net_paid` DECIMAL(7,2),
  `cs_net_paid_inc_tax` DECIMAL(7,2),
  `cs_net_paid_inc_ship` DECIMAL(7,2),
  `cs_net_paid_inc_ship_tax` DECIMAL(7,2),
  `cs_net_profit` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `customer`(
  `c_customer_sk` INT,
  `c_customer_id` VARCHAR(16),
  `c_current_cdemo_sk` INT,
  `c_current_hdemo_sk` INT,
  `c_current_addr_sk` INT,
  `c_first_shipto_date_sk` INT,
  `c_first_sales_date_sk` INT,
  `c_salutation` VARCHAR(10),
  `c_first_name` VARCHAR(20),
  `c_last_name` VARCHAR(30),
  `c_preferred_cust_flag` VARCHAR(1),
  `c_birth_day` INT,
  `c_birth_month` INT,
  `c_birth_year` INT,
  `c_birth_country` VARCHAR(20),
  `c_login` VARCHAR(13),
  `c_email_address` VARCHAR(50),
  `c_last_review_date` VARCHAR(10)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `customer_address`(
  `ca_address_sk` INT,
  `ca_address_id` VARCHAR(16),
  `ca_street_number` VARCHAR(10),
  `ca_street_name` VARCHAR(60),
  `ca_street_type` VARCHAR(15),
  `ca_suite_number` VARCHAR(10),
  `ca_city` VARCHAR(60),
  `ca_county` VARCHAR(30),
  `ca_state` VARCHAR(2),
  `ca_zip` VARCHAR(10),
  `ca_country` VARCHAR(20),
  `ca_gmt_offset` DECIMAL(5,2),
  `ca_location_type` VARCHAR(20)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `customer_demographics`(
  `cd_demo_sk` INT,
  `cd_gender` VARCHAR(1),
  `cd_marital_status` VARCHAR(1),
  `cd_education_status` VARCHAR(20),
  `cd_purchase_estimate` INT,
  `cd_credit_rating` VARCHAR(10),
  `cd_dep_count` INT,
  `cd_dep_employed_count` INT,
  `cd_dep_college_count` INT
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `date_dim`(
  `d_date_sk` INT,
  `d_date_id` VARCHAR(16),
  `d_date` DATE,
  `d_month_seq` INT,
  `d_week_seq` INT,
  `d_quarter_seq` INT,
  `d_year` INT,
  `d_dow` INT,
  `d_moy` INT,
  `d_dom` INT,
  `d_qoy` INT,
  `d_fy_year` INT,
  `d_fy_quarter_seq` INT,
  `d_fy_week_seq` INT,
  `d_day_name` VARCHAR(9),
  `d_quarter_name` VARCHAR(6),
  `d_holiday` VARCHAR(1),
  `d_weekend` VARCHAR(1),
  `d_following_holiday` VARCHAR(1),
  `d_first_dom` INT,
  `d_last_dom` INT,
  `d_same_day_ly` INT,
  `d_same_day_lq` INT,
  `d_current_day` VARCHAR(1),
  `d_current_week` VARCHAR(1),
  `d_current_month` VARCHAR(1),
  `d_current_quarter` VARCHAR(1),
  `d_current_year` VARCHAR(1)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `household_demographics`(
  `hd_demo_sk` INT,
  `hd_income_band_sk` INT,
  `hd_buy_potential` VARCHAR(15),
  `hd_dep_count` INT,
  `hd_vehicle_count` INT
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `income_band`(
  `ib_income_band_sk` INT,
  `ib_lower_bound` INT,
  `ib_upper_bound` INT
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `inventory`(
  `inv_date_sk` INT,
  `inv_item_sk` INT,
  `inv_warehouse_sk` INT,
  `inv_quantity_on_hand` INT
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `item`(
  `i_item_sk` INT,
  `i_item_id` VARCHAR(16),
  `i_rec_start_date` DATE,
  `i_rec_end_date` DATE,
  `i_item_desc` VARCHAR(200),
  `i_current_price` DECIMAL(7,2),
  `i_wholesale_cost` DECIMAL(7,2),
  `i_brand_id` INT,
  `i_brand` VARCHAR(50),
  `i_class_id` INT,
  `i_class` VARCHAR(50),
  `i_category_id` INT,
  `i_category` VARCHAR(50),
  `i_manufact_id` INT,
  `i_manufact` VARCHAR(50),
  `i_size` VARCHAR(20),
  `i_formulation` VARCHAR(20),
  `i_color` VARCHAR(20),
  `i_units` VARCHAR(10),
  `i_container` VARCHAR(10),
  `i_manager_id` INT,
  `i_product_name` VARCHAR(50)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `promotion`(
  `p_promo_sk` INT,
  `p_promo_id` VARCHAR(16),
  `p_start_date_sk` INT,
  `p_end_date_sk` INT,
  `p_item_sk` INT,
  `p_cost` DECIMAL(15,2),
  `p_response_target` INT,
  `p_promo_name` VARCHAR(50),
  `p_channel_dmail` VARCHAR(1),
  `p_channel_email` VARCHAR(1),
  `p_channel_catalog` VARCHAR(1),
  `p_channel_tv` VARCHAR(1),
  `p_channel_radio` VARCHAR(1),
  `p_channel_press` VARCHAR(1),
  `p_channel_event` VARCHAR(1),
  `p_channel_demo` VARCHAR(1),
  `p_channel_details` VARCHAR(100),
  `p_purpose` VARCHAR(15),
  `p_discount_active` VARCHAR(1)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `reason`(
  `r_reason_sk` INT,
  `r_reason_id` VARCHAR(16),
  `r_reason_desc` VARCHAR(100)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `ship_mode`(
  `sm_ship_mode_sk` INT,
  `sm_ship_mode_id` VARCHAR(16),
  `sm_type` VARCHAR(30),
  `sm_code` VARCHAR(10),
  `sm_carrier` VARCHAR(20),
  `sm_contract` VARCHAR(20)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `store`(
  `s_store_sk` INT,
  `s_store_id` VARCHAR(16),
  `s_rec_start_date` DATE,
  `s_rec_end_date` DATE,
  `s_closed_date_sk` INT,
  `s_store_name` VARCHAR(50),
  `s_number_employees` INT,
  `s_floor_space` INT,
  `s_hours` VARCHAR(20),
  `s_manager` VARCHAR(40),
  `s_market_id` INT,
  `s_geography_class` VARCHAR(100),
  `s_market_desc` VARCHAR(100),
  `s_market_manager` VARCHAR(40),
  `s_division_id` INT,
  `s_division_name` VARCHAR(50),
  `s_company_id` INT,
  `s_company_name` VARCHAR(50),
  `s_street_number` VARCHAR(10),
  `s_street_name` VARCHAR(60),
  `s_street_type` VARCHAR(15),
  `s_suite_number` VARCHAR(10),
  `s_city` VARCHAR(60),
  `s_county` VARCHAR(30),
  `s_state` VARCHAR(2),
  `s_zip` VARCHAR(10),
  `s_country` VARCHAR(20),
  `s_gmt_offset` DECIMAL(5,2),
  `s_tax_precentage` DECIMAL(5,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `store_returns`(
  `sr_returned_date_sk` INT,
  `sr_return_time_sk` INT,
  `sr_item_sk` INT,
  `sr_customer_sk` INT,
  `sr_cdemo_sk` INT,
  `sr_hdemo_sk` INT,
  `sr_addr_sk` INT,
  `sr_store_sk` INT,
  `sr_reason_sk` INT,
  `sr_ticket_number` INT,
  `sr_return_quantity` INT,
  `sr_return_amt` DECIMAL(7,2),
  `sr_return_tax` DECIMAL(7,2),
  `sr_return_amt_inc_tax` DECIMAL(7,2),
  `sr_fee` DECIMAL(7,2),
  `sr_return_ship_cost` DECIMAL(7,2),
  `sr_refunded_cash` DECIMAL(7,2),
  `sr_reversed_charge` DECIMAL(7,2),
  `sr_store_credit` DECIMAL(7,2),
  `sr_net_loss` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `store_sales`(
  `ss_sold_date_sk` INT,
  `ss_sold_time_sk` INT,
  `ss_item_sk` INT,
  `ss_customer_sk` INT,
  `ss_cdemo_sk` INT,
  `ss_hdemo_sk` INT,
  `ss_addr_sk` INT,
  `ss_store_sk` INT,
  `ss_promo_sk` INT,
  `ss_ticket_number` INT,
  `ss_quantity` INT,
  `ss_wholesale_cost` DECIMAL(7,2),
  `ss_list_price` DECIMAL(7,2),
  `ss_sales_price` DECIMAL(7,2),
  `ss_ext_discount_amt` DECIMAL(7,2),
  `ss_ext_sales_price` DECIMAL(7,2),
  `ss_ext_wholesale_cost` DECIMAL(7,2),
  `ss_ext_list_price` DECIMAL(7,2),
  `ss_ext_tax` DECIMAL(7,2),
  `ss_coupon_amt` DECIMAL(7,2),
  `ss_net_paid` DECIMAL(7,2),
  `ss_net_paid_inc_tax` DECIMAL(7,2),
  `ss_net_profit` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `time_dim`(
  `t_time_sk` INT,
  `t_time_id` VARCHAR(16),
  `t_time` INT,
  `t_hour` INT,
  `t_minute` INT,
  `t_second` INT,
  `t_am_pm` VARCHAR(2),
  `t_shift` VARCHAR(20),
  `t_sub_shift` VARCHAR(20),
  `t_meal_time` VARCHAR(20)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `warehouse`(
  `w_warehouse_sk` INT,
  `w_warehouse_id` VARCHAR(16),
  `w_warehouse_name` VARCHAR(20),
  `w_warehouse_sq_ft` INT,
  `w_street_number` VARCHAR(10),
  `w_street_name` VARCHAR(60),
  `w_street_type` VARCHAR(15),
  `w_suite_number` VARCHAR(10),
  `w_city` VARCHAR(60),
  `w_county` VARCHAR(30),
  `w_state` VARCHAR(2),
  `w_zip` VARCHAR(10),
  `w_country` VARCHAR(20),
  `w_gmt_offset` DECIMAL(5,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `web_page`(
  `wp_web_page_sk` INT,
  `wp_web_page_id` VARCHAR(16),
  `wp_rec_start_date` DATE,
  `wp_rec_end_date` DATE,
  `wp_creation_date_sk` INT,
  `wp_access_date_sk` INT,
  `wp_autogen_flag` VARCHAR(1),
  `wp_customer_sk` INT,
  `wp_url` VARCHAR(100),
  `wp_type` VARCHAR(50),
  `wp_char_count` INT,
  `wp_link_count` INT,
  `wp_image_count` INT,
  `wp_max_ad_count` INT
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `web_returns`(
  `wr_returned_date_sk` INT,
  `wr_returned_time_sk` INT,
  `wr_item_sk` INT,
  `wr_refunded_customer_sk` INT,
  `wr_refunded_cdemo_sk` INT,
  `wr_refunded_hdemo_sk` INT,
  `wr_refunded_addr_sk` INT,
  `wr_returning_customer_sk` INT,
  `wr_returning_cdemo_sk` INT,
  `wr_returning_hdemo_sk` INT,
  `wr_returning_addr_sk` INT,
  `wr_web_page_sk` INT,
  `wr_reason_sk` INT,
  `wr_order_number` INT,
  `wr_return_quantity` INT,
  `wr_return_amt` DECIMAL(7,2),
  `wr_return_tax` DECIMAL(7,2),
  `wr_return_amt_inc_tax` DECIMAL(7,2),
  `wr_fee` DECIMAL(7,2),
  `wr_return_ship_cost` DECIMAL(7,2),
  `wr_refunded_cash` DECIMAL(7,2),
  `wr_reversed_charge` DECIMAL(7,2),
  `wr_account_credit` DECIMAL(7,2),
  `wr_net_loss` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `web_sales`(
  `ws_sold_date_sk` INT,
  `ws_sold_time_sk` INT,
  `ws_ship_date_sk` INT,
  `ws_item_sk` INT,
  `ws_bill_customer_sk` INT,
  `ws_bill_cdemo_sk` INT,
  `ws_bill_hdemo_sk` INT,
  `ws_bill_addr_sk` INT,
  `ws_ship_customer_sk` INT,
  `ws_ship_cdemo_sk` INT,
  `ws_ship_hdemo_sk` INT,
  `ws_ship_addr_sk` INT,
  `ws_web_page_sk` INT,
  `ws_web_site_sk` INT,
  `ws_ship_mode_sk` INT,
  `ws_warehouse_sk` INT,
  `ws_promo_sk` INT,
  `ws_order_number` INT,
  `ws_quantity` INT,
  `ws_wholesale_cost` DECIMAL(7,2),
  `ws_list_price` DECIMAL(7,2),
  `ws_sales_price` DECIMAL(7,2),
  `ws_ext_discount_amt` DECIMAL(7,2),
  `ws_ext_sales_price` DECIMAL(7,2),
  `ws_ext_wholesale_cost` DECIMAL(7,2),
  `ws_ext_list_price` DECIMAL(7,2),
  `ws_ext_tax` DECIMAL(7,2),
  `ws_coupon_amt` DECIMAL(7,2),
  `ws_ext_ship_cost` DECIMAL(7,2),
  `ws_net_paid` DECIMAL(7,2),
  `ws_net_paid_inc_tax` DECIMAL(7,2),
  `ws_net_paid_inc_ship` DECIMAL(7,2),
  `ws_net_paid_inc_ship_tax` DECIMAL(7,2),
  `ws_net_profit` DECIMAL(7,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);

CREATE TABLE `web_site`(
  `web_site_sk` INT,
  `web_site_id` VARCHAR(16),
  `web_rec_start_date` DATE,
  `web_rec_end_date` DATE,
  `web_name` VARCHAR(50),
  `web_open_date_sk` INT,
  `web_close_date_sk` INT,
  `web_class` VARCHAR(50),
  `web_manager` VARCHAR(40),
  `web_mkt_id` INT,
  `web_mkt_class` VARCHAR(50),
  `web_mkt_desc` VARCHAR(100),
  `web_market_manager` VARCHAR(40),
  `web_company_id` INT,
  `web_company_name` VARCHAR(50),
  `web_street_number` VARCHAR(10),
  `web_street_name` VARCHAR(60),
  `web_street_type` VARCHAR(15),
  `web_suite_number` VARCHAR(10),
  `web_city` VARCHAR(60),
  `web_county` VARCHAR(30),
  `web_state` VARCHAR(2),
  `web_zip` VARCHAR(10),
  `web_country` VARCHAR(20),
  `web_gmt_offset` DECIMAL(5,2),
  `web_tax_percentage` DECIMAL(5,2)
) STORED AS PARQUET
TBLPROPERTIES (
    'parquet.compression'='LZ4'
);
```

#### 2.1.1.2 Trino Syntax

```sql
CREATE TABLE call_center(
  cc_call_center_sk INT,
  cc_call_center_id VARCHAR(16),
  cc_rec_start_date DATE,
  cc_rec_end_date DATE,
  cc_closed_date_sk INT,
  cc_open_date_sk INT,
  cc_name VARCHAR(50),
  cc_class VARCHAR(50),
  cc_employees INT,
  cc_sq_ft INT,
  cc_hours VARCHAR(20),
  cc_manager VARCHAR(40),
  cc_mkt_id INT,
  cc_mkt_class VARCHAR(50),
  cc_mkt_desc VARCHAR(100),
  cc_market_manager VARCHAR(40),
  cc_division INT,
  cc_division_name VARCHAR(50),
  cc_company INT,
  cc_company_name VARCHAR(50),
  cc_street_number VARCHAR(10),
  cc_street_name VARCHAR(60),
  cc_street_type VARCHAR(15),
  cc_suite_number VARCHAR(10),
  cc_city VARCHAR(60),
  cc_county VARCHAR(30),
  cc_state VARCHAR(2),
  cc_zip VARCHAR(10),
  cc_country VARCHAR(20),
  cc_gmt_offset DECIMAL(5,2),
  cc_tax_percentage DECIMAL(5,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['cc_call_center_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['cc_call_center_sk']
);

CREATE TABLE catalog_page(
  cp_catalog_page_sk INT,
  cp_catalog_page_id VARCHAR(16),
  cp_start_date_sk INT,
  cp_end_date_sk INT,
  cp_department VARCHAR(50),
  cp_catalog_number INT,
  cp_catalog_page_number INT,
  cp_description VARCHAR(100),
  cp_type VARCHAR(100)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['cp_catalog_page_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['cp_catalog_page_sk']
);

CREATE TABLE catalog_returns(
  cr_returned_date_sk INT,
  cr_returned_time_sk INT,
  cr_item_sk INT,
  cr_refunded_customer_sk INT,
  cr_refunded_cdemo_sk INT,
  cr_refunded_hdemo_sk INT,
  cr_refunded_addr_sk INT,
  cr_returning_customer_sk INT,
  cr_returning_cdemo_sk INT,
  cr_returning_hdemo_sk INT,
  cr_returning_addr_sk INT,
  cr_call_center_sk INT,
  cr_catalog_page_sk INT,
  cr_ship_mode_sk INT,
  cr_warehouse_sk INT,
  cr_reason_sk INT,
  cr_order_number INT,
  cr_return_quantity INT,
  cr_return_amount DECIMAL(7,2),
  cr_return_tax DECIMAL(7,2),
  cr_return_amt_inc_tax DECIMAL(7,2),
  cr_fee DECIMAL(7,2),
  cr_return_ship_cost DECIMAL(7,2),
  cr_refunded_cash DECIMAL(7,2),
  cr_reversed_charge DECIMAL(7,2),
  cr_store_credit DECIMAL(7,2),
  cr_net_loss DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['cr_returned_date_sk', 'cr_returned_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['cr_returned_date_sk', 'cr_returned_time_sk']
);

CREATE TABLE catalog_sales(
  cs_sold_date_sk INT,
  cs_sold_time_sk INT,
  cs_ship_date_sk INT,
  cs_bill_customer_sk INT,
  cs_bill_cdemo_sk INT,
  cs_bill_hdemo_sk INT,
  cs_bill_addr_sk INT,
  cs_ship_customer_sk INT,
  cs_ship_cdemo_sk INT,
  cs_ship_hdemo_sk INT,
  cs_ship_addr_sk INT,
  cs_call_center_sk INT,
  cs_catalog_page_sk INT,
  cs_ship_mode_sk INT,
  cs_warehouse_sk INT,
  cs_item_sk INT,
  cs_promo_sk INT,
  cs_order_number INT,
  cs_quantity INT,
  cs_wholesale_cost DECIMAL(7,2),
  cs_list_price DECIMAL(7,2),
  cs_sales_price DECIMAL(7,2),
  cs_ext_discount_amt DECIMAL(7,2),
  cs_ext_sales_price DECIMAL(7,2),
  cs_ext_wholesale_cost DECIMAL(7,2),
  cs_ext_list_price DECIMAL(7,2),
  cs_ext_tax DECIMAL(7,2),
  cs_coupon_amt DECIMAL(7,2),
  cs_ext_ship_cost DECIMAL(7,2),
  cs_net_paid DECIMAL(7,2),
  cs_net_paid_inc_tax DECIMAL(7,2),
  cs_net_paid_inc_ship DECIMAL(7,2),
  cs_net_paid_inc_ship_tax DECIMAL(7,2),
  cs_net_profit DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['cs_sold_date_sk', 'cs_sold_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['cs_sold_date_sk', 'cs_sold_time_sk']
);

CREATE TABLE customer(
  c_customer_sk INT,
  c_customer_id VARCHAR(16),
  c_current_cdemo_sk INT,
  c_current_hdemo_sk INT,
  c_current_addr_sk INT,
  c_first_shipto_date_sk INT,
  c_first_sales_date_sk INT,
  c_salutation VARCHAR(10),
  c_first_name VARCHAR(20),
  c_last_name VARCHAR(30),
  c_preferred_cust_flag VARCHAR(1),
  c_birth_day INT,
  c_birth_month INT,
  c_birth_year INT,
  c_birth_country VARCHAR(20),
  c_login VARCHAR(13),
  c_email_address VARCHAR(50),
  c_last_review_date VARCHAR(10)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['c_customer_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['c_customer_sk']
);

CREATE TABLE customer_address(
  ca_address_sk INT,
  ca_address_id VARCHAR(16),
  ca_street_number VARCHAR(10),
  ca_street_name VARCHAR(60),
  ca_street_type VARCHAR(15),
  ca_suite_number VARCHAR(10),
  ca_city VARCHAR(60),
  ca_county VARCHAR(30),
  ca_state VARCHAR(2),
  ca_zip VARCHAR(10),
  ca_country VARCHAR(20),
  ca_gmt_offset DECIMAL(5,2),
  ca_location_type VARCHAR(20)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['ca_address_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['ca_address_sk']
);

CREATE TABLE customer_demographics(
  cd_demo_sk INT,
  cd_gender VARCHAR(1),
  cd_marital_status VARCHAR(1),
  cd_education_status VARCHAR(20),
  cd_purchase_estimate INT,
  cd_credit_rating VARCHAR(10),
  cd_dep_count INT,
  cd_dep_employed_count INT,
  cd_dep_college_count INT
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['cd_demo_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['cd_demo_sk']
);

CREATE TABLE date_dim(
  d_date_sk INT,
  d_date_id VARCHAR(16),
  d_date DATE,
  d_month_seq INT,
  d_week_seq INT,
  d_quarter_seq INT,
  d_year INT,
  d_dow INT,
  d_moy INT,
  d_dom INT,
  d_qoy INT,
  d_fy_year INT,
  d_fy_quarter_seq INT,
  d_fy_week_seq INT,
  d_day_name VARCHAR(9),
  d_quarter_name VARCHAR(6),
  d_holiday VARCHAR(1),
  d_weekend VARCHAR(1),
  d_following_holiday VARCHAR(1),
  d_first_dom INT,
  d_last_dom INT,
  d_same_day_ly INT,
  d_same_day_lq INT,
  d_current_day VARCHAR(1),
  d_current_week VARCHAR(1),
  d_current_month VARCHAR(1),
  d_current_quarter VARCHAR(1),
  d_current_year VARCHAR(1)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['d_date_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['d_date_sk']
);

CREATE TABLE household_demographics(
  hd_demo_sk INT,
  hd_income_band_sk INT,
  hd_buy_potential VARCHAR(15),
  hd_dep_count INT,
  hd_vehicle_count INT
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['hd_demo_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['hd_demo_sk']
);

CREATE TABLE income_band(
  ib_income_band_sk INT,
  ib_lower_bound INT,
  ib_upper_bound INT
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['ib_income_band_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['ib_income_band_sk']
);

CREATE TABLE inventory(
  inv_date_sk INT,
  inv_item_sk INT,
  inv_warehouse_sk INT,
  inv_quantity_on_hand INT
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['inv_date_sk', 'inv_item_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['inv_date_sk', 'inv_item_sk']
);

CREATE TABLE item(
  i_item_sk INT,
  i_item_id VARCHAR(16),
  i_rec_start_date DATE,
  i_rec_end_date DATE,
  i_item_desc VARCHAR(200),
  i_current_price DECIMAL(7,2),
  i_wholesale_cost DECIMAL(7,2),
  i_brand_id INT,
  i_brand VARCHAR(50),
  i_class_id INT,
  i_class VARCHAR(50),
  i_category_id INT,
  i_category VARCHAR(50),
  i_manufact_id INT,
  i_manufact VARCHAR(50),
  i_size VARCHAR(20),
  i_formulation VARCHAR(20),
  i_color VARCHAR(20),
  i_units VARCHAR(10),
  i_container VARCHAR(10),
  i_manager_id INT,
  i_product_name VARCHAR(50)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['i_item_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['i_item_sk']
);

CREATE TABLE promotion(
  p_promo_sk INT,
  p_promo_id VARCHAR(16),
  p_start_date_sk INT,
  p_end_date_sk INT,
  p_item_sk INT,
  p_cost DECIMAL(15,2),
  p_response_target INT,
  p_promo_name VARCHAR(50),
  p_channel_dmail VARCHAR(1),
  p_channel_email VARCHAR(1),
  p_channel_catalog VARCHAR(1),
  p_channel_tv VARCHAR(1),
  p_channel_radio VARCHAR(1),
  p_channel_press VARCHAR(1),
  p_channel_event VARCHAR(1),
  p_channel_demo VARCHAR(1),
  p_channel_details VARCHAR(100),
  p_purpose VARCHAR(15),
  p_discount_active VARCHAR(1)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['p_promo_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['p_promo_sk']
);

CREATE TABLE reason(
  r_reason_sk INT,
  r_reason_id VARCHAR(16),
  r_reason_desc VARCHAR(100)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['r_reason_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['r_reason_sk']
);

CREATE TABLE ship_mode(
  sm_ship_mode_sk INT,
  sm_ship_mode_id VARCHAR(16),
  sm_type VARCHAR(30),
  sm_code VARCHAR(10),
  sm_carrier VARCHAR(20),
  sm_contract VARCHAR(20)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['sm_ship_mode_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['sm_ship_mode_sk']
);

CREATE TABLE store(
  s_store_sk INT,
  s_store_id VARCHAR(16),
  s_rec_start_date DATE,
  s_rec_end_date DATE,
  s_closed_date_sk INT,
  s_store_name VARCHAR(50),
  s_number_employees INT,
  s_floor_space INT,
  s_hours VARCHAR(20),
  s_manager VARCHAR(40),
  s_market_id INT,
  s_geography_class VARCHAR(100),
  s_market_desc VARCHAR(100),
  s_market_manager VARCHAR(40),
  s_division_id INT,
  s_division_name VARCHAR(50),
  s_company_id INT,
  s_company_name VARCHAR(50),
  s_street_number VARCHAR(10),
  s_street_name VARCHAR(60),
  s_street_type VARCHAR(15),
  s_suite_number VARCHAR(10),
  s_city VARCHAR(60),
  s_county VARCHAR(30),
  s_state VARCHAR(2),
  s_zip VARCHAR(10),
  s_country VARCHAR(20),
  s_gmt_offset DECIMAL(5,2),
  s_tax_precentage DECIMAL(5,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['s_store_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['s_store_sk']
);

CREATE TABLE store_returns(
  sr_returned_date_sk INT,
  sr_return_time_sk INT,
  sr_item_sk INT,
  sr_customer_sk INT,
  sr_cdemo_sk INT,
  sr_hdemo_sk INT,
  sr_addr_sk INT,
  sr_store_sk INT,
  sr_reason_sk INT,
  sr_ticket_number INT,
  sr_return_quantity INT,
  sr_return_amt DECIMAL(7,2),
  sr_return_tax DECIMAL(7,2),
  sr_return_amt_inc_tax DECIMAL(7,2),
  sr_fee DECIMAL(7,2),
  sr_return_ship_cost DECIMAL(7,2),
  sr_refunded_cash DECIMAL(7,2),
  sr_reversed_charge DECIMAL(7,2),
  sr_store_credit DECIMAL(7,2),
  sr_net_loss DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['sr_returned_date_sk', 'sr_return_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['sr_returned_date_sk', 'sr_return_time_sk']
);

CREATE TABLE store_sales(
  ss_sold_date_sk INT,
  ss_sold_time_sk INT,
  ss_item_sk INT,
  ss_customer_sk INT,
  ss_cdemo_sk INT,
  ss_hdemo_sk INT,
  ss_addr_sk INT,
  ss_store_sk INT,
  ss_promo_sk INT,
  ss_ticket_number INT,
  ss_quantity INT,
  ss_wholesale_cost DECIMAL(7,2),
  ss_list_price DECIMAL(7,2),
  ss_sales_price DECIMAL(7,2),
  ss_ext_discount_amt DECIMAL(7,2),
  ss_ext_sales_price DECIMAL(7,2),
  ss_ext_wholesale_cost DECIMAL(7,2),
  ss_ext_list_price DECIMAL(7,2),
  ss_ext_tax DECIMAL(7,2),
  ss_coupon_amt DECIMAL(7,2),
  ss_net_paid DECIMAL(7,2),
  ss_net_paid_inc_tax DECIMAL(7,2),
  ss_net_profit DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['ss_sold_date_sk', 'ss_sold_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['ss_sold_date_sk', 'ss_sold_time_sk']
);

CREATE TABLE time_dim(
  t_time_sk INT,
  t_time_id VARCHAR(16),
  t_time INT,
  t_hour INT,
  t_minute INT,
  t_second INT,
  t_am_pm VARCHAR(2),
  t_shift VARCHAR(20),
  t_sub_shift VARCHAR(20),
  t_meal_time VARCHAR(20)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['t_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['t_time_sk']
);

CREATE TABLE warehouse(
  w_warehouse_sk INT,
  w_warehouse_id VARCHAR(16),
  w_warehouse_name VARCHAR(20),
  w_warehouse_sq_ft INT,
  w_street_number VARCHAR(10),
  w_street_name VARCHAR(60),
  w_street_type VARCHAR(15),
  w_suite_number VARCHAR(10),
  w_city VARCHAR(60),
  w_county VARCHAR(30),
  w_state VARCHAR(2),
  w_zip VARCHAR(10),
  w_country VARCHAR(20),
  w_gmt_offset DECIMAL(5,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['w_warehouse_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['w_warehouse_sk']
);

CREATE TABLE web_page(
  wp_web_page_sk INT,
  wp_web_page_id VARCHAR(16),
  wp_rec_start_date DATE,
  wp_rec_end_date DATE,
  wp_creation_date_sk INT,
  wp_access_date_sk INT,
  wp_autogen_flag VARCHAR(1),
  wp_customer_sk INT,
  wp_url VARCHAR(100),
  wp_type VARCHAR(50),
  wp_char_count INT,
  wp_link_count INT,
  wp_image_count INT,
  wp_max_ad_count INT
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['wp_web_page_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['wp_web_page_sk']
);

CREATE TABLE web_returns(
  wr_returned_date_sk INT,
  wr_returned_time_sk INT,
  wr_item_sk INT,
  wr_refunded_customer_sk INT,
  wr_refunded_cdemo_sk INT,
  wr_refunded_hdemo_sk INT,
  wr_refunded_addr_sk INT,
  wr_returning_customer_sk INT,
  wr_returning_cdemo_sk INT,
  wr_returning_hdemo_sk INT,
  wr_returning_addr_sk INT,
  wr_web_page_sk INT,
  wr_reason_sk INT,
  wr_order_number INT,
  wr_return_quantity INT,
  wr_return_amt DECIMAL(7,2),
  wr_return_tax DECIMAL(7,2),
  wr_return_amt_inc_tax DECIMAL(7,2),
  wr_fee DECIMAL(7,2),
  wr_return_ship_cost DECIMAL(7,2),
  wr_refunded_cash DECIMAL(7,2),
  wr_reversed_charge DECIMAL(7,2),
  wr_account_credit DECIMAL(7,2),
  wr_net_loss DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['wr_returned_date_sk', 'wr_returned_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['wr_returned_date_sk', 'wr_returned_time_sk']
);

CREATE TABLE web_sales(
  ws_sold_date_sk INT,
  ws_sold_time_sk INT,
  ws_ship_date_sk INT,
  ws_item_sk INT,
  ws_bill_customer_sk INT,
  ws_bill_cdemo_sk INT,
  ws_bill_hdemo_sk INT,
  ws_bill_addr_sk INT,
  ws_ship_customer_sk INT,
  ws_ship_cdemo_sk INT,
  ws_ship_hdemo_sk INT,
  ws_ship_addr_sk INT,
  ws_web_page_sk INT,
  ws_web_site_sk INT,
  ws_ship_mode_sk INT,
  ws_warehouse_sk INT,
  ws_promo_sk INT,
  ws_order_number INT,
  ws_quantity INT,
  ws_wholesale_cost DECIMAL(7,2),
  ws_list_price DECIMAL(7,2),
  ws_sales_price DECIMAL(7,2),
  ws_ext_discount_amt DECIMAL(7,2),
  ws_ext_sales_price DECIMAL(7,2),
  ws_ext_wholesale_cost DECIMAL(7,2),
  ws_ext_list_price DECIMAL(7,2),
  ws_ext_tax DECIMAL(7,2),
  ws_coupon_amt DECIMAL(7,2),
  ws_ext_ship_cost DECIMAL(7,2),
  ws_net_paid DECIMAL(7,2),
  ws_net_paid_inc_tax DECIMAL(7,2),
  ws_net_paid_inc_ship DECIMAL(7,2),
  ws_net_paid_inc_ship_tax DECIMAL(7,2),
  ws_net_profit DECIMAL(7,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['ws_sold_date_sk', 'ws_sold_time_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['ws_sold_date_sk', 'ws_sold_time_sk']
);

CREATE TABLE web_site(
  web_site_sk INT,
  web_site_id VARCHAR(16),
  web_rec_start_date DATE,
  web_rec_end_date DATE,
  web_name VARCHAR(50),
  web_open_date_sk INT,
  web_close_date_sk INT,
  web_class VARCHAR(50),
  web_manager VARCHAR(40),
  web_mkt_id INT,
  web_mkt_class VARCHAR(50),
  web_mkt_desc VARCHAR(100),
  web_market_manager VARCHAR(40),
  web_company_id INT,
  web_company_name VARCHAR(50),
  web_street_number VARCHAR(10),
  web_street_name VARCHAR(60),
  web_street_type VARCHAR(15),
  web_suite_number VARCHAR(10),
  web_city VARCHAR(60),
  web_county VARCHAR(30),
  web_state VARCHAR(2),
  web_zip VARCHAR(10),
  web_country VARCHAR(20),
  web_gmt_offset DECIMAL(5,2),
  web_tax_percentage DECIMAL(5,2)
) WITH (
    format = 'PARQUET',
    bucketed_by = ARRAY['web_site_sk'],
    bucket_count = 100,
    sorted_by = ARRAY['web_site_sk']
);
```

### 2.1.2 Insert Statement

Difference between hive schema and trino schema:

* `customer`.`c_last_review_date` vs. `customer`.`c_last_review_date_sk`
* `promotion`.`p_response_target` vs. `promotion`.`p_response_targe`

```sql
INSERT INTO call_center (
  cc_call_center_sk,
  cc_call_center_id,
  cc_rec_start_date,
  cc_rec_end_date,
  cc_closed_date_sk,
  cc_open_date_sk,
  cc_name,
  cc_class,
  cc_employees,
  cc_sq_ft,
  cc_hours,
  cc_manager,
  cc_mkt_id,
  cc_mkt_class,
  cc_mkt_desc,
  cc_market_manager,
  cc_division,
  cc_division_name,
  cc_company,
  cc_company_name,
  cc_street_number,
  cc_street_name,
  cc_street_type,
  cc_suite_number,
  cc_city,
  cc_county,
  cc_state,
  cc_zip,
  cc_country,
  cc_gmt_offset,
  cc_tax_percentage
) SELECT 
  cc_call_center_sk,
  cc_call_center_id,
  cc_rec_start_date,
  cc_rec_end_date,
  cc_closed_date_sk,
  cc_open_date_sk,
  cc_name,
  cc_class,
  cc_employees,
  cc_sq_ft,
  cc_hours,
  cc_manager,
  cc_mkt_id,
  cc_mkt_class,
  cc_mkt_desc,
  cc_market_manager,
  cc_division,
  cc_division_name,
  cc_company,
  cc_company_name,
  cc_street_number,
  cc_street_name,
  cc_street_type,
  cc_suite_number,
  cc_city,
  cc_county,
  cc_state,
  cc_zip,
  cc_country,
  cc_gmt_offset,
  cc_tax_percentage
FROM tpcds.sf1.call_center
ORDER BY cc_call_center_sk;

INSERT INTO catalog_page (
  cp_catalog_page_sk,
  cp_catalog_page_id,
  cp_start_date_sk,
  cp_end_date_sk,
  cp_department,
  cp_catalog_number,
  cp_catalog_page_number,
  cp_description,
  cp_type
) SELECT
  cp_catalog_page_sk,
  cp_catalog_page_id,
  cp_start_date_sk,
  cp_end_date_sk,
  cp_department,
  cp_catalog_number,
  cp_catalog_page_number,
  cp_description,
  cp_type
FROM tpcds.sf1.catalog_page
ORDER BY cp_catalog_page_sk;

INSERT INTO catalog_returns (
  cr_returned_date_sk,
  cr_returned_time_sk,
  cr_item_sk,
  cr_refunded_customer_sk,
  cr_refunded_cdemo_sk,
  cr_refunded_hdemo_sk,
  cr_refunded_addr_sk,
  cr_returning_customer_sk,
  cr_returning_cdemo_sk,
  cr_returning_hdemo_sk,
  cr_returning_addr_sk,
  cr_call_center_sk,
  cr_catalog_page_sk,
  cr_ship_mode_sk,
  cr_warehouse_sk,
  cr_reason_sk,
  cr_order_number,
  cr_return_quantity,
  cr_return_amount,
  cr_return_tax,
  cr_return_amt_inc_tax,
  cr_fee,
  cr_return_ship_cost,
  cr_refunded_cash,
  cr_reversed_charge,
  cr_store_credit,
  cr_net_loss
) SELECT
  cr_returned_date_sk,
  cr_returned_time_sk,
  cr_item_sk,
  cr_refunded_customer_sk,
  cr_refunded_cdemo_sk,
  cr_refunded_hdemo_sk,
  cr_refunded_addr_sk,
  cr_returning_customer_sk,
  cr_returning_cdemo_sk,
  cr_returning_hdemo_sk,
  cr_returning_addr_sk,
  cr_call_center_sk,
  cr_catalog_page_sk,
  cr_ship_mode_sk,
  cr_warehouse_sk,
  cr_reason_sk,
  cr_order_number,
  cr_return_quantity,
  cr_return_amount,
  cr_return_tax,
  cr_return_amt_inc_tax,
  cr_fee,
  cr_return_ship_cost,
  cr_refunded_cash,
  cr_reversed_charge,
  cr_store_credit,
  cr_net_loss
FROM tpcds.sf1.catalog_returns
ORDER BY cr_returned_date_sk, cr_returned_time_sk;

INSERT INTO catalog_sales (
  cs_sold_date_sk,
  cs_sold_time_sk,
  cs_ship_date_sk,
  cs_bill_customer_sk,
  cs_bill_cdemo_sk,
  cs_bill_hdemo_sk,
  cs_bill_addr_sk,
  cs_ship_customer_sk,
  cs_ship_cdemo_sk,
  cs_ship_hdemo_sk,
  cs_ship_addr_sk,
  cs_call_center_sk,
  cs_catalog_page_sk,
  cs_ship_mode_sk,
  cs_warehouse_sk,
  cs_item_sk,
  cs_promo_sk,
  cs_order_number,
  cs_quantity,
  cs_wholesale_cost,
  cs_list_price,
  cs_sales_price,
  cs_ext_discount_amt,
  cs_ext_sales_price,
  cs_ext_wholesale_cost,
  cs_ext_list_price,
  cs_ext_tax,
  cs_coupon_amt,
  cs_ext_ship_cost,
  cs_net_paid,
  cs_net_paid_inc_tax,
  cs_net_paid_inc_ship,
  cs_net_paid_inc_ship_tax,
  cs_net_profit
) SELECT
  cs_sold_date_sk,
  cs_sold_time_sk,
  cs_ship_date_sk,
  cs_bill_customer_sk,
  cs_bill_cdemo_sk,
  cs_bill_hdemo_sk,
  cs_bill_addr_sk,
  cs_ship_customer_sk,
  cs_ship_cdemo_sk,
  cs_ship_hdemo_sk,
  cs_ship_addr_sk,
  cs_call_center_sk,
  cs_catalog_page_sk,
  cs_ship_mode_sk,
  cs_warehouse_sk,
  cs_item_sk,
  cs_promo_sk,
  cs_order_number,
  cs_quantity,
  cs_wholesale_cost,
  cs_list_price,
  cs_sales_price,
  cs_ext_discount_amt,
  cs_ext_sales_price,
  cs_ext_wholesale_cost,
  cs_ext_list_price,
  cs_ext_tax,
  cs_coupon_amt,
  cs_ext_ship_cost,
  cs_net_paid,
  cs_net_paid_inc_tax,
  cs_net_paid_inc_ship,
  cs_net_paid_inc_ship_tax,
  cs_net_profit
FROM tpcds.sf1.catalog_sales
ORDER BY cs_sold_date_sk, cs_sold_time_sk;

INSERT INTO customer (
  c_customer_sk,
  c_customer_id,
  c_current_cdemo_sk,
  c_current_hdemo_sk,
  c_current_addr_sk,
  c_first_shipto_date_sk,
  c_first_sales_date_sk,
  c_salutation,
  c_first_name,
  c_last_name,
  c_preferred_cust_flag,
  c_birth_day,
  c_birth_month,
  c_birth_year,
  c_birth_country,
  c_login,
  c_email_address,
  c_last_review_date
) SELECT 
  c_customer_sk,
  c_customer_id,
  c_current_cdemo_sk,
  c_current_hdemo_sk,
  c_current_addr_sk,
  c_first_shipto_date_sk,
  c_first_sales_date_sk,
  c_salutation,
  c_first_name,
  c_last_name,
  c_preferred_cust_flag,
  c_birth_day,
  c_birth_month,
  c_birth_year,
  c_birth_country,
  c_login,
  c_email_address,
  CAST(c_last_review_date_sk AS VARCHAR(10))
FROM tpcds.sf1.customer
ORDER BY c_customer_sk;

INSERT INTO customer_address (
  ca_address_sk,
  ca_address_id,
  ca_street_number,
  ca_street_name,
  ca_street_type,
  ca_suite_number,
  ca_city,
  ca_county,
  ca_state,
  ca_zip,
  ca_country,
  ca_gmt_offset,
  ca_location_type
) SELECT
  ca_address_sk,
  ca_address_id,
  ca_street_number,
  ca_street_name,
  ca_street_type,
  ca_suite_number,
  ca_city,
  ca_county,
  ca_state,
  ca_zip,
  ca_country,
  ca_gmt_offset,
  ca_location_type
FROM tpcds.sf1.customer_address
ORDER BY ca_address_sk;

INSERT INTO customer_demographics (
  cd_demo_sk,
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
) SELECT 
  cd_demo_sk,
  cd_gender,
  cd_marital_status,
  cd_education_status,
  cd_purchase_estimate,
  cd_credit_rating,
  cd_dep_count,
  cd_dep_employed_count,
  cd_dep_college_count
FROM tpcds.sf1.customer_demographics
ORDER BY cd_demo_sk;

INSERT INTO date_dim (
  d_date_sk,
  d_date_id,
  d_date,
  d_month_seq,
  d_week_seq,
  d_quarter_seq,
  d_year,
  d_dow,
  d_moy,
  d_dom,
  d_qoy,
  d_fy_year,
  d_fy_quarter_seq,
  d_fy_week_seq,
  d_day_name,
  d_quarter_name,
  d_holiday,
  d_weekend,
  d_following_holiday,
  d_first_dom,
  d_last_dom,
  d_same_day_ly,
  d_same_day_lq,
  d_current_day,
  d_current_week,
  d_current_month,
  d_current_quarter,
  d_current_year
) SELECT
  d_date_sk,
  d_date_id,
  d_date,
  d_month_seq,
  d_week_seq,
  d_quarter_seq,
  d_year,
  d_dow,
  d_moy,
  d_dom,
  d_qoy,
  d_fy_year,
  d_fy_quarter_seq,
  d_fy_week_seq,
  d_day_name,
  d_quarter_name,
  d_holiday,
  d_weekend,
  d_following_holiday,
  d_first_dom,
  d_last_dom,
  d_same_day_ly,
  d_same_day_lq,
  d_current_day,
  d_current_week,
  d_current_month,
  d_current_quarter,
  d_current_year
FROM tpcds.sf1.date_dim
ORDER BY d_date_sk;

INSERT INTO household_demographics (
  hd_demo_sk,
  hd_income_band_sk,
  hd_buy_potential,
  hd_dep_count,
  hd_vehicle_count
) SELECT
  hd_demo_sk,
  hd_income_band_sk,
  hd_buy_potential,
  hd_dep_count,
  hd_vehicle_count
FROM tpcds.sf1.household_demographics
ORDER BY hd_demo_sk;

INSERT INTO income_band (
  ib_income_band_sk,
  ib_lower_bound,
  ib_upper_bound
) SELECT
  ib_income_band_sk,
  ib_lower_bound,
  ib_upper_bound
FROM tpcds.sf1.income_band
ORDER BY ib_income_band_sk;

INSERT INTO inventory (
  inv_date_sk,
  inv_item_sk,
  inv_warehouse_sk,
  inv_quantity_on_hand
) SELECT
  inv_date_sk,
  inv_item_sk,
  inv_warehouse_sk,
  inv_quantity_on_hand
FROM tpcds.sf1.inventory
ORDER BY inv_date_sk, inv_item_sk;

INSERT INTO item (
  i_item_sk,
  i_item_id,
  i_rec_start_date,
  i_rec_end_date,
  i_item_desc,
  i_current_price,
  i_wholesale_cost,
  i_brand_id,
  i_brand,
  i_class_id,
  i_class,
  i_category_id,
  i_category,
  i_manufact_id,
  i_manufact,
  i_size,
  i_formulation,
  i_color,
  i_units,
  i_container,
  i_manager_id,
  i_product_name
) SELECT
  i_item_sk,
  i_item_id,
  i_rec_start_date,
  i_rec_end_date,
  i_item_desc,
  i_current_price,
  i_wholesale_cost,
  i_brand_id,
  i_brand,
  i_class_id,
  i_class,
  i_category_id,
  i_category,
  i_manufact_id,
  i_manufact,
  i_size,
  i_formulation,
  i_color,
  i_units,
  i_container,
  i_manager_id,
  i_product_name
FROM tpcds.sf1.item
ORDER BY i_item_sk;

INSERT INTO promotion (
  p_promo_sk,
  p_promo_id,
  p_start_date_sk,
  p_end_date_sk,
  p_item_sk,
  p_cost,
  p_response_target,
  p_promo_name,
  p_channel_dmail,
  p_channel_email,
  p_channel_catalog,
  p_channel_tv,
  p_channel_radio,
  p_channel_press,
  p_channel_event,
  p_channel_demo,
  p_channel_details,
  p_purpose,
  p_discount_active
) SELECT
  p_promo_sk,
  p_promo_id,
  p_start_date_sk,
  p_end_date_sk,
  p_item_sk,
  p_cost,
  p_response_targe,
  p_promo_name,
  p_channel_dmail,
  p_channel_email,
  p_channel_catalog,
  p_channel_tv,
  p_channel_radio,
  p_channel_press,
  p_channel_event,
  p_channel_demo,
  p_channel_details,
  p_purpose,
  p_discount_active
FROM tpcds.sf1.promotion
ORDER BY p_promo_sk;

INSERT INTO reason (
  r_reason_sk,
  r_reason_id,
  r_reason_desc
) SELECT
  r_reason_sk,
  r_reason_id,
  r_reason_desc
FROM tpcds.sf1.reason
ORDER BY r_reason_sk;

INSERT INTO ship_mode (
  sm_ship_mode_sk,
  sm_ship_mode_id,
  sm_type,
  sm_code,
  sm_carrier,
  sm_contract
) SELECT
  sm_ship_mode_sk,
  sm_ship_mode_id,
  sm_type,
  sm_code,
  sm_carrier,
  sm_contract
FROM tpcds.sf1.ship_mode
ORDER BY sm_ship_mode_sk;

INSERT INTO store (
  s_store_sk,
  s_store_id,
  s_rec_start_date,
  s_rec_end_date,
  s_closed_date_sk,
  s_store_name,
  s_number_employees,
  s_floor_space,
  s_hours,
  s_manager,
  s_market_id,
  s_geography_class,
  s_market_desc,
  s_market_manager,
  s_division_id,
  s_division_name,
  s_company_id,
  s_company_name,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip,
  s_country,
  s_gmt_offset,
  s_tax_precentage
) SELECT
  s_store_sk,
  s_store_id,
  s_rec_start_date,
  s_rec_end_date,
  s_closed_date_sk,
  s_store_name,
  s_number_employees,
  s_floor_space,
  s_hours,
  s_manager,
  s_market_id,
  s_geography_class,
  s_market_desc,
  s_market_manager,
  s_division_id,
  s_division_name,
  s_company_id,
  s_company_name,
  s_street_number,
  s_street_name,
  s_street_type,
  s_suite_number,
  s_city,
  s_county,
  s_state,
  s_zip,
  s_country,
  s_gmt_offset,
  s_tax_precentage
FROM tpcds.sf1.store
ORDER BY s_store_sk;

INSERT INTO store_returns (
  sr_returned_date_sk,
  sr_return_time_sk,
  sr_item_sk,
  sr_customer_sk,
  sr_cdemo_sk,
  sr_hdemo_sk,
  sr_addr_sk,
  sr_store_sk,
  sr_reason_sk,
  sr_ticket_number,
  sr_return_quantity,
  sr_return_amt,
  sr_return_tax,
  sr_return_amt_inc_tax,
  sr_fee,
  sr_return_ship_cost,
  sr_refunded_cash,
  sr_reversed_charge,
  sr_store_credit,
  sr_net_loss
) SELECT
  sr_returned_date_sk,
  sr_return_time_sk,
  sr_item_sk,
  sr_customer_sk,
  sr_cdemo_sk,
  sr_hdemo_sk,
  sr_addr_sk,
  sr_store_sk,
  sr_reason_sk,
  sr_ticket_number,
  sr_return_quantity,
  sr_return_amt,
  sr_return_tax,
  sr_return_amt_inc_tax,
  sr_fee,
  sr_return_ship_cost,
  sr_refunded_cash,
  sr_reversed_charge,
  sr_store_credit,
  sr_net_loss
FROM tpcds.sf1.store_returns
ORDER BY sr_returned_date_sk, sr_return_time_sk;

INSERT INTO store_sales (
  ss_sold_date_sk,
  ss_sold_time_sk,
  ss_item_sk,
  ss_customer_sk,
  ss_cdemo_sk,
  ss_hdemo_sk,
  ss_addr_sk,
  ss_store_sk,
  ss_promo_sk,
  ss_ticket_number,
  ss_quantity,
  ss_wholesale_cost,
  ss_list_price,
  ss_sales_price,
  ss_ext_discount_amt,
  ss_ext_sales_price,
  ss_ext_wholesale_cost,
  ss_ext_list_price,
  ss_ext_tax,
  ss_coupon_amt,
  ss_net_paid,
  ss_net_paid_inc_tax,
  ss_net_profit
) SELECT
  ss_sold_date_sk,
  ss_sold_time_sk,
  ss_item_sk,
  ss_customer_sk,
  ss_cdemo_sk,
  ss_hdemo_sk,
  ss_addr_sk,
  ss_store_sk,
  ss_promo_sk,
  ss_ticket_number,
  ss_quantity,
  ss_wholesale_cost,
  ss_list_price,
  ss_sales_price,
  ss_ext_discount_amt,
  ss_ext_sales_price,
  ss_ext_wholesale_cost,
  ss_ext_list_price,
  ss_ext_tax,
  ss_coupon_amt,
  ss_net_paid,
  ss_net_paid_inc_tax,
  ss_net_profit
FROM tpcds.sf1.store_sales
ORDER BY ss_sold_date_sk, ss_sold_time_sk;

INSERT INTO time_dim (
  t_time_sk,
  t_time_id,
  t_time,
  t_hour,
  t_minute,
  t_second,
  t_am_pm,
  t_shift,
  t_sub_shift,
  t_meal_time
) SELECT
  t_time_sk,
  t_time_id,
  t_time,
  t_hour,
  t_minute,
  t_second,
  t_am_pm,
  t_shift,
  t_sub_shift,
  t_meal_time
FROM tpcds.sf1.time_dim
ORDER BY t_time_sk;

INSERT INTO warehouse (
  w_warehouse_sk,
  w_warehouse_id,
  w_warehouse_name,
  w_warehouse_sq_ft,
  w_street_number,
  w_street_name,
  w_street_type,
  w_suite_number,
  w_city,
  w_county,
  w_state,
  w_zip,
  w_country,
  w_gmt_offset
) SELECT
  w_warehouse_sk,
  w_warehouse_id,
  w_warehouse_name,
  w_warehouse_sq_ft,
  w_street_number,
  w_street_name,
  w_street_type,
  w_suite_number,
  w_city,
  w_county,
  w_state,
  w_zip,
  w_country,
  w_gmt_offset
FROM tpcds.sf1.warehouse
ORDER BY w_warehouse_sk;

INSERT INTO web_page (
  wp_web_page_sk,
  wp_web_page_id,
  wp_rec_start_date,
  wp_rec_end_date,
  wp_creation_date_sk,
  wp_access_date_sk,
  wp_autogen_flag,
  wp_customer_sk,
  wp_url,
  wp_type,
  wp_char_count,
  wp_link_count,
  wp_image_count,
  wp_max_ad_count
) SELECT
  wp_web_page_sk,
  wp_web_page_id,
  wp_rec_start_date,
  wp_rec_end_date,
  wp_creation_date_sk,
  wp_access_date_sk,
  wp_autogen_flag,
  wp_customer_sk,
  wp_url,
  wp_type,
  wp_char_count,
  wp_link_count,
  wp_image_count,
  wp_max_ad_count
FROM tpcds.sf1.web_page
ORDER BY wp_web_page_sk;

INSERT INTO web_returns (
  wr_returned_date_sk,
  wr_returned_time_sk,
  wr_item_sk,
  wr_refunded_customer_sk,
  wr_refunded_cdemo_sk,
  wr_refunded_hdemo_sk,
  wr_refunded_addr_sk,
  wr_returning_customer_sk,
  wr_returning_cdemo_sk,
  wr_returning_hdemo_sk,
  wr_returning_addr_sk,
  wr_web_page_sk,
  wr_reason_sk,
  wr_order_number,
  wr_return_quantity,
  wr_return_amt,
  wr_return_tax,
  wr_return_amt_inc_tax,
  wr_fee,
  wr_return_ship_cost,
  wr_refunded_cash,
  wr_reversed_charge,
  wr_account_credit,
  wr_net_loss
) SELECT
  wr_returned_date_sk,
  wr_returned_time_sk,
  wr_item_sk,
  wr_refunded_customer_sk,
  wr_refunded_cdemo_sk,
  wr_refunded_hdemo_sk,
  wr_refunded_addr_sk,
  wr_returning_customer_sk,
  wr_returning_cdemo_sk,
  wr_returning_hdemo_sk,
  wr_returning_addr_sk,
  wr_web_page_sk,
  wr_reason_sk,
  wr_order_number,
  wr_return_quantity,
  wr_return_amt,
  wr_return_tax,
  wr_return_amt_inc_tax,
  wr_fee,
  wr_return_ship_cost,
  wr_refunded_cash,
  wr_reversed_charge,
  wr_account_credit,
  wr_net_loss
FROM tpcds.sf1.web_returns
ORDER BY wr_returned_date_sk, wr_returned_time_sk;

INSERT INTO web_sales (
  ws_sold_date_sk,
  ws_sold_time_sk,
  ws_ship_date_sk,
  ws_item_sk,
  ws_bill_customer_sk,
  ws_bill_cdemo_sk,
  ws_bill_hdemo_sk,
  ws_bill_addr_sk,
  ws_ship_customer_sk,
  ws_ship_cdemo_sk,
  ws_ship_hdemo_sk,
  ws_ship_addr_sk,
  ws_web_page_sk,
  ws_web_site_sk,
  ws_ship_mode_sk,
  ws_warehouse_sk,
  ws_promo_sk,
  ws_order_number,
  ws_quantity,
  ws_wholesale_cost,
  ws_list_price,
  ws_sales_price,
  ws_ext_discount_amt,
  ws_ext_sales_price,
  ws_ext_wholesale_cost,
  ws_ext_list_price,
  ws_ext_tax,
  ws_coupon_amt,
  ws_ext_ship_cost,
  ws_net_paid,
  ws_net_paid_inc_tax,
  ws_net_paid_inc_ship,
  ws_net_paid_inc_ship_tax,
  ws_net_profit
) SELECT
  ws_sold_date_sk,
  ws_sold_time_sk,
  ws_ship_date_sk,
  ws_item_sk,
  ws_bill_customer_sk,
  ws_bill_cdemo_sk,
  ws_bill_hdemo_sk,
  ws_bill_addr_sk,
  ws_ship_customer_sk,
  ws_ship_cdemo_sk,
  ws_ship_hdemo_sk,
  ws_ship_addr_sk,
  ws_web_page_sk,
  ws_web_site_sk,
  ws_ship_mode_sk,
  ws_warehouse_sk,
  ws_promo_sk,
  ws_order_number,
  ws_quantity,
  ws_wholesale_cost,
  ws_list_price,
  ws_sales_price,
  ws_ext_discount_amt,
  ws_ext_sales_price,
  ws_ext_wholesale_cost,
  ws_ext_list_price,
  ws_ext_tax,
  ws_coupon_amt,
  ws_ext_ship_cost,
  ws_net_paid,
  ws_net_paid_inc_tax,
  ws_net_paid_inc_ship,
  ws_net_paid_inc_ship_tax,
  ws_net_profit
FROM tpcds.sf1.web_sales
ORDER BY ws_sold_date_sk, ws_sold_time_sk;

INSERT INTO web_site (
  web_site_sk,
  web_site_id,
  web_rec_start_date,
  web_rec_end_date,
  web_name,
  web_open_date_sk,
  web_close_date_sk,
  web_class,
  web_manager,
  web_mkt_id,
  web_mkt_class,
  web_mkt_desc,
  web_market_manager,
  web_company_id,
  web_company_name,
  web_street_number,
  web_street_name,
  web_street_type,
  web_suite_number,
  web_city,
  web_county,
  web_state,
  web_zip,
  web_country,
  web_gmt_offset,
  web_tax_percentage
) SELECT
  web_site_sk,
  web_site_id,
  web_rec_start_date,
  web_rec_end_date,
  web_name,
  web_open_date_sk,
  web_close_date_sk,
  web_class,
  web_manager,
  web_mkt_id,
  web_mkt_class,
  web_mkt_desc,
  web_market_manager,
  web_company_id,
  web_company_name,
  web_street_number,
  web_street_name,
  web_street_type,
  web_suite_number,
  web_city,
  web_county,
  web_state,
  web_zip,
  web_country,
  web_gmt_offset,
  web_tax_percentage
FROM tpcds.sf1.web_site
ORDER BY web_site_sk;
```

### 2.1.3 Drop Table Statement

```sql
DROP TABLE call_center;
DROP TABLE catalog_page;
DROP TABLE catalog_returns;
DROP TABLE catalog_sales;
DROP TABLE customer;
DROP TABLE customer_address;
DROP TABLE customer_demographics;
DROP TABLE date_dim;
DROP TABLE household_demographics;
DROP TABLE income_band;
DROP TABLE inventory;
DROP TABLE item;
DROP TABLE promotion;
DROP TABLE reason;
DROP TABLE ship_mode;
DROP TABLE store;
DROP TABLE store_returns;
DROP TABLE store_sales;
DROP TABLE time_dim;
DROP TABLE warehouse;
DROP TABLE web_page;
DROP TABLE web_returns;
DROP TABLE web_sales;
DROP TABLE web_site;
```

## 2.2 TPC-H

### 2.2.1 Create Table Statement for Hive

```sql
CREATE TABLE `customer`(
  `c_custkey` INT,
  `c_name` VARCHAR(25),
  `c_address` VARCHAR(40),
  `c_nationkey` INT,
  `c_phone` VARCHAR(15),
  `c_acctbal` DECIMAL(15,2),
  `c_mktsegment` VARCHAR(10),
  `c_comment` VARCHAR(117)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `lineitem`(
  `l_orderkey` BIGINT,
  `l_partkey` INT,
  `l_suppkey` INT,
  `l_linenumber` INT,
  `l_quantity` DECIMAL(15,2),
  `l_extendedprice` DECIMAL(15,2),
  `l_discount` DECIMAL(15,2),
  `l_tax` DECIMAL(15,2),
  `l_returnflag` VARCHAR(1),
  `l_linestatus` VARCHAR(1),
  `l_shipdate` DATE,
  `l_commitdate` DATE,
  `l_receiptdate` DATE,
  `l_shipinstruct` VARCHAR(25),
  `l_shipmode` VARCHAR(10),
  `l_comment` VARCHAR(44)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `nation`(
  `n_nationkey` INT,
  `n_name` VARCHAR(25),
  `n_regionkey` INT,
  `n_comment` VARCHAR(152)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `orders`(
  `o_orderkey` BIGINT,
  `o_custkey` INT,
  `o_orderstatus` VARCHAR(1),
  `o_totalprice` DECIMAL(15,2),
  `o_orderdate` DATE,
  `o_orderpriority` VARCHAR(15),
  `o_clerk` VARCHAR(15),
  `o_shippriority` INT,
  `o_comment` VARCHAR(79)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `part`(
  `p_partkey` INT,
  `p_name` VARCHAR(55),
  `p_mfgr` VARCHAR(25),
  `p_brand` VARCHAR(10),
  `p_type` VARCHAR(25),
  `p_size` INT,
  `p_container` VARCHAR(10),
  `p_retailprice` DECIMAL(15,2),
  `p_comment` VARCHAR(23)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `partsupp`(
  `ps_partkey` INT,
  `ps_suppkey` INT,
  `ps_availqty` INT,
  `ps_supplycost` DECIMAL(15,2),
  `ps_comment` VARCHAR(199)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `region`(
  `r_regionkey` INT,
  `r_name` VARCHAR(25),
  `r_comment` VARCHAR(152)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);

CREATE TABLE `supplier`(
  `s_suppkey` INT,
  `s_name` VARCHAR(25),
  `s_address` VARCHAR(40),
  `s_nationkey` INT,
  `s_phone` VARCHAR(15),
  `s_acctbal` DECIMAL(15,2),
  `s_comment` VARCHAR(101)
) STORED AS ORC
TBLPROPERTIES (
    'orc.compression'='LZ4'
);
```

### 2.2.2 Insert Statement

```sql
INSERT INTO customer (
  c_custkey,
  c_name,
  c_address,
  c_nationkey,
  c_phone,
  c_acctbal,
  c_mktsegment,
  c_comment
) SELECT
  custkey,
  name,
  address,
  nationkey,
  phone,
  acctbal,
  mktsegment,
  comment
FROM tpch.sf1.customer;

INSERT INTO lineitem (
  l_orderkey,
  l_partkey,
  l_suppkey,
  l_linenumber,
  l_quantity,
  l_extendedprice,
  l_discount,
  l_tax,
  l_returnflag,
  l_linestatus,
  l_shipdate,
  l_commitdate,
  l_receiptdate,
  l_shipinstruct,
  l_shipmode,
  l_comment
) SELECT
  orderkey,
  partkey,
  suppkey,
  linenumber,
  quantity,
  extendedprice,
  discount,
  tax,
  returnflag,
  linestatus,
  shipdate,
  commitdate,
  receiptdate,
  shipinstruct,
  shipmode,
  comment
FROM tpch.sf1.lineitem;

INSERT INTO nation (
  n_nationkey,
  n_name,
  n_regionkey,
  n_comment
) SELECT
  nationkey,
  name,
  regionkey,
  comment
FROM tpch.sf1.nation;

INSERT INTO orders (
  o_orderkey,
  o_custkey,
  o_orderstatus,
  o_totalprice,
  o_orderdate,
  o_orderpriority,
  o_clerk,
  o_shippriority,
  o_comment
) SELECT
  orderkey,
  custkey,
  orderstatus,
  totalprice,
  orderdate,
  orderpriority,
  clerk,
  shippriority,
  comment
FROM tpch.sf1.orders;

INSERT INTO part (
  p_partkey,
  p_name,
  p_mfgr,
  p_brand,
  p_type,
  p_size,
  p_container,
  p_retailprice,
  p_comment
) SELECT
  partkey,
  name,
  mfgr,
  brand,
  type,
  size,
  container,
  retailprice,
  comment
FROM tpch.sf1.part;

INSERT INTO partsupp (
  ps_partkey,
  ps_suppkey,
  ps_availqty,
  ps_supplycost,
  ps_comment
) SELECT
  partkey,
  suppkey,
  availqty,
  supplycost,
  comment
FROM tpch.sf1.partsupp;

INSERT INTO region (
  r_regionkey,
  r_name,
  r_comment
) SELECT
  regionkey,
  name,
  comment
FROM tpch.sf1.region;

INSERT INTO supplier (
  s_suppkey,
  s_name,
  s_address,
  s_nationkey,
  s_phone,
  s_acctbal,
  s_comment
) SELECT
  suppkey,
  name,
  address,
  nationkey,
  phone,
  acctbal,
  comment
FROM tpch.sf1.supplier;
```

### 2.2.3 Drop Table Statement

```sql
DROP TABLE customer;
DROP TABLE lineitem;
DROP TABLE nation;
DROP TABLE orders;
DROP TABLE part;
DROP TABLE partsupp;
DROP TABLE region;
DROP TABLE supplier;
```

## 2.3 Parquet/Orc Load Related Settings

```sql
SHOW SESSION LIKE '%hive.parquet%';
SHOW SESSION LIKE '%hive.orc%';
```

# 3 Sql

## 3.1 Drop Schema With Everything Contains

```sql
DROP SCHEMA xxx CASCADE;
```
