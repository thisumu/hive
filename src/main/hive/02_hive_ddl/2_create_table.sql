-- 二、复杂数据类型使用
-- 有hot_hero_skin_price.txt文件，存放着手游《王者荣耀》热门英雄皮肤及价格等信息
-- 字段含义：id、name（英雄名称）、win_rate（胜率）、skin_price（皮肤及价格）
-- 前3个字段为原生数据类型、最后一个字段为复杂类型map
-- 需要指定字段之间的分隔符、集合元素之间的分隔符、map kv之间的分隔符

-- 1、切花数据库
use thisumu;

-- 2、建表
create table t_hot_hero_skin_price(
    id int comment "主键",
    name string comment "英雄名称",
    win_rate int comment "胜率",
    skin_price map<string, int> comment "皮肤及价格" -- map 复杂数据类型
) comment "热门英雄皮肤及价格"
row format delimited
fields terminated by "," -- 指定字段之间的分隔符
collection items terminated by "-" -- 指定集合元素之间的分隔符
map keys terminated by ":"; -- 指定map元素kv之间的分割符

-- 3、查看表是否建立成功
show tables;

-- 4、将hot_hero_skin_price.txt文件上传至hdfs的/user/hive/warehouse/sumu.db/t_hot_hero_skin_price目录下
-- bash命令：hdfs dfs -put hot_hero_skin_price.txt /user/hive/warehouse/sumu.db/t_hot_hero_skin_price

-- 5、查看表数据
select * from t_hot_hero_skin_price;
