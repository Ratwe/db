from datetime import datetime

from sqlalchemy import String, DateTime, ForeignKey, Time, create_engine, text, Integer
from sqlalchemy.orm import *

engine = create_engine("postgresql+psycopg2://postgres:postgres@localhost:5000", pool_pre_ping=True)
Session = sessionmaker(bind=engine)
session = Session()
query_text = """select * from staff_io"""


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


def exec_sample():
    with engine.connect() as connection:
        result = connection.execute(text(query_text))
    return result.fetchall()


def exec_sample_orm():
    staff = session.query(Staff).all()
    for s in staff:
        print(s.id, s.fio, s.bd, s.department)


print(exec_sample())
print(exec_sample_orm())
session.close()