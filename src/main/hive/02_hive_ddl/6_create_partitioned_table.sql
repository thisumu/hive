-- 现有6份数据文件，分别记录了《王者荣耀》中6种位置的英雄相关信息。现要求通过建立一张表t_all_hero，把6份文件同时映射加载

-- 切换数据库
use thisumu;

-- 创建普通表
create table t_all_hero(
    id int,
    name string,
    hp_max int,
    mp_max int,
    attack_max int,
    defense_max int,
    attack_range string,
    role_main string,
    role_assist string
)
row format delimited
fields terminated by "\t";

-- 查看所有表
show tables;

-- 查询表里数据
select * from t_all_hero;

-- 查询hero中主要定位是射手且hp_max最大生命大于6000的有几个
select count(*) from t_all_hero where role_main="archer" and hp_max>6000;

-- -------------------------------- 但分区表学习 -----------------------------

-- 分区表的创建
-- 注意：分区字段不能是表中已经存在的字段，因为分区字段最终也会以虚拟字段的形式显示在表结构上。
create table t_all_hero_tmp(
   id int,
   name string,
   hp_max int,
   mp_max int,
   attack_max int,
   defense_max int,
   attack_range string,
   role_main string,
   role_assist string
)
partitioned by (role string)
row format delimited
fields terminated by "\t" ;

-- 查询会发现表中多了一个虚拟分区字段：role
select * from t_all_hero_tmp;

-- 把6个文件上传到分区表对应的HDFS目录，查看然后表里是否有数据?
-- 查询后会发现表里没有数据，这是因为分区表的数据加载/映射方式不是这样的
select * from t_all_hero_tmp;

-- 创建静态分区表
create table t_all_hero_part(
   id int,
   name string,
   hp_max int,
   mp_max int,
   attack_max int,
   defense_max int,
   attack_range string,
   role_main string,
   role_assist string
)
partitioned by (role string) -- 注意这里是分区字段
row format delimited
fields terminated by "\t" ;

-- 加载数据到表里,本地加载记得加上local关键字
load data local inpath '/home/sumu/data/hero/archer.txt' into table t_all_hero_part partition (role="archer");
load data local inpath '/home/sumu/data/hero/assassin.txt' into table t_all_hero_part partition (role="assassin");
load data local inpath '/home/sumu/data/hero/mage.txt' into table t_all_hero_part partition (role="mage");
load data local inpath '/home/sumu/data/hero/support.txt' into table t_all_hero_part partition (role="support");
load data local inpath '/home/sumu/data/hero/tank.txt' into table t_all_hero_part partition (role="tank");
load data local inpath '/home/sumu/data/hero/warrior.txt' into table t_all_hero_part partition (role="warrior");

select * from t_all_hero_part;

-- 查询hero中主要定位是射手且hp_max最大生命大于6000的有几个
-- 非分区表 全表扫描过滤查询
select count(*) from t_all_hero where role_main="archer" and hp_max>6000;
-- 分区表 先基于分区过滤 再查询
select count(*) from t_all_hero_part where role="archer" and hp_max>6000;


-- --------------------------- 多重分区表学习 -------------------------------
-- 单分区表，按省份分区
create table t_user_province(id int, name string, age int) partitioned by (province string) row format delimited fields terminated by ",";

-- 双分区表，按省份和市分区
-- 分区字段之间是一种递进的关系，因此要注意分区字段的顺序 谁在前谁在后
create table t_user_province_city(id int, name string, age int) partitioned by (province string, city string) row format delimited fields terminated by ",";

-- 三分区表，按省份、市、县分区
create table t_user_province_city_county(id int, name string, age int) partitioned by (province string, city string, county string) row format delimited fields terminated by ",";

show tables;

-- 多分区表的数据插入 静态加载
load data local inpath '/home/sumu/data/user1.txt' into table t_user_province partition (province='shanghai');
load data local inpath '/home/sumu/data/user1.txt' into table t_user_province_city partition (province='zhejiang', city='hangzhou');
load data local inpath '/home/sumu/data/user1.txt' into table t_user_province_city partition (province='zhejiang', city='ningbo');
load data local inpath '/home/sumu/data/user1.txt' into table t_user_province_city partition (province='shanghai', city='pudong');

-- 查询
select * from t_user_province_city where province='zhejiang' and city='hangzhou';


-- -------------------------------- 分区表数据加载————动态分区 ----------------------------------
-- 启用hive动态分区，需要在hive会话中设置两个参数：
-- 1、是否开启动态分区功能
set hive.exec.dynamic.partition=true;

-- 2、指定动态分区模式，分为nonstrict非严格模式和strict严格模式
-- strict严格模式要求至少有一个分区为静态分区
set hive.exec.dynamic.partition.mode=nonstrict;

-- 创建分区表
create table t_all_hero_part_dynamic(
    id int,
    name string,
    hp_max int,
    mp_max int,
    attack_max int,
    defense_max int,
    attack_range string,
    role_main string,
    role_assist string
)
partitioned by (role string) -- 注意这里是分区字段
row format delimited
fields terminated by "\t" ;

select * from t_all_hero;

-- 执行动态分区插入
insert into table t_all_hero_part_dynamic partition (role) -- 注意：分区值并没有手动写死指定
select tmp.*, tmp.role_main from t_all_hero tmp;

select * from t_all_hero_part_dynamic;

-- 分区表的注意事项
-- —、分区表不是建表的必要语法规则，是一种优化手段表，可选；
-- 二、分区字段不能是表中己有的字段，不能重复；
-- 三、分区字段是虚拟字段，其数据并不存储在底层的文件中；
-- 四、分区字段值的确定来自于用户价值数据手动指定（静态分区）或者根据查询结果位置自动推断（动态分区）；
-- 五、Hive支持多重分区，也就是说在分区的基础上继续分区，划分更加细粒度；