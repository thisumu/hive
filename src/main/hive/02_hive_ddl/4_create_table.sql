-- 指定数据存储路径的使用

-- 1、在HDFS上创建/data/目录并将team_ace_player.txt文件上传至该目录下
-- bash: hadoop fs -mkdir /data
-- bash: hadoop fs -put team_ace_player.txt /data

-- 2、切换数据库
use thisumu;

-- 3、建表
create table t_team_ace_player_location(
                                  id int comment "主键",
                                  team_name string comment "战队名称",
                                  ace_player_name string comment "王牌选手名字"
) comment "王者手游主要战队王牌选手信息表" -- 未指定row format语句，采用的是默认的\001作为字段之间的分隔符
location "/data";

-- 4、查看表数据
select * from t_team_ace_player_location;