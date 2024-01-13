CREATE DATABASE mydatabase;

\c mydatabase;

CREATE TABLE IF NOT EXISTS departments (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    "desc" VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS prepods (
    id int PRIMARY KEY,
    fio VARCHAR(255),
    grade INT,
    position VARCHAR(255),
    department_id INT,
    CONSTRAINT fk_department FOREIGN KEY(department_id) REFERENCES departments(id)
);

CREATE TABLE IF NOT EXISTS subjects (
    id INT PRIMARY KEY,
    name VARCHAR(255),
    hours INT,
    sem INT,
    rating INT
);

CREATE TABLE IF NOT EXISTS prepod_subject (
   prepod_id INT,
   subject_id INT,
   PRIMARY KEY (prepod_id, subject_id),
   CONSTRAINT fk_teacher FOREIGN KEY(prepod_id) REFERENCES prepods(id),
   CONSTRAINT fk_subject FOREIGN KEY(subject_id) REFERENCES subjects(id)
);

INSERT INTO departments (id, name, "desc")
SELECT i, 'Кафедра ' || i, 'Описание кафедры ' || i
FROM generate_series(1, 10) s(i);

INSERT INTO prepods (id, fio, grade, position, department_id)
SELECT i, 'Пётр Васильевич ' || i, i % 4, 'Должность ' || i, i % 5 + 1
FROM generate_series(1, 10) s(i);

INSERT INTO subjects (id, name, hours, sem, rating)
SELECT i, 'Предмет ' || i, i * 12, i % 3 + 1, (i * 17 + 55) % 100
FROM generate_series(1, 10) s(i);

INSERT INTO prepod_subject (prepod_id, subject_id)
SELECT i * 3 % 10 + 1, i * 13 % 10
FROM generate_series(1, 10) s(i);

/* Задание №2 */
/* select + between */
select * from subjects
where rating between 30 and 70;

/* select + exists + вложенный коррелированный подзапрос */
select * from prepods
where exists(select prepods.grade
             where prepods.grade <= 1);

/* select + агрегатные функции в выражениях столбцов */
select id, rating from subjects
where rating > (select avg(rating) from subjects);

/* Задание №3 */
/* Создать хранимую процедуру или функцию с входным параметром "имя таблицы",
   которая удаляет дубликаты записей из указанной таблицы в текущей базе данных.*/
CREATE TABLE IF NOT EXISTS duplicates (
   a INT,
   b INT,
   c INT
);

INSERT INTO duplicates (a, b, c)
SELECT i % 3, i % 3 + 1, i % 3 + 2
FROM generate_series(1, 20) s(i);

/* Идея следующая: удалить из переданной таблицы %I все записи, которые различаются идентификаторами.
   a - одна строка таблицы
   b - другая строка таблицы
   (a.*) = (b.*) -> значения строк a и b совпадают
   .ctid - идентификатор строки
   Т.е. если a.ctid != b.ctid -> строки различные
   Знак < ставится для того, чтобы осталась одна дублирующая строка.
   Если оставить != удалятся вообще ВСЕ строки-дубликаты.
 */
CREATE OR REPLACE FUNCTION remove_duplicates(table_name text)
RETURNS VOID AS
$$
BEGIN
    EXECUTE format('DELETE FROM %I a USING %I b ' ||
                   'WHERE a.ctid < b.ctid AND (a.*) = (b.*)',
        table_name, table_name);
END;
$$
LANGUAGE plpgsql;

select remove_duplicates('duplicates');
select * from duplicates;