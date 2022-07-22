from datetime import timedelta

from airflow.sensors.base import BaseSensorOperator

from custom.triggers.api_check_trigger import ApiCheckTrigger


class WaitForStartedStatusSensor(BaseSensorOperator):
    def execute(self, context):
        self.defer(trigger=ApiCheckTrigger(url="http://mockserver:1080/testapi", expected_status="Started"), method_name="execute_complete", timeout=timedelta(minutes=2))

    def execute_complete(self, context, event=None):
        # We have no more work to do here. Mark as complete.
        print(event)
        return
