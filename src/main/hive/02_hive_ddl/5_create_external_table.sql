-- 五、内外部表差异学习
-- 文件students.txt记录着学生的基本信息，分别建立内部表和外部表并成功映射该文件
-- 进行删除表操作、查看删除后的差异

-- 1、切换数据库
use sumu;

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