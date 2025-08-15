import aiohttp
import asyncio
from typing import Any, Dict, Tuple

from airflow.triggers.base import BaseTrigger, TriggerEvent

class ApiCheckTrigger(BaseTrigger):
    """
    A trigger that calls a Rest API until a certain status is returned.
    """

    def __init__(self, url:str, expected_status: int):
        super().__init__()
        self.url = url
        self.expected_status = expected_status

    def serialize(self) -> Tuple[str, Dict[str, Any]]:
        return ("custom.triggers.api_check_trigger.ApiCheckTrigger", {"url": self.url, "expected_status": self.expected_status})

    async def run(self):
        """
        Simple time delay loop until the relevant status is found.
        """
        current_status = "Init"
        while self.expected_status != current_status:
            await asyncio.sleep(1)
            async with aiohttp.ClientSession() as session:
                async with session.get(self.url) as response:
                    api_call_result = await response.json()
                    current_status = api_call_result["status"]
        
        # Send our single event and then we're done
        yield TriggerEvent(api_call_result)
