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
const WHATSAPP_NUMBER = "556191865680";
const STORE_ADDRESS = "QMS 19 Rua 11 Casa 17 Setor de Mansoes - Sobradinho2 - DF";
const STORE_LOCATION = {
  lat:  -15.6333,
  lon: -47.82787
};
const VALOR_POR_KM = 4.99;

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
  const initBrandLogo = () => {
    document.querySelectorAll(".site-brand").forEach((brand) => {
      const logo = brand.querySelector(".site-brand-logo");
      const text = brand.querySelector(".site-brand-text");
      if (!logo || !text) return;

      const showLogo = () => {
        logo.style.display = "inline-block";
        text.style.display = "none";
      };

      const showText = () => {
        logo.style.display = "none";
        text.style.display = "inline-block";
      };

      if (logo.complete) {
        if (logo.naturalWidth > 0) {
          showLogo();
        } else {
          showText();
        }
        return;
      }

      logo.addEventListener("load", showLogo, { once: true });
      logo.addEventListener("error", showText, { once: true });
    });
  };

  initBrandLogo();
  updateCartBadge();
  renderCartUI();

  const pageCategory = (() => {
    const headerTitle = document.querySelector(".pizza-page-header h1");
    if (headerTitle && headerTitle.textContent) {
      return headerTitle.textContent.trim();
    }
    return "Cardápio";
  })();

  const parsePrice = (priceText) => {
    if (!priceText) return 0;
    const normalized = priceText.replace(/[^\d,]/g, "").replace(",", ".");
    return Number(normalized || 0);
  };

  const makeIdFromName = (name, category) => {
    const base = `${category}-${name}`
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "");
    return base || `item-${Date.now()}`;
  };

  const bindCatalogCards = () => {
    const cards = document.querySelectorAll(".pizza-card");
    if (!cards.length) return;

    cards.forEach(card => {
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
          const name = card.querySelector(".pizza-title")?.textContent?.trim() || "Item";
          const description = card.querySelector(".pizza-ingredients")?.textContent?.trim() || "";
          const priceText = card.querySelector(".pizza-price")?.textContent || "0";
          const image = card.querySelector(".pizza-image")?.getAttribute("src") || "";
          const quantity = Math.max(1, Number(qtyValue?.textContent || 1));
          const price = parsePrice(priceText);

          const product = {
            id: makeIdFromName(name, pageCategory),
            nome: name,
            categoria: pageCategory,
            descricao: description,
            preco: price,
            quantidade: quantity,
            imagem: image
          };

          // Adiciona respeitando quantidade escolhida
          const cart = getCart();
          const existing = cart.find(item => item.id === product.id);
          if (existing) {
            existing.quantidade = Math.max(1, existing.quantidade + quantity);
          } else {
            cart.push(product);
          }
          saveCart(cart);
          openCart();
        });
      }
    });
  };

  bindCatalogCards();

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

      closeCart();
      window.location.href = getCheckoutUrl();
    });
  }
});

window.addEventListener("storage", (event) => {
  if (event.key === CART_KEY) {
    notifyCartUpdated();
  }
});

/* ===== CHECKOUT ===== */
const CHECKOUT_KEY = "checkout_data";

const getCheckoutData = () => {
  try {
    const raw = localStorage.getItem(CHECKOUT_KEY);
    return raw ? JSON.parse(raw) : {};
  } catch (error) {
    return {};
  }
};

const saveCheckoutData = (data) => {
  localStorage.setItem(CHECKOUT_KEY, JSON.stringify(data || {}));
};

