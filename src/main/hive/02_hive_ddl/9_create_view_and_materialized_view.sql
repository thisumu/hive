-- Hive View 视图相关语法
use thisumu;

-- Hive中有一张真实的基础表t_usa_covid19
select * from t_usa_covid19;

-- 1、创建视图
create view v_usa_covid19 as select count_date, county, state, deaths from t_usa_covid19 limit 5;

-- 是否可以从已有的视图中创建视图？答案是可以的
create view v_usa_covid_from_view as select * from v_usa_covid19 limit 3;

-- 2、显示当前已有的视图
show tables; -- 会显示所有表和视图
show views; -- 只显示视图，Hive v2.2.0后支持

-- 3、视图的查询
select * from v_usa_covid19;
select * from v_usa_covid_from_view;

-- 能否插入数据到视图中呢？
-- 不行，报错:SemanticException [Error 10090]: A view cannot be used as target table for LOAD or INSERT
insert into v_usa_covid19 select count_date, county, state, deaths from t_usa_covid19;

-- 4、查看视图定义
show create table v_usa_covid19;

-- 5、删除视图
drop view v_usa_covid_from_view;

show views;

-- 6、更改视图属性
alter view v_usa_covid19 set TBLPROPERTIES ('comment' = 'This is view');

-- 7、更改视图定义
alter view v_usa_covid19 as select county, deaths from t_usa_covid19 limit 2;
select * from v_usa_covid19;

-- 8、使用视图的好处
-- 8.1、将真实表中特定的列数据提供给用户，保护数据隐私；
-- 通过视图来限制数据访问可以用来保护信息不被随意查询；
create table userinfo(firstname string, lastname string, ssn string, password string);
create view safe_user_info as select firstname, lastname from userinfo;

-- 可以通过where子句限制数据访问，比如，提供一个员工表视图，只暴露来自特定部门的员工信息；
create table employee(firstname string, lastname string, ssn string, password string, department string);
create view java_employee as select firstname, lastname, ssn from employee where department = 'java';

-- 8.2、降低查询复杂度，优化查询语句
-- 使用视图优化嵌套查询
from (
    select * from people join cart
             on (cart.people_id = people.id) where firstname='join'
) a select a.lastname where a.id =3;

-- 把嵌套自查询变成一个视图
create view shorter_join as select * from people join cart on (cart.people_id = people.id) where firstname='join';
-- 基于子视图查询
select lastname from shorter_join where id=3;

-- ------------------------------------- Materialized Views 物化视图 -----------------------------------
-- 1、创建一张事务表
set hive.support.concurrency = true; --Hive是否支持并发
set hive.enforce.bucketing = true; --从Hive2.0开始不再需要 是否开启分桶功能
set hive.exec.dynamic.partition.mode = nonstrict; --动态分区模式 非严格
set hive.txn.manager = org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on = true; --是否在Metastore实例上运行启动线程和清理线程
set hive.compactor.worker.threads = 1; --在比metastore实勿上运行多少个压缩程序工作线程。

-- 2、创建Hive事务表
create table student_trans(
    num int comment "学号",
    name string comment "姓名",
    sex string comment "性别",
    age int comment "年龄",
    dept string comment "院系"
)
clustered by (num) into 2 buckets stored as ORC tblproperties ('transactional' = 'true');

-- 导入数据到student_trans中
insert overwrite table student_trans select * from t_student;

select * from student_trans;

-- 3、对student_trans建立聚合物化视图
create materialized view student_trans_agg as select dept, count(*) as dept_cnt from student_trans group by dept;
-- 注意：这里执行CREATE MATERIALIZED VIEW会启动一个MR对物化视图进行构建
-- 查看数据库中的物化视图
show materialized views;

-- 4、对原始表student_trans查询(可以对比建立物化视图前后查询速度)
-- 由于会命中物化视图，重写query查询物化视图，查询速度会加快（没有启动MR，只是普通的table scan）
select dept, count(*) as dept_cnt from student_trans group by dept;

-- 5、查询执行计划可以发现 查询被自动重写为TableScan alias：thisumu.student_trans_agg
-- 转换成对物化视图的查询 提高了查询效率
explain select dept, count(*) as dept_cnt from student_trans group by dept;

-- 禁用物化视图自动重写(开启：enable)
alter materialized view student_trans_agg disable rewrite;

-- 删除物化视图
drop materialized view student_trans_agg;