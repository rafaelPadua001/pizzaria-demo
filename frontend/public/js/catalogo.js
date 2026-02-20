(() => {
  const origin = window.location.origin === "null" ? "" : window.location.origin;
  const API_BASE = origin || "http://127.0.0.1:8000";
  const titleEl = document.getElementById("categoryTitle");
  const descEl = document.getElementById("categoryDescription");
  const gridEl = document.getElementById("productsGrid");

  const formatPrice = (value) => {
    return `R$ ${Number(value || 0).toFixed(2).replace(".", ",")}`;
  };

  const resolveImage = (value) => {
    if (!value) return "/assets/hero-pizza.jpg";
    if (value.startsWith("http") || value.startsWith("/")) return value;
    return `/${value}`;
  };

  const getSlug = () => {
    const parts = window.location.pathname.split("/").filter(Boolean);
    return parts[parts.length - 1] || "";
  };

  const setErrorState = (message) => {
    if (titleEl) titleEl.textContent = message;
    if (descEl) descEl.textContent = "Verifique o link e tente novamente.";
    if (gridEl) gridEl.innerHTML = "";
  };

  const bindCardControls = (card, product, categoryLabel) => {
    const qtyValue = card.querySelector(".qty-value");
    const minusBtn = card.querySelector(".qty-btn[aria-label*='Diminuir']");
    const plusBtn = card.querySelector(".qty-btn[aria-label*='Aumentar']");
    const orderBtn = card.querySelector(".pizza-order");

    if (minusBtn && qtyValue) {
      minusBtn.addEventListener("click", () => {
        const current = Number(qtyValue.textContent || 1);
        const next = Math.max(1, current - 1);
        qtyValue.textContent = String(next);
      });
    }

    if (plusBtn && qtyValue) {
      plusBtn.addEventListener("click", () => {
        const current = Number(qtyValue.textContent || 1);
        qtyValue.textContent = String(current + 1);
      });
    }

    if (orderBtn) {
      orderBtn.addEventListener("click", () => {
        const quantity = Math.max(1, Number(qtyValue?.textContent || 1));
        const cart = typeof getCart === "function" ? getCart() : [];
        const payload = {
          id: String(product.id),
          nome: String(product.name || "Item"),
          categoria: String(categoryLabel || "Cardapio"),
          descricao: String(product.description || ""),
          preco: Number(product.price || 0),
          quantidade: quantity,
          imagem: resolveImage(product.image_url),
        };

        const existing = cart.find((item) => item.id === payload.id);
        if (existing) {
          existing.quantidade = Math.max(1, existing.quantidade + quantity);
        } else {
          cart.push(payload);
        }

        if (typeof saveCart === "function") {
          saveCart(cart);
        }

        if (typeof openCart === "function") {
          openCart();
        }
      });
    }
  };

  const renderProducts = (category, products) => {
    if (!gridEl) return;
    gridEl.innerHTML = "";

    if (!products.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhum produto encontrado.";
      gridEl.appendChild(empty);
      return;
    }

    const fragment = document.createDocumentFragment();
    const categoryLabel = category?.title || category?.slug || "Cardapio";

    products.forEach((product) => {
      const card = document.createElement("article");
      card.className = "pizza-card";
      const imageUrl = resolveImage(product.image_url);
      const description = product.description ? `<p class="pizza-ingredients">${product.description}</p>` : "";

      card.innerHTML = `
        <img class="pizza-image" src="${imageUrl}" alt="${product.name}">
        <div class="pizza-body">
          <h2 class="pizza-title">${product.name}</h2>
          ${description}
          <div class="pizza-meta">
            <span class="pizza-price">${formatPrice(product.price)}</span>
            <div class="pizza-qty" aria-label="Quantidade ${product.name}">
              <button class="qty-btn" type="button" aria-label="Diminuir quantidade">-</button>
              <span class="qty-value">1</span>
              <button class="qty-btn" type="button" aria-label="Aumentar quantidade">+</button>
            </div>
          </div>
          <button class="pizza-order" type="button">Pedir</button>
        </div>
      `;

      bindCardControls(card, product, categoryLabel);
      fragment.appendChild(card);
    });

    gridEl.appendChild(fragment);
  };

  const loadCategory = async () => {
    const slug = getSlug();
    if (!slug) {
      setErrorState("Categoria nao encontrada");
      return;
    }

    try {
      const response = await fetch(`${API_BASE}/catalogo/${encodeURIComponent(slug)}`, {
        headers: { Accept: "application/json" },
      });
      if (!response.ok) {
        throw new Error("Categoria nao encontrada");
      }
      const data = await response.json();
      const category = data.category || data;
      const products = Array.isArray(data.products)
        ? data.products
        : Array.isArray(category?.products)
          ? category.products
          : [];
      if (titleEl) titleEl.textContent = category?.title || category?.name || "Categoria";
      if (descEl) descEl.textContent = category?.description || "";
      document.title = `${category?.title || category?.name || "Catalogo"} | Pizzaria Demo`;
      renderProducts(category, products);
    } catch (error) {
      setErrorState("Categoria nao encontrada");
    }
  };

  document.addEventListener("DOMContentLoaded", loadCategory);
})();