const calculateDistanceKm = (lat1, lon1, lat2, lon2) => {
  const toRad = (value) => (value * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
};

const geocodeAddress = async (address) => {
  if (!address) {
    throw new Error("Endereço vazio");
  }

  const query = encodeURIComponent(address);
  const response = await fetch(`https://nominatim.openstreetmap.org/search?format=json&limit=1&countrycodes=br&q=${query}`, {
    headers: {
      "Accept-Language": "pt-BR"
    }
  });

  if (!response.ok) {
    throw new Error("Falha ao consultar o endereço");
  }

  const data = await response.json();
  if (!data || !data.length) {
    throw new Error("Endereço não encontrado");
  }

  return {
    lat: Number(data[0].lat),
    lon: Number(data[0].lon)
  };
};

const calculateDeliveryDistance = async (address, cep) => {
  const fullQuery = [address, cep, "Brasil"].filter(Boolean).join(", ");
  let location;
  try {
    location = await geocodeAddress(fullQuery);
  } catch (error) {
    if (cep) {
      location = await geocodeAddress(`${cep}, Brasil`);
    } else {
      throw error;
    }
  }
  const distance = calculateDistanceKm(
    STORE_LOCATION.lat,
    STORE_LOCATION.lon,
    location.lat,
    location.lon
  );
  return Number(distance.toFixed(2));
};

const buildCheckoutMessage = ({ cart, checkoutData, distanceKm, deliveryFee, total }) => {
  const lines = [
    "Pedido - Pizzaria Demo",
    "",
    "Itens:"
  ];

  cart.forEach((item, index) => {
    const subtotal = Number(item.preco || 0) * Number(item.quantidade || 0);
    lines.push(
      `${index + 1}. ${item.nome}`,
      `Qtd: ${item.quantidade} | PreÃ§o: ${formatBRL(item.preco)} | Subtotal: ${formatBRL(subtotal)}`
    );
  });

  lines.push("");
  lines.push(`Total dos produtos: ${formatBRL(calculateTotal())}`);
  lines.push(`DistÃ¢ncia: ${distanceKm} km`);
  lines.push(`Entrega: ${formatBRL(deliveryFee)}`);
  lines.push(`Total geral: ${formatBRL(total)}`);
  lines.push("");
  lines.push("EndereÃ§o de entrega:");
  lines.push(`${checkoutData.nome || "Cliente"}`);
  lines.push(`${checkoutData.endereco || ""}`);
  lines.push(`CEP: ${checkoutData.cep || ""}`);
  if (checkoutData.complemento) {
    lines.push(`Complemento: ${checkoutData.complemento}`);
  }
  lines.push("");
  lines.push(`Origem: ${STORE_ADDRESS}`);

  return encodeURIComponent(lines.join("\n"));
};

const initCheckoutPage = () => {
  const itemsEl = document.getElementById("checkoutItems");
  const emptyEl = document.getElementById("checkoutEmpty");
  const subtotalEl = document.getElementById("checkoutSubtotal");
  const distanceEl = document.getElementById("checkoutDistance");
  const deliveryEl = document.getElementById("checkoutDelivery");
  const totalEl = document.getElementById("checkoutTotal");
  const confirmBtn = document.getElementById("checkoutConfirm");
  const form = document.getElementById("checkoutForm");
  const checkoutErrorEl = document.getElementById("checkoutError");
  const deliveryLoadingEl = document.getElementById("checkoutDeliveryLoading");
  let lastDelivery = {
    addressKey: "",
    distanceKm: 0,
    deliveryFee: 0
  };

  if (!itemsEl || !emptyEl || !subtotalEl || !distanceEl || !deliveryEl || !totalEl || !confirmBtn || !form) {
    return;
  }

  const nameInput = document.getElementById("checkoutName");
  const addressInput = document.getElementById("checkoutAddress");
  const cepInput = document.getElementById("checkoutCep");
  const complementInput = document.getElementById("checkoutComplement");
  const cepLoadingEl = document.getElementById("checkoutCepLoading");
  const addressSection = form.closest(".checkout-section");
  let cepAbortController = null;
  let deliveryDebounceTimer = null;

  const populateForm = () => {
    const data = getCheckoutData();
    if (nameInput) nameInput.value = data.nome || "";
    if (addressInput) addressInput.value = data.endereco || "";
    if (cepInput) cepInput.value = data.cep || "";
    if (complementInput) complementInput.value = data.complemento || "";
  };

  const collectFormData = () => {
    return {
      nome: nameInput?.value?.trim() || "",
      endereco: addressInput?.value?.trim() || "",
      cep: cepInput?.value?.trim() || "",
      complemento: complementInput?.value?.trim() || ""
    };
  };

  const renderCheckout = () => {
    const cart = getCart();
    itemsEl.innerHTML = "";

    if (!cart.length) {
      emptyEl.style.display = "block";
      itemsEl.style.display = "none";
      subtotalEl.textContent = "R$ 0,00";
      distanceEl.textContent = "0 km";
      deliveryEl.textContent = "R$ 0,00";
      totalEl.textContent = "R$ 0,00";
      confirmBtn.disabled = true;
      return;
    }

    emptyEl.style.display = "none";
    itemsEl.style.display = "grid";
    confirmBtn.disabled = false;

    const fragment = document.createDocumentFragment();
    cart.forEach(item => {
      const subtotal = Number(item.preco || 0) * Number(item.quantidade || 0);
      const row = document.createElement("div");
      row.className = "checkout-item";
      row.innerHTML = `
        <div class="checkout-item-title">${item.nome}</div>
        <div class="checkout-item-meta">
          <span>Qtd: ${item.quantidade}</span>
          <span>${formatBRL(item.preco)}</span>
          <strong>${formatBRL(subtotal)}</strong>
        </div>
      `;
      fragment.appendChild(row);
    });
    itemsEl.appendChild(fragment);

    const subtotal = calculateTotal();
    subtotalEl.textContent = formatBRL(subtotal);

    distanceEl.textContent = "0 km";
    deliveryEl.textContent = "R$ 0,00";
    totalEl.textContent = formatBRL(subtotal);
  };

  const handleInput = (event) => {
    saveCheckoutData(collectFormData());
    renderCheckout();
    if (event?.target === cepInput) {
      if (deliveryDebounceTimer) {
        clearTimeout(deliveryDebounceTimer);
      }
      deliveryDebounceTimer = setTimeout(() => {
        calculateDelivery();
      }, 500);
      return;
    }
    calculateDelivery();
  };

  const setDeliveryLoading = (isLoading) => {
    if (deliveryLoadingEl) {
      deliveryLoadingEl.hidden = !isLoading;
    }
  };

  const setCheckoutError = (message) => {
    if (!checkoutErrorEl) return;
    if (message) {
      checkoutErrorEl.textContent = message;
      checkoutErrorEl.hidden = false;
    } else {
      checkoutErrorEl.textContent = "";
      checkoutErrorEl.hidden = true;
    }
  };

  const calculateDelivery = async () => {
    const data = collectFormData();
    if (!data.endereco && !data.cep) {
      setCheckoutError("");
      return;
    }

    try {
      setDeliveryLoading(true);
      setCheckoutError("");
      const distanceKm = await calculateDeliveryDistance(data.endereco, data.cep);
      const deliveryFee = Number((distanceKm * VALOR_POR_KM).toFixed(2));
      const total = calculateTotal() + deliveryFee;

      lastDelivery = {
        addressKey: `${data.endereco || ""}|${data.cep || ""}`,
        distanceKm,
        deliveryFee
      };

      distanceEl.textContent = `${distanceKm} km`;
      deliveryEl.textContent = formatBRL(deliveryFee);
      totalEl.textContent = formatBRL(total);
    } catch (error) {
      distanceEl.textContent = "0 km";
      deliveryEl.textContent = "R$ 0,00";
      totalEl.textContent = formatBRL(calculateTotal());
      setCheckoutError("Não foi possível localizar o endereço. Verifique e tente novamente.");
    } finally {
      setDeliveryLoading(false);
    }
  };

  const fillAddressFromCep = async (cep) => {
    if (!addressInput) return;
    const cleanCep = (cep || "").replace(/\D/g, "");
    if (cleanCep.length !== 8) {
      return;
    }

    try {
      if (addressSection) {
        addressSection.classList.add("is-loading");
      }
      if (cepLoadingEl) {
        cepLoadingEl.hidden = false;
      }
      if (cepAbortController) {
        cepAbortController.abort();
      }
      cepAbortController = new AbortController();

      const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`, {
        signal: cepAbortController.signal
      });
      if (!response.ok) {
        throw new Error("Falha ao buscar CEP");
      }
      const data = await response.json();
      if (data.erro) {
        return;
      }

      const parts = [
        data.logradouro,
        data.bairro,
        data.localidade,
        data.uf
      ].filter(Boolean);

      if (parts.length) {
        addressInput.value = parts.join(", ");
        handleInput();
      }
    } catch (error) {
      if (error.name !== "AbortError") {
        console.warn("NÃ£o foi possÃ­vel buscar o CEP", error);
      }
    } finally {
      if (addressSection) {
        addressSection.classList.remove("is-loading");
      }
      if (cepLoadingEl) {
        cepLoadingEl.hidden = true;
      }
    }
  };

  populateForm();
  renderCheckout();
  calculateDelivery();
  if (cepInput) {
    cepInput.focus();
  }

  form.addEventListener("input", handleInput);
  if (cepInput) {
    cepInput.addEventListener("input", (event) => {
      const value = event.target.value || "";
      fillAddressFromCep(value);
    });
  }

  confirmBtn.addEventListener("click", async () => {
    const cart = getCart();
    if (!cart.length) return;

    const checkoutData = collectFormData();
    if (!checkoutData.nome || !checkoutData.endereco || !checkoutData.cep) {
      form.reportValidity();
      return;
    }

    const addressKey = `${checkoutData.endereco || ""}|${checkoutData.cep || ""}`;
    let distanceKm = lastDelivery.distanceKm;
    let deliveryFee = lastDelivery.deliveryFee;

    if (lastDelivery.addressKey !== addressKey || !distanceKm) {
      try {
        setDeliveryLoading(true);
        setCheckoutError("");
        distanceKm = await calculateDeliveryDistance(checkoutData.endereco, checkoutData.cep);
        deliveryFee = Number((distanceKm * VALOR_POR_KM).toFixed(2));
      } catch (error) {
        setDeliveryLoading(false);
        setCheckoutError("Não foi possível calcular a entrega. Verifique o endereço.");
        return;
      }
    }
    const total = calculateTotal() + deliveryFee;

    const message = buildCheckoutMessage({
      cart,
      checkoutData,
      distanceKm,
      deliveryFee,
      total
    });

    clearCart();
    localStorage.removeItem(CHECKOUT_KEY);
    setDeliveryLoading(false);
    window.location.href = `https://wa.me/${WHATSAPP_NUMBER}?text=${message}`;
  });
};

const getCheckoutUrl = () => {
  const currentPath = window.location.pathname.replace(/\\/g, "/");
  const isInCatalog = currentPath.includes("/catalogo/");
  return isInCatalog ? "checkout.html" : "catalogo/checkout.html";
};

document.addEventListener("DOMContentLoaded", initCheckoutPage);
