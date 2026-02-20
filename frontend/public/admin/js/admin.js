(() => {
  const API_BASE = "http://127.0.0.1:8000";
  const TOKEN_KEY = "pizzariaAdminToken";

  const loginView = document.getElementById("loginView");
  const appView = document.getElementById("appView");
  const authStatus = document.getElementById("authStatus");
  const loginForm = document.getElementById("loginForm");
  const loginError = document.getElementById("loginError");

  const nav = document.getElementById("adminNav");

  const categoryForm = document.getElementById("categoryForm");
  const categoryError = document.getElementById("categoryError");
  const categoriesList = document.getElementById("categoriesList");
  const refreshCategoriesBtn = document.getElementById("refreshCategories");

  const productForm = document.getElementById("productForm");
  const productError = document.getElementById("productError");
  const productsList = document.getElementById("productsList");
  const refreshProductsBtn = document.getElementById("refreshProducts");

  const ordersList = document.getElementById("ordersList");
  const ordersError = document.getElementById("ordersError");
  const refreshOrdersBtn = document.getElementById("refreshOrders");

  const pageSectionsList = document.getElementById("pageSectionsList");
  const pageSectionError = document.getElementById("pageSectionError");
  const refreshPageSectionsBtn = document.getElementById("refreshPageSections");
  const createPageSectionBtn = document.getElementById("createPageSection");
  const pageSectionModal = document.getElementById("pageSectionModal");
  const pageSectionForm = document.getElementById("pageSectionForm");
  const pageSectionModalTitle = document.getElementById("pageSectionModalTitle");
  const pageSectionModalError = document.getElementById("pageSectionModalError");
  const pageSectionImageInput = document.getElementById("pageSectionImage");
  const pageSectionPreview = document.getElementById("pageSectionPreview");

  const pageForm = document.getElementById("pageForm");
  const pagesList = document.getElementById("pagesList");
  const pagesError = document.getElementById("pagesError");
  const refreshPagesBtn = document.getElementById("refreshPages");

  let categories = [];
  let products = [];
  let pageSections = [];
  let pages = [];

  const setStatus = (text) => {
    authStatus.querySelector("span:last-child").textContent = text;
  };

  const showElement = (el) => {
    if (el) el.hidden = false;
  };

  const hideElement = (el) => {
    if (el) el.hidden = true;
  };

  const setAlert = (el, message) => {
    if (!el) return;
    if (!message) {
      el.textContent = "";
      el.hidden = true;
      return;
    }
    el.textContent = message;
    el.hidden = false;
  };

  const getToken = () => localStorage.getItem(TOKEN_KEY);
  const setToken = (token) => localStorage.setItem(TOKEN_KEY, token);
  const clearToken = () => localStorage.removeItem(TOKEN_KEY);

  const authFetch = (url, options = {}) => {
    const token = getToken();
    if (!token) {
      throw new Error("Token ausente");
    }
    const headers = new Headers(options.headers || {});
    headers.set("Authorization", `Bearer ${token}`);
    const isFormData =
      typeof FormData !== "undefined" && options.body instanceof FormData;
    if (options.body && !headers.has("Content-Type") && !isFormData) {
      headers.set("Content-Type", "application/json");
    }
    const fullUrl = url.startsWith("http") ? url : `${API_BASE}${url}`;
    return fetch(fullUrl, { ...options, headers });
  };

  const handleAuthError = (response) => {
    if (response.status === 401 || response.status === 403) {
      doLogout();
      throw new Error("Sessao expirada. Faca login novamente.");
    }
  };

  const doLogout = () => {
    clearToken();
    hideElement(appView);
    showElement(loginView);
    setStatus("Autenticacao requerida");
  };

  const showApp = () => {
    hideElement(loginView);
    showElement(appView);
    setStatus("Autenticado");
  };

  const setActiveView = (viewName) => {
    document.querySelectorAll("[data-view]").forEach((panel) => {
      if (panel.getAttribute("data-view") === viewName) {
        panel.hidden = false;
      } else if (panel.closest(".admin-content")) {
        panel.hidden = true;
      }
    });

    nav.querySelectorAll(".nav-link").forEach((btn) => {
      if (btn.dataset.view === viewName) {
        btn.classList.add("is-active");
      } else {
        btn.classList.remove("is-active");
      }
    });
  };

  const renderCategories = () => {
    categoriesList.innerHTML = "";
    if (!categories.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhuma categoria cadastrada.";
      categoriesList.appendChild(empty);
      return;
    }

    categories.forEach((section) => {
      const row = document.createElement("div");
      row.className = "list-row";

      const info = document.createElement("div");
      const title = document.createElement("div");
      title.className = "row-title";
      title.textContent = section.name;
      const meta = document.createElement("div");
      meta.className = "row-meta";
      meta.textContent = `Ordem: ${section.order}`;
      info.appendChild(title);
      info.appendChild(meta);

      const actions = document.createElement("div");
      actions.className = "row-actions";
      const editBtn = document.createElement("button");
      editBtn.type = "button";
      editBtn.className = "btn-ghost";
      editBtn.textContent = "Editar";
      editBtn.addEventListener("click", () => fillCategoryForm(section));

      const deleteBtn = document.createElement("button");
      deleteBtn.type = "button";
      deleteBtn.className = "btn-ghost danger";
      deleteBtn.textContent = "Excluir";
      deleteBtn.addEventListener("click", () => deleteCategory(section.id));

      actions.appendChild(editBtn);
      actions.appendChild(deleteBtn);

      row.appendChild(info);
      row.appendChild(actions);
      categoriesList.appendChild(row);
    });
  };

  const renderCategoriesSelect = () => {
    const select = productForm.querySelector("[name='productCategory']");
    select.innerHTML = "";

    if (!categories.length) {
      const option = document.createElement("option");
      option.value = "";
      option.textContent = "Cadastre uma categoria primeiro";
      select.appendChild(option);
      select.disabled = true;
      return;
    }

    select.disabled = false;
    categories.forEach((section) => {
      const option = document.createElement("option");
      option.value = section.id;
      option.textContent = section.name;
      select.appendChild(option);
    });
  };

  const renderProducts = () => {
    productsList.innerHTML = "";
    if (!products.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhum produto cadastrado.";
      productsList.appendChild(empty);
      return;
    }

    const sectionMap = new Map(categories.map((s) => [s.id, s.title || s.name]));

    products.forEach((product) => {
      const row = document.createElement("div");
      row.className = "list-row";

      const info = document.createElement("div");
      const title = document.createElement("div");
      title.className = "row-title";
      title.textContent = product.name;
      info.appendChild(title);

      if (product.description) {
        const desc = document.createElement("div");
        desc.className = "row-desc";
        desc.textContent = product.description;
        info.appendChild(desc);
      }

      const meta = document.createElement("div");
      meta.className = "row-meta";
      const sectionName = sectionMap.get(product.category_id) || "Sem categoria";
      meta.textContent = `Categoria: ${sectionName} | R$ ${Number(product.price).toFixed(2)}`;
      info.appendChild(meta);

      const actions = document.createElement("div");
      actions.className = "row-actions";
      const editBtn = document.createElement("button");
      editBtn.type = "button";
      editBtn.className = "btn-ghost";
      editBtn.textContent = "Editar";
      editBtn.addEventListener("click", () => fillProductForm(product));

      const deleteBtn = document.createElement("button");
      deleteBtn.type = "button";
      deleteBtn.className = "btn-ghost danger";
      deleteBtn.textContent = "Excluir";
      deleteBtn.addEventListener("click", () => deleteProduct(product.id));

      actions.appendChild(editBtn);
      actions.appendChild(deleteBtn);

      row.appendChild(info);
      row.appendChild(actions);
      productsList.appendChild(row);
    });
  };

  const renderOrders = (orders) => {
    ordersList.innerHTML = "";
    if (!orders.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhum pedido encontrado.";
      ordersList.appendChild(empty);
      return;
    }

    const productMap = new Map(products.map((p) => [p.id, p.name]));

    orders.forEach((order) => {
      const card = document.createElement("div");
      card.className = "order-card";

      const header = document.createElement("div");
      header.className = "order-header";

      const title = document.createElement("div");
      title.className = "row-title";
      title.textContent = `Pedido #${order.id}`;

      const meta = document.createElement("div");
      meta.className = "row-meta";
      const date = new Date(order.created_at);
      meta.textContent = `${date.toLocaleString("pt-BR")} | Total R$ ${Number(
        order.total
      ).toFixed(2)}`;

      header.appendChild(title);
      header.appendChild(meta);

      const items = document.createElement("div");
      items.className = "order-items";

      order.items.forEach((item) => {
        const row = document.createElement("div");
        row.className = "order-item";
        const name = productMap.get(item.product_id) || `Produto ${item.product_id}`;
        row.textContent = `${item.quantity}x ${name} - R$ ${Number(item.unit_price).toFixed(2)}`;
        items.appendChild(row);
      });

      card.appendChild(header);
      card.appendChild(items);
      ordersList.appendChild(card);
    });
  };

  const renderPageSections = () => {
    pageSectionsList.innerHTML = "";
    if (!pageSections.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhuma secao cadastrada.";
      pageSectionsList.appendChild(empty);
      return;
    }

    pageSections.forEach((section) => {
      const row = document.createElement("div");
      row.className = "list-row";

      const info = document.createElement("div");
      const title = document.createElement("div");
      title.className = "row-title";
      title.textContent = section.title || section.name;
      const meta = document.createElement("div");
      meta.className = "row-meta";
      meta.textContent = `Nome interno: ${section.name} | Ordem: ${section.order}`;
      info.appendChild(title);
      if (section.subtitle) {
        const desc = document.createElement("div");
        desc.className = "row-desc";
        desc.textContent = section.subtitle;
        info.appendChild(desc);
      }
      info.appendChild(meta);

      const actions = document.createElement("div");
      actions.className = "row-actions";
      const editBtn = document.createElement("button");
      editBtn.type = "button";
      editBtn.className = "btn-ghost";
      editBtn.textContent = "Editar";
      editBtn.addEventListener("click", () => openPageSectionModal(section));

      const deleteBtn = document.createElement("button");
      deleteBtn.type = "button";
      deleteBtn.className = "btn-ghost danger";
      deleteBtn.textContent = "Excluir";
      deleteBtn.addEventListener("click", () => deletePageSection(section.id));

      actions.appendChild(editBtn);
      actions.appendChild(deleteBtn);
      row.appendChild(info);
      row.appendChild(actions);
      pageSectionsList.appendChild(row);
    });
  };

  const renderPages = () => {
    pagesList.innerHTML = "";
    if (!pages.length) {
      const empty = document.createElement("div");
      empty.className = "empty-state";
      empty.textContent = "Nenhuma pagina cadastrada.";
      pagesList.appendChild(empty);
      return;
    }

    pages.forEach((page) => {
      const row = document.createElement("div");
      row.className = "list-row";

      const info = document.createElement("div");
      const title = document.createElement("div");
      title.className = "row-title";
      title.textContent = page.title || page.slug;
      const meta = document.createElement("div");
      meta.className = "row-meta";
      meta.textContent = `Slug: ${page.slug}`;
      info.appendChild(title);
      info.appendChild(meta);

      const actions = document.createElement("div");
      actions.className = "row-actions";
      const editBtn = document.createElement("button");
      editBtn.type = "button";
      editBtn.className = "btn-ghost";
      editBtn.textContent = "Editar";
      editBtn.addEventListener("click", () => fillPageForm(page));

      const deleteBtn = document.createElement("button");
      deleteBtn.type = "button";
      deleteBtn.className = "btn-ghost danger";
      deleteBtn.textContent = "Excluir";
      deleteBtn.addEventListener("click", () => deletePage(page.id));

      actions.appendChild(editBtn);
      actions.appendChild(deleteBtn);
      row.appendChild(info);
      row.appendChild(actions);
      pagesList.appendChild(row);
    });
  };

  const fillCategoryForm = (category) => {
    categoryForm.categoryId.value = category.id;
    categoryForm.categoryName.value = category.name;
    categoryForm.categoryTitle.value = category.title || "";
    categoryForm.categoryDescription.value = category.description || "";
    categoryForm.categoryIcon.value = category.icon || "";
    categoryForm.categoryImageUrl.value = category.image_url || "";
    categoryForm.categorySlug.value = category.slug || "";
    categoryForm.categoryOrder.value = category.order ?? 0;
    categoryForm.categoryActive.value = String(category.is_active);
    categoryForm.querySelector("#categorySubmit").textContent = "Atualizar categoria";
  };

  const resetCategoryForm = () => {
    categoryForm.categoryId.value = "";
    categoryForm.categoryName.value = "";
    categoryForm.categoryTitle.value = "";
    categoryForm.categoryDescription.value = "";
    categoryForm.categoryIcon.value = "";
    categoryForm.categoryImageUrl.value = "";
    categoryForm.categorySlug.value = "";
    categoryForm.categoryOrder.value = "0";
    categoryForm.categoryActive.value = "true";
    categoryForm.querySelector("#categorySubmit").textContent = "Salvar categoria";
  };

  const fillProductForm = (product) => {
    productForm.productId.value = product.id;
    productForm.productName.value = product.name;
    productForm.productDescription.value = product.description || "";
    productForm.productPrice.value = product.price;
    productForm.productCategory.value = String(product.category_id);
    productForm.querySelector("#productSubmit").textContent = "Atualizar produto";
  };

  const resetProductForm = () => {
    productForm.productId.value = "";
    productForm.productName.value = "";
    productForm.productDescription.value = "";
    productForm.productPrice.value = "";
    if (productForm.productImage) {
      productForm.productImage.value = "";
    }
    productForm.querySelector("#productSubmit").textContent = "Salvar produto";
  };

  const fillPageForm = (page) => {
    pageForm.pageId.value = page.id;
    pageForm.pageSlug.value = page.slug;
    pageForm.pageTitle.value = page.title || "";
    pageForm.pageContent.value = page.content || "";
    pageForm.querySelector("#pageSubmit").textContent = "Atualizar pagina";
  };

  const resetPageForm = () => {
    pageForm.pageId.value = "";
    pageForm.pageSlug.value = "";
    pageForm.pageTitle.value = "";
    pageForm.pageContent.value = "";
    pageForm.querySelector("#pageSubmit").textContent = "Salvar pagina";
  };

  const openPageSectionModal = (section = null) => {
    setAlert(pageSectionModalError, "");
    pageSectionForm.pageSectionId.value = section?.id || "";
    pageSectionForm.pageSectionName.value = section?.name || "";
    pageSectionForm.pageSectionTitle.value = section?.title || "";
    pageSectionForm.pageSectionSubtitle.value = section?.subtitle || "";
    pageSectionForm.pageSectionContent.value = section?.content || "";
    pageSectionForm.pageSectionLink.value = section?.link || "";
    pageSectionForm.pageSectionOrder.value = section?.order ?? 0;
    pageSectionForm.pageSectionImageUrl.value = section?.image_url || "";
    const rawImageUrl = typeof section?.image_url === "string" ? section.image_url : "";
    const previewUrl = rawImageUrl
      ? rawImageUrl.startsWith("http")
        ? rawImageUrl
        : `${API_BASE}${rawImageUrl}`
      : "";
    pageSectionPreview.innerHTML = previewUrl
      ? `<img src="${previewUrl}" alt="preview">`
      : "";
    pageSectionModalTitle.textContent = section ? "Editar secao" : "Nova secao";
    showElement(pageSectionModal);
  };

  const closePageSectionModal = () => {
    hideElement(pageSectionModal);
  };

  const uploadImage = async (file) => {
    const formData = new FormData();
    formData.append("file", file);
    const response = await authFetch("/admin/upload", {
      method: "POST",
      body: formData,
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro no upload.");
    }
    const data = await response.json();
    if (!data?.url) {
      throw new Error("Resposta invalida do upload.");
    }
    return data.url;
  };

  const loadCategories = async () => {
    setAlert(categoryError, "");
    const response = await authFetch("/admin/categories");
    handleAuthError(response);
    categories = await response.json();
    renderCategories();
    renderCategoriesSelect();
  };

  const loadProducts = async () => {
    setAlert(productError, "");
    const response = await authFetch("/products");
    handleAuthError(response);
    products = await response.json();
    renderProducts();
  };

  const loadOrders = async () => {
    setAlert(ordersError, "");
    const response = await authFetch("/orders");
    handleAuthError(response);
    const data = await response.json();
    renderOrders(data);
  };

  const loadPageSections = async () => {
    setAlert(pageSectionError, "");
    const response = await authFetch("/admin/sections");
    handleAuthError(response);
    pageSections = await response.json();
    renderPageSections();
  };

  const loadPages = async () => {
    setAlert(pagesError, "");
    const response = await authFetch("/admin/pages");
    handleAuthError(response);
    pages = await response.json();
    renderPages();
  };

  const createCategory = async (payload) => {
    const response = await authFetch("/admin/categories", {
      method: "POST",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao criar categoria.");
    }
  };

  const updateCategory = async (categoryId, payload) => {
    const response = await authFetch(`/admin/categories/${categoryId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao atualizar categoria.");
    }
  };

  const deleteCategory = async (categoryId) => {
    if (!confirm("Deseja remover esta categoria?")) return;
    const response = await authFetch(`/admin/categories/${categoryId}`, { method: "DELETE" });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      setAlert(categoryError, data?.detail || "Erro ao remover categoria.");
      return;
    }
    await loadCategories();
  };

  const createProduct = async (payload) => {
    const response = await authFetch("/products", {
      method: "POST",
      body: payload,
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao criar produto.");
    }
  };

  const updateProduct = async (productId, payload) => {
    const response = await authFetch(`/products/${productId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao atualizar produto.");
    }
  };

  const deleteProduct = async (productId) => {
    if (!confirm("Deseja remover este produto?")) return;
    const response = await authFetch(`/products/${productId}`, { method: "DELETE" });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      setAlert(productError, data?.detail || "Erro ao remover produto.");
      return;
    }
    await loadProducts();
  };

  const createPageSection = async (payload) => {
    const response = await authFetch("/admin/sections", {
      method: "POST",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao criar secao.");
    }
  };

  const updatePageSection = async (sectionId, payload) => {
    const response = await authFetch(`/admin/sections/${sectionId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao atualizar secao.");
    }
  };

  const deletePageSection = async (sectionId) => {
    if (!confirm("Deseja remover esta secao?")) return;
    const response = await authFetch(`/admin/sections/${sectionId}`, { method: "DELETE" });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      setAlert(pageSectionError, data?.detail || "Erro ao remover secao.");
      return;
    }
    await loadPageSections();
  };

  const createPage = async (payload) => {
    const response = await authFetch("/admin/pages", {
      method: "POST",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao criar pagina.");
    }
  };

  const updatePage = async (pageId, payload) => {
    const response = await authFetch(`/admin/pages/${pageId}`, {
      method: "PUT",
      body: JSON.stringify(payload),
    });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      throw new Error(data?.detail || "Erro ao atualizar pagina.");
    }
  };

  const deletePage = async (pageId) => {
    if (!confirm("Deseja remover esta pagina?")) return;
    const response = await authFetch(`/admin/pages/${pageId}`, { method: "DELETE" });
    handleAuthError(response);
    if (!response.ok) {
      const data = await response.json().catch(() => null);
      setAlert(pagesError, data?.detail || "Erro ao remover pagina.");
      return;
    }
    await loadPages();
  };

  loginForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    setAlert(loginError, "");
    const formData = new FormData(loginForm);
    const payload = {
      username: formData.get("username"),
      password: formData.get("password"),
    };

    try {
      const response = await fetch(`${API_BASE}/auth/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error("Credenciais invalidas.");
      }

      const data = await response.json();
      setToken(data.access_token);
      showApp();
      setActiveView("page-sections");
      await Promise.all([
        loadPageSections(),
        loadCategories(),
        loadProducts(),
        loadOrders(),
        loadPages(),
      ]);
    } catch (error) {
      setAlert(loginError, error.message || "Erro no login.");
    }
  });

  categoryForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    setAlert(categoryError, "");
    const categoryId = categoryForm.categoryId.value;
    const payload = {
      name: categoryForm.categoryName.value.trim(),
      title: categoryForm.categoryTitle.value.trim() || null,
      description: categoryForm.categoryDescription.value.trim() || null,
      icon: categoryForm.categoryIcon.value.trim() || null,
      image_url: categoryForm.categoryImageUrl.value.trim() || null,
      slug: categoryForm.categorySlug.value.trim(),
      order: Number(categoryForm.categoryOrder.value || 0),
      is_active: categoryForm.categoryActive.value === "true",
    };

    try {
      if (categoryId) {
        await updateCategory(categoryId, payload);
      } else {
        await createCategory(payload);
      }
      resetCategoryForm();
      await loadCategories();
    } catch (error) {
      setAlert(categoryError, error.message || "Erro ao salvar categoria.");
    }
  });

  document.getElementById("categoryCancel").addEventListener("click", () => {
    resetCategoryForm();
  });

  productForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    setAlert(productError, "");
    const productId = productForm.productId.value;
    const name = productForm.productName.value.trim();
    const description = productForm.productDescription.value.trim();
    const price = Number(productForm.productPrice.value);
    const categoryId = Number(productForm.productCategory.value);
    const imageFile = productForm.productImage?.files?.[0];

    try {
      if (productId) {
        const payload = {
          name,
          description,
          price,
          category_id: categoryId,
        };
        await updateProduct(productId, payload);
      } else {
        const formData = new FormData();
        formData.append("name", name);
        formData.append("description", description);
        formData.append("price", String(price));
        formData.append("category_id", String(categoryId));
        if (imageFile) {
          formData.append("image", imageFile);
        }
        await createProduct(formData);
      }
      resetProductForm();
      await loadProducts();
      await loadOrders();
    } catch (error) {
      setAlert(productError, error.message || "Erro ao salvar produto.");
    }
  });

  document.getElementById("productCancel").addEventListener("click", () => {
    resetProductForm();
  });

  pageForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    setAlert(pagesError, "");
    const pageId = pageForm.pageId.value;
    const payload = {
      slug: pageForm.pageSlug.value.trim(),
      title: pageForm.pageTitle.value.trim(),
      content: pageForm.pageContent.value.trim(),
    };

    try {
      if (pageId) {
        await updatePage(pageId, payload);
      } else {
        await createPage(payload);
      }
      resetPageForm();
      await loadPages();
    } catch (error) {
      setAlert(pagesError, error.message || "Erro ao salvar pagina.");
    }
  });

  document.getElementById("pageCancel").addEventListener("click", () => {
    resetPageForm();
  });

  pageSectionForm.addEventListener("submit", async (event) => {
    event.preventDefault();
    setAlert(pageSectionModalError, "");
    const sectionId = pageSectionForm.pageSectionId.value;
    const payload = {
      name: pageSectionForm.pageSectionName.value.trim(),
      title: pageSectionForm.pageSectionTitle.value.trim(),
      subtitle: pageSectionForm.pageSectionSubtitle.value.trim(),
      content: pageSectionForm.pageSectionContent.value.trim(),
      image_url: pageSectionForm.pageSectionImageUrl.value.trim(),
      link: pageSectionForm.pageSectionLink.value.trim(),
      order: Number(pageSectionForm.pageSectionOrder.value || 0),
    };

    try {
      if (sectionId) {
        await updatePageSection(sectionId, payload);
      } else {
        await createPageSection(payload);
      }
      closePageSectionModal();
      await loadPageSections();
    } catch (error) {
      setAlert(pageSectionModalError, error.message || "Erro ao salvar secao.");
    }
  });

  pageSectionImageInput.addEventListener("change", async (event) => {
    const file = event.target.files?.[0];
    if (!file) return;
    setAlert(pageSectionModalError, "");
    try {
      const url = await uploadImage(file);
      pageSectionForm.pageSectionImageUrl.value = url;
      pageSectionPreview.innerHTML = `<img src="${API_BASE}${url}" alt="preview">`;
    } catch (error) {
      setAlert(pageSectionModalError, error.message || "Erro no upload.");
    }
  });

  document.querySelectorAll("[data-modal-close]").forEach((btn) => {
    btn.addEventListener("click", () => closePageSectionModal());
  });

  createPageSectionBtn.addEventListener("click", () => openPageSectionModal());
  refreshPageSectionsBtn.addEventListener("click", () => loadPageSections());
  refreshCategoriesBtn.addEventListener("click", () => loadCategories());
  refreshProductsBtn.addEventListener("click", () => loadProducts());
  refreshOrdersBtn.addEventListener("click", () => loadOrders());
  refreshPagesBtn.addEventListener("click", () => loadPages());

  nav.addEventListener("click", (event) => {
    const target = event.target.closest(".nav-link");
    if (!target) return;
    const view = target.dataset.view;
    if (view) {
      setActiveView(view);
    }
    if (target.dataset.action === "logout") {
      doLogout();
    }
  });

  document.querySelectorAll("[data-action='logout']").forEach((btn) => {
    btn.addEventListener("click", () => doLogout());
  });

  const bootstrap = async () => {
    if (getToken()) {
      try {
        showApp();
        setActiveView("page-sections");
        await Promise.all([
          loadPageSections(),
          loadCategories(),
          loadProducts(),
          loadOrders(),
          loadPages(),
        ]);
        return;
      } catch (error) {
        doLogout();
      }
    }
    showElement(loginView);
    hideElement(appView);
  };

  bootstrap();
})();
