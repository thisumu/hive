-- 创建使用Hive事务表
-- 再Hive中创建一张具备事务功能的表，并尝试进行增删改操作
-- 体验一下Hive的增删改操作和mysql比较起来，性能如何

use thisumu;

-- 1、创建普通的表
drop table if exists t_student;
create table t_student(
   num int comment "学号",
   name string comment "姓名",
   sex string comment "性别",
   age int comment "年龄",
   dept string comment "院系"
) comment "学生信息表-内部表"
row format delimited
fields terminated by ",";

-- 加载数据到普通表中
load data local inpath '/home/sumu/data/students.txt' into table t_student;

select * from t_student;
-- 执行更新操作
update t_student set age=25 where num=95001;
-- 会发现报如下错误：
-- [42000][10294] Error while compiling statement: FAILED: SemanticException [Error 10294]: Attempt to do update or delete using transaction manager that does not support these operations

-- Hive 中專务表的创建使用
-- 1、开启事务配置（可以使用set设置当前session生效，也可以配置在hive-site.XmL中）
set hive.support.concurrency = true; --Hive是否支持并发
set hive.enforce.bucketing = true; --从Hive2.0开始不再需要 是否开启分桶功能
set hive.exec.dynamic.partition.mode = nonstrict; --动态分区模式 非严格
set hive.txn.manager = org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
set hive.compactor.initiator.on = true; --是否在Metastore实例上运行启动线程和清理线程
set hive.compactor.worker.threads = 1; --在比metastore实勿上运行多少个压缩程序工作线程。

-- 2、创建Hive事务表
create table t_student_transactional(
    num int comment "学号",
    name string comment "姓名",
    sex string comment "性别",
    age int comment "年龄",
    dept string comment "院系"
)
clustered by (num) into 2 buckets stored as ORC tblproperties ('transactional' = 'true');

insert into table t_student_transactional select * from t_student;

select * from t_student_transactional;

-- 更新测试
update t_student_transactional set age=26 where num=95022;

-- 删除测试
delete from t_student_transactional where num = 95022;
