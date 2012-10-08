drop table if exists subreddit;
create table subreddit (
    id integer primary key autoincrement,
    name varchar(21) not null unique, 
    hits int default 0
);

