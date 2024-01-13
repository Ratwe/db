/* 1. Инструкция SELECT, использующая предикат сравнения */
select * from match
where dataversion >= 5.0;

/* 2. Инструкция SELECT, использующая предикат BETWEEN */
select * from match
where dataversion between 5.0 and 5.5;

/* 3. Инструкция SELECT, использующая предикат LIKE */
select * from champion
where name like 'a%b%';

/* 4. Инструкция SELECT, использующая предикат IN со вложенным подзапросом */
select * from champion
where name in (select name from champion);

/* 5. Инструкция SELECT, использующая предикат EXISTS со вложенным подзапросом */
select matchid, dataversion from match
where exists(select match.dataversion from match inner join game
    on match.dataversion = game.dataversion);

/* 6. Инструкция SELECT, использующая предикат сравнения с квантором */
select matchid, dataversion from match
where match.dataversion >= ALL (
    select match.dataversion from match);

/* 7. Инструкция SELECT, использующая агрегатные функции в выражениях столбцов */
select avg(wr) as wr
from (select winrate as wr from champion) as info;

/* 8. Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов */
select name,
       (select avg(winrate) from champion
                            where champion.name = name) as avg_wr
from champion
where name like 'a%';

/* 9. Инструкция SELECT, использующая простое выражение CASE */
select champid, cost,
       case cost
            when 5000 then 'high'
            when 3000 then 'medium'
            else 'low'
       end as price
from champion;

/* 10. Инструкция SELECT, использующая поисковое выражение CASE */
select champid, cost,
       case
            when cost > 5000 then 'high'
            when cost > 3000 then 'medium'
            else 'low'
       end as price
from champion;

/* 11. Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT */
select playername, accountlvl as pl
into temp_t
from account;

/* 12. Инструкция SELECT, использующая вложенные корреалированные подзапросы в качестве производных таблиц в предложении FROM */
SELECT *
FROM (SELECT COUNT(*)
     FROM Match AS M
     WHERE M.matchId is not NULL) AS numMatchesAccount;

/* 13. Инстркуция SELECT, использующая вложенные подзапросы с уровнем вложенности 3 */
select matchid, dataversion from match
where dataversion = (select min(G.dataversion)
                     from game as G
                     where G.matches > (select min(G6.players)
                                        from game as G6
                                        where G6.players > 100)
                     );

/* 14. Инстркуция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING */
select champid, cost from champion as na
group by cost, champid;

/* 15. Инстркуция SELECT, консолидирующая данные с помощью предложения GROUP BY и предложения HAVING */
select champid, min(cost) from champion
group by champid
having min(cost) > 1000;

/* 16. Однострочная INSERT, выполняющая вставку в таблицу одной строки значений */
INSERT INTO Game (gameid, gamename, players, matches, dataversion)
VALUES ('12345', 'Example Game', 100, 50, 2.0);


/* 17. Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса */
/*/1* */
insert into account(puuid, playername, lastplayed, sinceplayed)
select (select max(match.matchid)
        from match),
        '17_request',
        (select max(lastplayed) from account),
        (select min(sinceplayed) from account);

/* 18. Простая инструкция UPDATE */
UPDATE account
set playername = '18_request'
where account.puuid = 'd7a3cc8f-8be7-499c-b30b-60cb5fffcb1d';

/* 19. Инструкция UPDATE со скалярным подзапросом в предложении SET */
UPDATE account
set playername = (select min(gamename) from game)
where account.puuid = 'ab8a854d-dc88-43ea-ae68-e2a85b9c76f6';

/* 20. Простая инструкция DELETE */
DELETE from champion
where champion.winrate < 10;

/* 21. Инструкция DELETE со вложенным коррелированным подзапросом в предложении WHERE */
DELETE from champion
where champion.champid in (select champid from champion
                           where winrate > 90);

/* 22. Инструкция SELECT, использующая простое обобщённое табличное выражение */
WITH CTE(names, number) as (
    select name, count(*) as total
    from champion
    group by name)
select * from CTE;

/* 23. Инструкция SELECT, использующая рекурсивное обобщённое табличное выражение */
WITH RECURSIVE REQ_23(champid, name, winrate, lvl) as (
    select champid, name, winrate, 0 as lvl
    from champion
    where winrate > 40
    union all


    select c.champid, c.name, c.winrate, lvl + 1
    from champion as c inner join REQ_23
    on c.winrate > REQ_23.winrate
)

SELECT champid, name, winrate, lvl
FROM REQ_23;

/* 24. Оконные функции. Использование конструкция MIN/MAX/AVG/OVER() */
select matchid, gameduration, gamecreation,
       sum(gameduration) over (partition by gameduration) as rn1
from match;

/* 25. Оконные функции для устранения дублей  */
WITH CTE AS (
    SELECT
        puuid,
        ROW_NUMBER() OVER (PARTITION BY accountlvl ORDER BY accountlvl) AS rn
    FROM account
)
select * from cte
where rn = 2;


