"""End-to-end: start the packaged server over stdio and call it as a client."""

import asyncio
import json
import os
import sys

from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

EXPECTED = {"get_entity", "list_people", "get_role", "who_owns", "get_policy", "get_process", "validate_change"}


async def main() -> None:
    params = StdioServerParameters(command=sys.argv[1], env=dict(os.environ))
    async with stdio_client(params) as (read, write):
        async with ClientSession(read, write) as session:
            await session.initialize()
            tools = {t.name for t in (await session.list_tools()).tools}
            assert tools == EXPECTED, tools
            res = await session.call_tool("who_owns", {"target": "acme-example/website:content/legal/x.md"})
            data = json.loads(res.content[0].text)
            assert data["owners"] == ["founder"], data
            res = await session.call_tool("get_entity", {})
            assert json.loads(res.content[0].text)["name"] == "Acme"
    print("smoke: ok")


asyncio.run(main())
