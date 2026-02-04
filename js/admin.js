(() => {
  const STORAGE_KEY = "pizzariaAdminData";
  let initialData = null;

  const getFieldValue = (data, path) => {
    return path.split(".").reduce((acc, key) => {
      if (!acc) {
        return acc;
      }
      if (Array.isArray(acc)) {
        return acc[Number(key)];
      }
      return acc[key];
    }, data);
  };

  const setFieldValue = (data, path, value) => {
    const keys = path.split(".");
    let current = data;
    keys.forEach((key, index) => {
      const isLast = index === keys.length - 1;
      const nextKey = keys[index + 1];
      const shouldBeArray = !isLast && Number.isInteger(Number(nextKey));

      if (isLast) {
        if (Array.isArray(current)) {
          current[Number(key)] = value;
        } else {
          current[key] = value;
        }
        return;
      }

      if (Array.isArray(current)) {
        const idx = Number(key);
        if (!current[idx]) {
          current[idx] = shouldBeArray ? [] : {};
        }
        current = current[idx];
      } else {
        if (!current[key]) {
          current[key] = shouldBeArray ? [] : {};
        }
        current = current[key];
      }
    });
  };

  const applyToForm = (data) => {
    document.querySelectorAll("[data-field]").forEach((input) => {
      const field = input.getAttribute("data-field");
      const value = getFieldValue(data, field);
      if (typeof value === "string") {
        input.value = value;
      }
    });
  };

  const readForm = () => {
    const result = structuredClone(initialData || {});
    document.querySelectorAll("[data-field]").forEach((input) => {
      const field = input.getAttribute("data-field");
      setFieldValue(result, field, input.value.trim());
    });
    return result;
  };

  const loadInitialData = async () => {
    try {
      const response = await fetch("admin.json", { cache: "no-store" });
      if (!response.ok) {
        throw new Error("Falha ao carregar admin.json");
      }
      initialData = await response.json();
      const cached = localStorage.getItem(STORAGE_KEY);
      if (cached) {
        try {
          initialData = { ...initialData, ...JSON.parse(cached) };
        } catch (error) {
          console.warn("Cache inválido no localStorage", error);
        }
      }
      applyToForm(initialData);
    } catch (error) {
      console.warn("Não foi possível carregar admin.json", error);
    }
  };

  const handleSave = () => {
    const payload = readForm();
    localStorage.setItem(STORAGE_KEY, JSON.stringify(payload, null, 2));
  };

  const handleCancel = () => {
    if (initialData) {
      applyToForm(initialData);
    }
  };

  document.getElementById("admin-save")?.addEventListener("click", handleSave);
  document.getElementById("admin-cancel")?.addEventListener("click", handleCancel);

  loadInitialData();
})();
