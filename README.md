# Pizzaria Demo

Projeto com frontend estatico e backend FastAPI. O admin consome a API com JWT.

## Estrutura

- `frontend/public/index.html`: landing page
- `frontend/admin/admin.html`: painel admin
- `backend/app/main.py`: API FastAPI

## Backend

```powershell
cd C:\GitHub\pizzaria-demo\backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Crie um `.env` com as variaveis do `.env.example`.

## Frontend

```powershell
cd C:\GitHub\pizzaria-demo\backend
.venv\Scripts\activate
uvicorn app.main:app --reload
# Acesse: http://127.0.0.1:8000
```

## Seed admin

```powershell
cd C:\GitHub\pizzaria-demo\backend
python -m app.seed_admin
```

## Seed categorias

```powershell
cd C:\GitHub\pizzaria-demo\backend
python -m app.seed_categories
```

## Admin

Abra `frontend/admin/admin.html` e faca login usando as credenciais do `.env`.

## Observacoes

- Produtos e pedidos sao persistidos no banco via API.
- O admin nao usa JSON local.
