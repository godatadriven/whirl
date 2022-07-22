from datetime import timedelta
from typing import Optional

from pendulum import UTC, Date, DateTime, Time

from airflow.plugins_manager import AirflowPlugin
from airflow.timetables.base import DagRunInfo, DataInterval, TimeRestriction, Timetable

import logging
import ephem

log = logging.getLogger(__name__)

class FullMoonTimetable(Timetable):

    def infer_manual_data_interval(self, run_after: DateTime) -> DataInterval:
        previous_full_moon = ephem.previous_full_moon(run_after.end_of('day')).datetime()
        start = DateTime.combine(previous_full_moon.date(), Time.min).replace(tzinfo=UTC)
        log.debug(f"Manual triggered: run_after: {run_after}, start: {start}")
        return DataInterval(start=start, end=(start + timedelta(days=1)))


    def next_dagrun_info(
        self,
        *,
        last_automated_data_interval: Optional[DataInterval],
        restriction: TimeRestriction,
    ) -> Optional[DagRunInfo]:
        if last_automated_data_interval is not None:  # There was a previous run on the regular schedule.
            log.debug(f"There was a previous run at {last_automated_data_interval.start}")
            last_full_moon = last_automated_data_interval.end
            next_full_moon = ephem.next_full_moon(last_full_moon).datetime()
            next_start = DateTime.combine(next_full_moon.date(), Time.min).replace(tzinfo=UTC)
        else:  # This is the first ever run on the regular schedule.
            log.debug(f"There was no previous run. Using earliest possible date {restriction.earliest}")
            last_start = restriction.earliest
            if last_start is None:  # No start_date. Don't schedule.
                return None
            if not restriction.catchup:
                # If the DAG has catchup=False, today is the earliest to consider.
                last_start = max(last_start, DateTime.combine(Date.today(), Time.min).replace(tzinfo=UTC))
            elif last_start.time() != Time.min:
                # If earliest does not fall on midnight, skip to the next day.
                next_day = last_start.date() + timedelta(days=1)
                last_start = DateTime.combine(next_day, Time.min).replace(tzinfo=UTC)
            log.debug(f"Determining next full moon after {last_start}")
            next_full_moon = ephem.next_full_moon(last_start).datetime()
            next_start = DateTime.combine(next_full_moon.date(), Time.min).replace(tzinfo=UTC)
        if restriction.latest is not None and next_start > restriction.latest:
            return None  # Over the DAG's scheduled end; don't schedule.
        return DagRunInfo.interval(start=next_start, end=(next_start + timedelta(days=1)))


class FullMoonTimetablePlugin(AirflowPlugin):
    name = "fullmoon_timetable_plugin"
    timetables = [FullMoonTimetable]
