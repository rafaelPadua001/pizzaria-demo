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
