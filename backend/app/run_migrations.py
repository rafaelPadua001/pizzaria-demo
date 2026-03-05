@app.post("/admin/run-migrations")
def run_migrations():
    from alembic.config import Config
    from alembic import command

    alembic_cfg = Config("alembic.ini")
    command.upgrade(alembic_cfg, "head")

    return {"status": "ok"}