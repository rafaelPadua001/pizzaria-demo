// Carrega conteúdo do admin.json ou localStorage e aplica na landing page.
(() => {
  const STORAGE_KEY = "pizzariaAdminData";

  const safeText = (id, value) => {
    const el = document.getElementById(id);
    if (el && typeof value === "string") {
      el.textContent = value;
    }
  };

  const safeLink = (id, text, href) => {
    const el = document.getElementById(id);
    if (!el) {
      return;
    }
    if (typeof text === "string") {
      el.textContent = text;
    }
    if (typeof href === "string") {
      el.setAttribute("href", href);
    }
  };

  const applyBenefits = (items = []) => {
    const cards = document.querySelectorAll("[data-benefit]");
    items.forEach((item, index) => {
      const card = cards[index];
      if (!card) {
        return;
      }
      const icon = card.querySelector(".benefit-icon");
      const title = card.querySelector(".benefit-title");
      const text = card.querySelector(".benefit-text");

      if (icon && typeof item.icon === "string") {
        icon.textContent = item.icon;
      }
      if (title && typeof item.title === "string") {
        title.textContent = item.title;
      }
      if (text && typeof item.text === "string") {
        text.textContent = item.text;
      }
    });
  };

  const applyData = (data) => {
    if (!data || typeof data !== "object") {
      return;
    }

    if (data.hero) {
      safeText("hero-kicker", data.hero.kicker);
      safeText("hero-title", data.hero.title);
      safeText("hero-subtitle", data.hero.subtitle);
      safeLink("hero-cta", data.hero.ctaText, data.hero.ctaHref);
    }

    if (data.benefits) {
      safeText("benefits-title", data.benefits.title);
      safeText("benefits-subtitle", data.benefits.subtitle);
      applyBenefits(data.benefits.items);
    }

    if (data.app) {
      safeText("app-title", data.app.title);
      safeText("app-text", data.app.text);
    }

    if (data.social) {
      safeText("social-highlight", data.social.highlight);
      safeText("social-trust", data.social.trust);
      const stars = document.getElementById("social-stars");
      if (stars && typeof data.social.stars === "string") {
        stars.textContent = data.social.stars;
      }
    }

    if (data.ctaFinal) {
      safeText("cta-title", data.ctaFinal.title);
      safeText("cta-text", data.ctaFinal.text);
      safeLink("cta-button", data.ctaFinal.buttonText, data.ctaFinal.buttonHref);
    }
  };

  const loadAdminData = async () => {
    const cached = localStorage.getItem(STORAGE_KEY);
    if (cached) {
      try {
        applyData(JSON.parse(cached));
        return;
      } catch (error) {
        console.warn("Cache inválido no localStorage", error);
      }
    }

    try {
      const response = await fetch("admin.json", { cache: "no-store" });
      if (!response.ok) {
        throw new Error("Falha ao carregar admin.json");
      }
      const data = await response.json();
      applyData(data);
    } catch (error) {
      console.warn("Não foi possível carregar admin.json", error);
    }
  };

  loadAdminData();
})();

/* ===== CARRINHO (LOCALSTORAGE) ===== */
// Chave fixa para persistir o carrinho
const CART_KEY = "cart";

// Exemplos de objetos de produto (estrutura esperada)
const exampleProducts = [
  {
    id: "pizza-001",
    nome: "Margherita",
    categoria: "ClÃ¡ssicas",
    descricao: "Molho de tomate, mussarela, manjericÃ£o e azeite.",
    preco: 45.9,
    quantidade: 1,
    imagem: "./assets/pizzas/margherita.jpg"
  },
  {
    id: "pizza-002",
    nome: "Calabresa",
    categoria: "Tradicionais",
    descricao: "Calabresa artesanal, cebola roxa e azeitonas.",
    preco: 49.9,
    quantidade: 1,
    imagem: "./assets/pizzas/calabresa.jpg"
  }
];

