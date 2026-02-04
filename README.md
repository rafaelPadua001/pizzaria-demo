# Pizzaria Demo

Landing page de pizzaria com área administrativa simples para editar textos e chamadas. O conteúdo pode ser salvo localmente (no navegador) e a página principal lê esses dados para exibição.

## Estrutura

- `index.html`: landing page.
- `admin.html`: painel administrativo.
- `admin.json`: dados base da landing.
- `css/`: estilos da landing e do admin.
- `js/`: scripts para carregar e salvar dados.
- `assets/`: imagens e mockups.

## Requisitos

- Navegador moderno.
- (Opcional) servidor local para evitar restrições de `fetch` em arquivos locais.

## Instalação

1. Clone o repositório ou copie a pasta `pizzaria-demo`.
2. Abra a pasta no seu editor.

## Uso

### Rodando localmente

Recomendado usar um servidor local simples:

```powershell
# PowerShell
cd C:\GitHub\pizzaria-demo
python -m http.server 5500
```

Depois acesse:

- Landing: `http://localhost:5500/index.html`
- Admin: `http://localhost:5500/admin.html`

### Editando conteúdo

1. Abra `admin.html`.
2. Altere os campos.
3. Clique em **Salvar alterações**.

Os dados são gravados no `localStorage` do navegador. A `index.html` sempre tenta ler primeiro do `localStorage` e, se não houver dados salvos, carrega o `admin.json`.

### Atualizando o conteúdo padrão

Para atualizar o conteúdo padrão usado por todos:

1. Edite `admin.json`.
2. (Opcional) limpe o `localStorage` do navegador para ver o conteúdo novo.

## Observações

- Não há backend neste momento. O fluxo é local.
- Se abrir o `index.html` diretamente pelo arquivo (sem servidor), o `fetch` do `admin.json` pode ser bloqueado pelo navegador.
