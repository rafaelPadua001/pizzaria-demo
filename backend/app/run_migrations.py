import os
import subprocess

print("Running database migrations...")

subprocess.run(
    ["alembic", "upgrade", "head"],
    check=True
)

print("Migrations finished.")