// LÃª e valida o carrinho do localStorage
function getCart() {
  try {
    const raw = localStorage.getItem(CART_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch (error) {
    return [];
  }
}

// Salva o carrinho no localStorage
function saveCart(cart) {
  const safeCart = Array.isArray(cart) ? cart : [];
  localStorage.setItem(CART_KEY, JSON.stringify(safeCart));
}

// Adiciona produto ao carrinho (se existir, incrementa quantidade)
function addToCart(product) {
  if (!product || !product.id) {
    return getCart();
  }

  const cart = getCart();
  const existing = cart.find(item => item.id === product.id);

  if (existing) {
    existing.quantidade = Math.max(1, (existing.quantidade || 0) + 1);
  } else {
    const normalizedProduct = {
      id: String(product.id),
      nome: String(product.nome || ""),
      categoria: String(product.categoria || ""),
      descricao: String(product.descricao || ""),
      preco: Number(product.preco || 0),
      quantidade: Math.max(1, Number(product.quantidade || 1)),
      imagem: String(product.imagem || "")
    };
    cart.push(normalizedProduct);
  }

  saveCart(cart);
  return cart;
}

// Remove item do carrinho pelo id
function removeFromCart(id) {
  const cart = getCart().filter(item => item.id !== id);
  saveCart(cart);
  return cart;
}

// Atualiza quantidade; se 0 remove. Quantidade mÃ­nima = 1
function updateQuantity(id, quantity) {
  const cart = getCart();
  const item = cart.find(p => p.id === id);

  if (!item) {
    return cart;
  }

  const nextQuantity = Number(quantity);
  if (Number.isNaN(nextQuantity) || nextQuantity <= 0) {
    return removeFromCart(id);
  }

  item.quantidade = Math.max(1, Math.floor(nextQuantity));
  saveCart(cart);
  return cart;
}

// Limpa todo o carrinho
function clearCart() {
  localStorage.removeItem(CART_KEY);
}

// Calcula o valor total do carrinho
function calculateTotal() {
  return getCart().reduce((total, item) => {
    return total + Number(item.preco || 0) * Number(item.quantidade || 0);
  }, 0);
}

// Soma a quantidade total de itens no carrinho
function getTotalItems() {
  return getCart().reduce((total, item) => {
    return total + Number(item.quantidade || 0);
  }, 0);
}

// Gera mensagem do WhatsApp com itens, subtotais e total (URL encoded)
function generateWhatsAppMessage() {
  const cart = getCart();

  if (!cart.length) {
    return encodeURIComponent("Carrinho vazio.");
  }

  const formatBRL = (value) => {
    return `R$ ${Number(value || 0).toFixed(2).replace(".", ",")}`;
  };

  const lines = [
    "Pedido:",
    ""
  ];

  cart.forEach((item, index) => {
    const quantidade = Number(item.quantidade || 0);
    const preco = Number(item.preco || 0);
    const subtotal = quantidade * preco;

    lines.push(
      `${index + 1}. ${item.nome} (${item.categoria})`,
      `Qtd: ${quantidade} | PreÃ§o: ${formatBRL(preco)} | Subtotal: ${formatBRL(subtotal)}`,
      ""
    );
  });

  lines.push(`Total: ${formatBRL(calculateTotal())}`);

  return encodeURIComponent(lines.join("\n"));
}

/* ===== UI DO CARRINHO ===== */
// Numero do WhatsApp (ajuste se precisar)
const WHATSAPP_NUMBER = "5511999999999";

const formatBRL = (value) => {
  return `R$ ${Number(value || 0).toFixed(2).replace(".", ",")}`;
};

const shortText = (text, limit = 68) => {
  if (!text) return "";
  return text.length > limit ? `${text.slice(0, limit)}...` : text;
};

function updateCartBadge() {
  const badge = document.getElementById("cartBadge");
  if (!badge) return;
  const totalItems = getTotalItems();
  badge.textContent = totalItems;
}

function renderCartUI() {
  const cartItemsEl = document.getElementById("cartItems");
  const cartEmptyEl = document.getElementById("cartEmpty");
  const cartTotalEl = document.getElementById("cartTotal");
  const cartCheckoutEl = document.getElementById("cartCheckout");

  if (!cartItemsEl || !cartEmptyEl || !cartTotalEl || !cartCheckoutEl) {
    return;
  }

  const cart = getCart();
  cartItemsEl.innerHTML = "";

  if (!cart.length) {
    cartEmptyEl.style.display = "block";
    cartItemsEl.style.display = "none";
    cartTotalEl.textContent = "R$ 0,00";
    cartCheckoutEl.disabled = true;
    return;
  }

  cartEmptyEl.style.display = "none";
  cartItemsEl.style.display = "grid";

  const fragment = document.createDocumentFragment();

  cart.forEach(item => {
    const subtotal = Number(item.preco || 0) * Number(item.quantidade || 0);
    const card = document.createElement("div");
    card.className = "cart-item";
    card.dataset.id = item.id;

    card.innerHTML = `
      <img class="cart-item-image" src="${item.imagem}" alt="${item.nome}">
      <div class="cart-item-body">
        <div class="cart-item-title">${item.nome}</div>
        <div class="cart-item-desc">${shortText(item.descricao)}</div>
        <div class="cart-item-meta">
          <span class="cart-item-price">${formatBRL(item.preco)}</span>
          <div class="cart-qty">
            <button class="cart-qty-btn" type="button" data-action="decrease">-</button>
            <input class="cart-qty-input" type="number" min="1" value="${item.quantidade}" data-action="input">
            <button class="cart-qty-btn" type="button" data-action="increase">+</button>
          </div>
        </div>
        <div class="cart-item-footer">
          <span class="cart-item-subtotal">Subtotal: ${formatBRL(subtotal)}</span>
          <button class="cart-remove" type="button" data-action="remove">Remover</button>
        </div>
      </div>
    `;

    fragment.appendChild(card);
  });

  cartItemsEl.appendChild(fragment);
  cartTotalEl.textContent = formatBRL(calculateTotal());
  cartCheckoutEl.disabled = false;
}

function openCart() {
  const drawer = document.getElementById("cartDrawer");
  const overlay = document.getElementById("cartOverlay");
  const button = document.getElementById("cartButton");

  if (!drawer || !overlay || !button) return;

  drawer.classList.add("is-open");
  drawer.setAttribute("aria-hidden", "false");
  overlay.hidden = false;
  button.setAttribute("aria-expanded", "true");
  document.body.style.overflow = "hidden";
}

function closeCart() {
  const drawer = document.getElementById("cartDrawer");
  const overlay = document.getElementById("cartOverlay");
  const button = document.getElementById("cartButton");

  if (!drawer || !overlay || !button) return;

  drawer.classList.remove("is-open");
  drawer.setAttribute("aria-hidden", "true");
  overlay.hidden = true;
  button.setAttribute("aria-expanded", "false");
  document.body.style.overflow = "";
}

function notifyCartUpdated() {
  updateCartBadge();
  renderCartUI();
}

// Garante que a UI atualize sempre que o carrinho mudar
const originalSaveCart = saveCart;
saveCart = function (cart) {
  originalSaveCart(cart);
  notifyCartUpdated();
};

const originalClearCart = clearCart;
clearCart = function () {
  originalClearCart();
  notifyCartUpdated();
};

document.addEventListener("DOMContentLoaded", () => {
  updateCartBadge();
  renderCartUI();

  const cartButton = document.getElementById("cartButton");
  const cartClose = document.getElementById("cartClose");
  const cartOverlay = document.getElementById("cartOverlay");
  const cartItemsEl = document.getElementById("cartItems");
  const cartCheckoutEl = document.getElementById("cartCheckout");

  if (cartButton) {
    cartButton.addEventListener("click", openCart);
  }

  if (cartClose) {
    cartClose.addEventListener("click", closeCart);
  }

  if (cartOverlay) {
    cartOverlay.addEventListener("click", closeCart);
  }

  if (cartItemsEl) {
    cartItemsEl.addEventListener("click", (event) => {
      const action = event.target?.dataset?.action;
      const itemEl = event.target.closest(".cart-item");
      if (!action || !itemEl) return;

      const id = itemEl.dataset.id;
      const cart = getCart();
      const item = cart.find(entry => entry.id === id);
      if (!item) return;

      if (action === "increase") {
        updateQuantity(id, Number(item.quantidade || 0) + 1);
      }

      if (action === "decrease") {
        updateQuantity(id, Number(item.quantidade || 0) - 1);
      }

      if (action === "remove") {
        removeFromCart(id);
      }
    });

    cartItemsEl.addEventListener("change", (event) => {
      const action = event.target?.dataset?.action;
      const itemEl = event.target.closest(".cart-item");
      if (action !== "input" || !itemEl) return;

      const id = itemEl.dataset.id;
      const value = Number(event.target.value || 1);
      updateQuantity(id, value);
    });
  }

  if (cartCheckoutEl) {
    cartCheckoutEl.addEventListener("click", () => {
      const cart = getCart();
      if (!cart.length) return;

      const message = generateWhatsAppMessage();
      clearCart();
      closeCart();
      window.location.href = `https://wa.me/${WHATSAPP_NUMBER}?text=${message}`;
    });
  }
});

window.addEventListener("storage", (event) => {
  if (event.key === CART_KEY) {
    notifyCartUpdated();
  }
});
