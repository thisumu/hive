-- 三、默认分隔符的使用
-- 文件team_ace_player.txt中记录了手游《王者荣耀》主要战队内最受欢迎的王牌选手信息，字段之间使用的是\001作为分隔符，要求在Hive中建表并成功映射该文件。
-- 字段含义：id、team_name（战队名称）、ace_player_name（王牌选手名字）
-- 数据都是原生数据类型，且字段之间分隔符为\001，因此在建表的时候可以省去row format语句，因为hive默认的分隔符就是\001

-- 1、切换数据库
use thisumu;

-- 2、建表
create table t_team_ace_player(
    id int comment "主键",
    team_name string comment "战队名称",
    ace_player_name string comment "王牌选手名字"
) comment "王者手游主要战队王牌选手信息表"; -- 未指定row format语句，采用的是默认的\001作为字段之间的分隔符

-- 3、查看表是否建成功
show tables;

-- 4、将team_ace_player.txt文件上传至hdfs的/user/hive/warehouse/thisumu.db/t_team_ace_player目录下
-- ^A分隔符符号\001,使用组合按键“ctrl+V+A”获得
-- bash命令：hdfs dfs -put team_ace_player.txt /user/hive/warehouse/thisumu.db/t_team_ace_player

-- 5、查看表数据
select * from t_team_ace_player;