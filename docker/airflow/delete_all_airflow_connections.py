#!/usr/bin/env python
"""
Removing all current airflow connections
"""

from airflow import settings
from airflow.models import Connection

session = settings.Session()
session.query(Connection).delete()
session.commit()
session.close()
exit()
