#!/usr/bin/env python
"""
Removing all current airflow connections
"""

from airflow.models import Connection
from airflow.utils.db import create_session

with create_session() as session:
    session.query(Connection).delete()
