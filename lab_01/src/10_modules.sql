-- скалярная функция, возвращающая 1
create or replace function one()
returns int as
$$
    select 1 as one;
$$
language SQL;

select one();


-- подставляемая табличная функция
-- возвращает список чемпионов с винрейтом больше среднего значения
create or replace function better_winrate()
returns setof varchar(255) as
$$
    select * from champion
    where winrate > (select avg(winrate) from champion)
    limit 20
$$
language SQL;

select better_winrate();


-- многооператорная табличная функция
-- возвращает список чемпионов с винрейтом от А до B
create or replace function get_between_winrate(A numeric(5, 2), B numeric(5, 2))
returns table
        (
            name    varchar(255),
            winrate numeric(5, 2)
        ) as
$$
    select name, winrate from champion
    where winrate between A and B
    limit 100
$$
language SQL;

select get_between_winrate(0, 20);

-- рекурсивная функция или функция с рекурсивным ОТВ
with recursive count_champs as (
    select 1 as n, winrate
    from champion
    union all
    select n + 1, winrate
    from count_champs
    where count_champs.winrate > (select avg(winrate) from champion)
    and n < 10
)
select * from count_champs;

with recursive countUp as (
    select 1 as n
    union all
    select n + 1 from countUp where n < 10
)
select * from countUp;

-- Хранимая процедура без параметров или с параметрами
-- увеличивает winrate чемпиона на X, если он меньше Y
create or replace procedure up_winrate(X int, Y int)
as
$$

    update champion
    set winrate = winrate + X
    where winrate < Y;

$$
language SQL;

select champid, winrate from champion;

call up_winrate(1, 50);

-- Рекурсивная хранимая процедура или хранимая процедура с рекурсивным ОТВ
create or replace procedure up_winrate_recursive(X int, Y int)
as
$$
begin
    with recursive countUp as (
        select 1 as n
        union all
        select n + 1 from countUp where X < 10
    )
    update champion
    set winrate = winrate + (select n from countUp)
    where winrate < Y;
end
$$
language plpgsql;

-- Хранимая процедура доступа к метаданным
CREATE OR REPLACE PROCEDURE get_table_metadata()
AS
$$
DECLARE
    table_info record;  -- record сохраняет значения переменной
BEGIN
    -- Используем запрос для извлечения списка таблиц
    FOR table_info IN (SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE')
    LOOP
        -- Выводим имя каждой таблицы
        RAISE NOTICE 'Таблица: %', table_info.table_name;
    END LOOP;
END
$$
LANGUAGE plpgsql;

call get_table_metadata();


-- Хранимая процедура с курсором
create procedure get_high_lvl_accounts() as
$$
    declare
        info record;
        mycursor cursor for
            select puuid, accountlvl from account
            where accountlvl > 20
            limit 10;
    begin
        open mycursor;
        loop
            fetch mycursor INTO info;
            exit when not found;
            raise notice 'puuid = %, lvl = %',
                info.puuid, info.accountlvl;
        end loop;
        close mycursor;
    end;
$$
language plpgsql;

drop procedure get_high_lvl_accounts();

call get_high_lvl_accounts();


-- DML триггер AFTER
-- Триггер - процедура особого типа, выполняющая инструкции в ответ на событие.
CREATE OR REPLACE FUNCTION new_champ_inform()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        raise notice 'new champ: %, cost: %', NEW.name, NEW.cost;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER new_champ_inform_trigger
AFTER INSERT ON champion
FOR EACH ROW
EXECUTE PROCEDURE new_champ_inform();

insert into champion (champid, name, gamescount, winrate, cost)
values (4444, 'jin', 0, 0, 4444);

-- DML триггер INSTEAD OF
CREATE OR REPLACE FUNCTION check_new_champ()
RETURNS TRIGGER AS
$$
BEGIN
    IF TG_OP = 'INSERT' THEN
        raise notice 'new champ: %, cost: %, wr: %', NEW.name, NEW.cost, NEW.winrate;
        if NEW.winrate > 0 then
            raise notice 'WR cant be bigger 0! New champ wont be added!';
        end if;
        return NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP VIEW champ_view;
CREATE VIEW champ_view AS
SELECT * FROM champion LIMIT 100;

CREATE TRIGGER check_new_champ_trigger
INSTEAD OF INSERT ON champ_view
FOR EACH ROW
EXECUTE PROCEDURE check_new_champ();

insert into champ_view (champid, name, gamescount, winrate, cost)
values (4449, 'jin', 0, 2, 4444);

select * from account
limit 1;

create or replace procedure delete_account(q_puuid varchar(255))
as
$$
    delete from account
    where account.puuid = q_puuid;
$$
language SQL;

call delete_account('09a84d6e-baac-4361-a237-944c267fe34a');