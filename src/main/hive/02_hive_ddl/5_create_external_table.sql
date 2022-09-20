-- 五、内外部表差异学习
-- 什么是内部表？
-- ● 内部表（Internal table）也称为被Hive拥有和管理的托管表（Managed table)。
-- ● 默认情况下创建的表就是内部表，Hive拥有该表的结构和文件。换句话说，Hive完全管理表（元数据和数据）的生命周期，类似于RDBMS中的表。
-- ● 当您删除内部表时，它会删除数据以及表的元数据。

-- 什么是外部表？
-- ● 外部表(External table）中的数据不是Hive拥有或管理的，只管理表元数据的生命周期。
-- ● 要创建一个外部表，需要使用EXTERNAL语法关键字。
-- ● 删除外部表只会删除元数据，而不会删除实际数据。在live外部仍然可以访问实际数据。
-- ● 实际场景中，外部表搭配location语法指定数据的路径，可以让数据更安全。

-- 内外部表差异
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜            ｜内部表、托管表                ｜外部表                            |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜创建方式     ｜默认情况下                   ｜使用EXTERNAL语法关键字              |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜Hive管理范围 ｜元数据、表数据                | 元数据                            |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜删除表结果    ｜删除元数据，删除HDFS上文件数据 ｜只会删除元数据                       |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜操作         ｜支持ARCHIVE， UNARCHIVE    ｜不支持TRUNCATE, MERGE, CONCATENATE |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜事务         ｜支持ACID/事务性             ｜不支持                             |
-- ——————————————————————————————————————————————————————————————————————————————
-- ｜缓存         ｜支持结果缓存                 ｜不支持                            |
-- ——————————————————————————————————————————————————————————————————————————————

-- 如何选择内部表、外部表?
-- ● 需要通过Hive完全管理控制表的整个生命周期时，请使用内部表。
-- ● 当文件已经存在或位于远程位置时，请使用外部表，因为即使删除表，文件也会被保留。

-- 练习：
-- 文件students.txt记录着学生的基本信息，分别建立内部表和外部表并成功映射该文件
-- 进行删除表操作、查看删除后的差异

-- 1、切换数据库
use thisumu;

-- 2、建立内部表（默认情况就是内部表）
create table t_students(
    num int comment "学号",
    name string comment "姓名",
    sex string comment "性别",
    age int comment "年龄",
    dept string comment "院系"
) comment "学生信息表-内部表"
row format delimited
fields terminated by ",";

-- 3、建立外部表
-- 创建外部表 需要关矬字 external
-- 外部表数据存储路经不指定 认期则和内部表一致
-- 也可以使用location关健字指定HDFS任意路径
create external table t_students_ext(
    num int comment "学号",
    name string comment "姓名",
    sex string comment "性别",
    age int comment "年龄",
    dept string comment "院系"
) comment "学生信息表-内部表"
row format delimited
fields terminated by ","
location "/stu";

-- 4、分别查看表的类型
describe formatted t_students;
describe formatted t_students_ext;

-- 5、查看表数据
select * from t_students;
select * from t_students_ext;

-- 6、删除内部表(会发现表被删除，并且hdfs上的文件被连同删除)
drop table t_students;
show tables;

-- 7、删除外部表(会发现表被删除，但hdfs上的文件没有被删除)
drop table t_students_ext;
show tables;