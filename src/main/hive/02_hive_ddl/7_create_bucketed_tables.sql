-- 分桶表的创建

use thisumu;

-- 1、根据state把数据分为5桶，建表语句如下：
create table t_usa_covid19_bucket(
    count_date string,
    county string,
    state string,
    fips int,
    cases int,
    deaths int
)
CLUSTERED BY (state) INTO 5 BUCKETS;

-- 2、在创建分桶表时，还可以指定分桶内的数据排序规则：
create table t_usa_covid19_bucket_sort(
  count_date string,
  county string,
  state string,
  fips int,
  cases int,
  deaths int
)
CLUSTERED BY (state)
sorted by (cases desc ) INTO 5 BUCKETS;

show tables;

-- step1: 开启分桶的功能，从Hive2.0开始不再需要设置
set hive.enforce.bucketing=true;

-- step2: 把源数据加载到普通hive表中
drop table if exists t_usa_covid19;
create table t_usa_covid19(
    count_date string,
    county string,
    state string,
    fips int,
    cases int,
    deaths int
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ",";

-- 将源数据上传到HDFS上t_usa_covid19表对应的路径下
-- bash命令: hadoop fs -put us-covid19-counties.dat /user/hive/warehouse/thisumu.db/t_usa_covid19

select * from t_usa_covid19;

-- step3:使用insert+select语法将数据加载到分桶表中
insert into t_usa_covid19_bucket select * from t_usa_covid19;

select * from t_usa_covid19_bucket;

-- 基于分杨字段state查询来自于New York的数据
-- 不再需要进行全表扫描过滤
-- 根据分杨的期则hash function(New York) mod 5计算出分杨编号
-- 查询指定分杨里面的数据 就可以找出结果 此时是分杨扫描而不是全表扫描
select * from t_usa_covid19_bucket where state="New York";