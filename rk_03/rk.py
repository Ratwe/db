from datetime import datetime

from sqlalchemy import String, DateTime, ForeignKey, Time, create_engine, text, Integer, func, and_
from sqlalchemy.orm import *

engine = create_engine("postgresql+psycopg2://postgres:postgres@localhost:5000", pool_pre_ping=True, echo=False)
Session = sessionmaker(bind=engine)
session = Session()

sql_task1 = """with ages(id, age) as (
            select id,date_part('year', age(current_date, bd)) as age
            from staff
            where department = 'ИТ'
        )
        select staff.id, fio
        from staff join ages on staff.id = ages.id
        where ages.age = (select MIN(age) from ages);"""

sql_task2 = """select s.fio from staff as s
        join staff_io as st on st.staff_id = s.id
        where st.date = current_date
        and st.time = (
            select min(time) from staff_io
            where date = current_date
            and type = 1);"""

sql_task3 = """with late(id, fio, late_arrive) as (
    select s.id, s.fio, late_arrive
    from staff as s
    join (select staff_id,
                 date_part('minute', MIN(time) - '9:00') +
                 date_part('hour', MIN(time) - '9:00') * 60 as late_arrive
          from staff_io
          group by staff_id) as st
    on s.id = st.staff_id
    where late_arrive < 10)
select s.id, s.fio
from late as s
where late_arrive < 10;"""


class Base(DeclarativeBase):
    pass


class Staff(Base):
    __tablename__ = "staff"
    id: Mapped[int] = mapped_column(primary_key=True)
    fio: Mapped[str] = mapped_column(String(50))
    bd: Mapped[datetime] = mapped_column(DateTime)
    department: Mapped[str] = mapped_column(String(30))


class StaffIO(Base):
    __tablename__ = "staff_io"
    staff_id: Mapped[int] = mapped_column(ForeignKey("staff.id"), primary_key=True)
    date: Mapped[datetime] = mapped_column(DateTime)
    day: Mapped[str] = mapped_column(String(30))
    time: Mapped[Time] = mapped_column(Time)
    type: Mapped[int] = mapped_column(Integer)


# Найти самого молодого сотрудника в ИТ отделе.
def task1_sql():
    with engine.connect() as connection:
        result = connection.execute(text(sql_task1))
    print(result.fetchall())


def task1_orm():
    ages = session.query(Staff.id,
                         (func.date_part('year', func.current_date()) - func.date_part('year', Staff.bd)).label('age')
                         ).where(Staff.department == 'ИТ').subquery('ages')
    min_age = session.query(func.min(ages.c.age)).scalar_subquery()
    query = session.query(Staff.id, Staff.fio).select_from(ages).filter(ages.c.id == Staff.id).where(
        ages.c.age == min_age)

    for row in query:
        print(row)


# Найти сотрудника, который пришёл сегодня на работу раньше всех
def task2_sql():
    with engine.connect() as connection:
        result = connection.execute(text(sql_task2))
    print(result.fetchall())


def task2_orm():
    min_time_come = session.query(
        func.min(StaffIO.time)
    ).where(and_(
        StaffIO.date == func.current_date(),
        StaffIO.type == 1)
    ).scalar_subquery()
    query = session.query(Staff.id, Staff.fio).join(StaffIO
                                                    ).where(and_(
        StaffIO.date == func.current_date(),
        StaffIO.time == min_time_come
    ))
    for row in query:
        print(row)


# Найти сотрудников, опоздавших сегодня меньше чем на 10 минут
def task3_sql():
    with engine.connect() as connection:
        result = connection.execute(text(sql_task3))
    print(result.fetchall())


def task3_orm():
    late = session.query(
        Staff.id,
        Staff.fio,
        ((func.date_part('minute', func.min(StaffIO.time)) + func.date_part('hour', func.min(StaffIO.time))) * 60
         ).label('late_arrive')
    ).join(StaffIO, Staff.id == StaffIO.staff_id).group_by(Staff.id).subquery('late')

    query = session.query(late.c.id, late.c.fio
                          ).filter(late.c.late_arrive < 10)

    for row in query:
        print(row.id, row.fio)


task1_sql()
task1_orm()
task2_sql()
task2_orm()
task3_sql()
task3_orm()
session.close()
