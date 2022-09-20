-- 一、原生数据类型使用
-- 文件archer.txt中记录了手游《王者荣耀》射手的相关信息，包括生命、物防、物攻等属性信息，其中字段之间的分隔符为制表符\t，要求在Hive中建表映射成功该文件
-- 字段含义：id、name（英雄名称）、hp_max（最大生命）、mp_max（最大法力）、attack_max（最高物攻）、defense_max（最大物防）、attack_range（攻击范围）、role_main（主要定位）、role_assist（次要等位）。
-- 字段都是基本类型、字段顺序需注意一下，字段之间的分隔符是制表符，需要使用row format语法进行指定

-- 1、切换数据库
use thisumu;
-- 2、创建表
create table t_archer(
    id int comment "主键",
    name string comment "英雄名称",
    hp_max int comment "最大生命",
    mp_max int comment "最大法力",
    attack_max int comment "最高物攻",
    defense_max int comment "最大物防",
    attack_range string comment "攻击范围",
    role_main string comment "主要定位",
    role_assist string comment "次要等位"
) comment "王者荣耀射手信息表"
row format delimited
fields terminated by "\t";

-- 3、查看所有表
show tables;

-- 4、将archer.txt文件上传至hdfs的/user/hive/warehouse/sumu.db/t_archer目录下
-- bash命令：hdfs dfs -put archer.txt /user/hive/warehouse/sumu.db/t_archer

-- 5、查看表里的数据
