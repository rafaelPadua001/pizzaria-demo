from __future__ import annotations

from typing import Dict, List

from fastapi import WebSocket


class ConnectionManager:
    def __init__(self) -> None:
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, restaurant_id: int, websocket: WebSocket) -> None:
        await websocket.accept()
        if restaurant_id not in self.active_connections:
            self.active_connections[restaurant_id] = []
        self.active_connections[restaurant_id].append(websocket)

    def disconnect(self, restaurant_id: int, websocket: WebSocket) -> None:
        connections = self.active_connections.get(restaurant_id)
        if not connections:
            return
        if websocket in connections:
            connections.remove(websocket)
        if not connections:
            self.active_connections.pop(restaurant_id, None)

    async def broadcast(self, restaurant_id: int, message: dict) -> None:
        connections = list(self.active_connections.get(restaurant_id, []))
        for connection in connections:
            try:
                await connection.send_json(message)
            except Exception:
                self.disconnect(restaurant_id, connection)


manager = ConnectionManager()
