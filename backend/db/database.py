from sqlalchemy import create_engine, Column, String, Integer, Float, Text, DateTime, Boolean
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from datetime import datetime, timezone
import os
import json

DATABASE_URL = "sqlite:///./datamind_history.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class AnalysisHistory(Base):
    __tablename__ = "analysis_history"

    id = Column(String, primary_key=True)
    data_type = Column(String, nullable=False)
    variable_name = Column(String, default="Variable")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    values_json = Column(Text, nullable=False)
    frequencies_json = Column(Text, nullable=True)
    lower_bounds_json = Column(Text, nullable=True)
    upper_bounds_json = Column(Text, nullable=True)
    x_json = Column(Text, nullable=True)
    y_json = Column(Text, nullable=True)
    result_summary = Column(Text, nullable=False)


Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def save_analysis(db, analysis_id: str, data_type: str, variable_name: str,
                  values: list, result_summary: dict, frequencies=None,
                  lower_bounds=None, upper_bounds=None, x=None, y=None):
    item = AnalysisHistory(
        id=analysis_id,
        data_type=data_type,
        variable_name=variable_name,
        values_json=json.dumps(values),
        frequencies_json=json.dumps(frequencies) if frequencies else None,
        lower_bounds_json=json.dumps(lower_bounds) if lower_bounds else None,
        upper_bounds_json=json.dumps(upper_bounds) if upper_bounds else None,
        x_json=json.dumps(x) if x else None,
        y_json=json.dumps(y) if y else None,
        result_summary=json.dumps(result_summary)
    )
    db.add(item)
    db.commit()
    return item


def get_recent_analyses(db, limit: int = 5):
    items = db.query(AnalysisHistory).order_by(
        AnalysisHistory.created_at.desc()
    ).limit(limit).all()
    return items


def delete_old_analyses(db, keep: int = 5):
    items = db.query(AnalysisHistory).order_by(
        AnalysisHistory.created_at.desc()
    ).offset(keep).all()
    for item in items:
        db.delete(item)
    db.commit()
