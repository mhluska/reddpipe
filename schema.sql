drop table if exists subreddits;
create table subreddits (
    id integer primary key autoincrement,
    name varchar(21) not null unique, 
    hits int default 0
);

