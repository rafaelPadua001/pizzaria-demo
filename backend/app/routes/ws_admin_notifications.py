from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from ..realtime.connection_manager import manager


router = APIRouter(tags=["Admin Notifications WS"])


@router.websocket("/ws/admin/{restaurant_id}")
async def admin_notifications_ws(websocket: WebSocket, restaurant_id: int) -> None:
    await manager.connect(restaurant_id, websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(restaurant_id, websocket)
    except Exception:
        manager.disconnect(restaurant_id, websocket)
