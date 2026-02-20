
// Configure aqui o restaurante para reuso em outros clientes
const RESTAURANT_ID = "pizzaria_napoli";
// Endpoint do backend local (troque em producao)
//const CHAT_ENDPOINT = `https://assistant-restaurant.onrender.com/restaurant/${RESTAURANT_ID}/chat`;
const CHAT_ENDPOINT = ` http://127.0.0.1:8000/restaurant/${RESTAURANT_ID}/chat`;

//Config Restaurant - pode ser carregada do backend para manter horarios dinamicos sem precisar atualizar o frontend
const restaurantConfig = {
    opening_hours: {
        start: "18:00",
        end: "23:00"
    }
};


// State do assistente (mantem o contexto da conversa)
let state = {};

// Historico local da conversa (somente no frontend)
const history = [];

// Elementos do DOM
const messagesEl = document.getElementById("pcw-messages");
const inputEl = document.getElementById("pcw-input");
const sendBtn = document.getElementById("pcw-send");
const closeBtn = document.getElementById("pcw-close");
const weekday = [
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
    "friday",
    "saturday",
];

function isRestaurantOpen() {
    if (!restaurantConfig || !restaurantConfig.opening_hours) return true; // Se nao tiver config, assume aberto
    const now = new Date();

    const todayKey = weekday[now.getDay()];
    const todayHours = restaurantConfig.opening_hours[todayKey];
    if (!todayHours) return false;

    const [openStr, closeStr] = todayHours.split("-").map(Number);
    const [closeHour, closeMin] = closeStr.split(":").map(Number);

    const openTime = new Date(now);
    openTime.setHours(openHour, openMin, 0);

    const closeTime = new Date(now);
    closeTime.setHours(closeHour, closeMin, 0);

    if (closeHour === 0) {
        closeTime.setDate(closeTime.getDate() + 1); // Fecha no dia seguinte
    }

    return now >= openTime && now <= closeTime;
}

//Atualiza status badge baseado no horario
function updateStatusBadge() {
    const badge = document.getElementById("pcw-status-message");
    if (!badge) return;
    const isOpen = isRestaurantOpen();
    badge.classList.remove("pcw-open", "pcw-closed");

    if (isOpen) {
        bage.textContent = "🟢 Aberto"
        badge.classList.add("pcw-open");
    }
    else {
        badge.textContent = "🔴 Fechado"
        badge.classList.add("pcw-closed");
    }
}

// Formata linhas de cardapio para exibir nome em destaque e preco/descricao em linhas separadas
function formatAssistantMessage(text) {
    if (!text) return text;

    const lines = text.split(/\r?\n/);
    const itemRegex =
        /^\s*•\s*([^-—]+)\s*[—-]\s*(.+?)\s*\(R\$\s*([\d.,]+)\)\s*[—-]\s*(.+)\s*$/;

    let hasMenuLines = false;
    let output = "";

    for (let i = 0; i < lines.length; i += 1) {
        const line = lines[i];
        const match = line.match(itemRegex);

        if (match) {
            const name = match[2].trim();
            const desc = match[4].trim();
            let price = match[3].trim();

            if (!price.includes(",") && price.includes(".")) {
                price = price.replace(".", ",");
            }

            output += `• <strong>${name}</strong><br>${desc}<br>R$ ${price}<br><br>`;
            hasMenuLines = true;
        } else {
            output += line;
            if (i < lines.length - 1) {
                output += "<br>";
            }
        }
    }

    return hasMenuLines ? output : text;
}

// Sanitiza HTML do assistant permitindo apenas tags seguras
function sanitizeAssistantHTML(html) {
    const container = document.createElement("div");
    container.innerHTML = html;

    const allowed = new Set(["STRONG", "EM", "BR"]);

    const cleanNode = (node) => {
        for (const child of Array.from(node.childNodes)) {
            if (child.nodeType === Node.ELEMENT_NODE) {
                if (!allowed.has(child.tagName)) {
                    // Substitui tag nao permitida pelo texto interno
                    const text = document.createTextNode(child.textContent || "");
                    child.replaceWith(text);
                    continue;
                }
                // Remove atributos de tags permitidas
                for (const attr of Array.from(child.attributes)) {
                    child.removeAttribute(attr.name);
                }
                cleanNode(child);
            }
        }
    };

    cleanNode(container);
    return container.innerHTML;
}

// Envia mensagens pre-definidas para facilitar testes
function sendQuick(text) {
    //addMessage("user", text);
    inputEl.value = text;
    sendMessage();
}

function updateHelpers(state) {
    const finishBtn = document.querySelector("#btn-finalizar");

    finishBtn.style.display = state && state.cart && state.cart.length > 0 ? "inline-block" : "none";
}

// Adiciona uma mensagem no painel
function addMessage(sender, text) {
    const msg = document.createElement("div");
    msg.className = `pcw-msg ${sender}`;
    if (sender === "assistant") {
        const formatted = formatAssistantMessage(text);
        msg.innerHTML = sanitizeAssistantHTML(formatted);
    } else {
        msg.textContent = text;
    }
    messagesEl.appendChild(msg);

    history.push({ sender, text });
    scrollToBottom();
}

// Adiciona botao do WhatsApp, se vier na resposta
function addWhatsAppButton(link) {
    const wrap = document.createElement("div");
    wrap.className = "pcw-whatsapp";

    const a = document.createElement("a");
    a.href = link;
    a.target = "_blank";
    a.rel = "noopener noreferrer";
    a.textContent = "Falar no WhatsApp";

    wrap.appendChild(a);
    messagesEl.appendChild(wrap);
    scrollToBottom();
}

// Mantem o scroll no final da conversa
function scrollToBottom() {
    messagesEl.scrollTop = messagesEl.scrollHeight;
}

// Envia mensagem para o backend
async function sendMessage() {
    const text = inputEl.value.trim();
    if (!text) return;

    addMessage("user", text);
    inputEl.value = "";
    inputEl.focus();

    sendBtn.disabled = true;

    try {
        const response = await fetch(CHAT_ENDPOINT, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ message: text, state }),
        });
        const data = await response.json();

        if (!response.ok) {
            if (data && data.message) {
                addMessage("assistant", data?.message || "Erro inesperado. Tente novamente.");
                return;
            }
            return;
            // throw new Error(`HTTP ${response.status}`);
        }


        // Atualiza o state do assistente
        if (data && data.state !== undefined) {
            state = data.state;
        }

        // atualiza status do badge ao carregar página
        await isRestaurantOpen();
        updateStatusBadge();
        updateHelpers(data.state);


        // Renderiza a resposta do assistente
        const assistantText =
            data.response || data.message || data.reply || "Ok! Posso ajudar em mais algo?";
        addMessage("assistant", assistantText);

        // Se vier link do WhatsApp, mostra o botao
        if (data && data.whatsapp_link) {
            addWhatsAppButton(data.whatsapp_link);
        }
    } catch (err) {
        console.error("Erro no chat:", err);
        addMessage("assistant", "Erro ao conectar com o chat. Tente novamente em instantes.");
    } finally {
        sendBtn.disabled = false;
    }
}

// Eventos de envio
sendBtn.addEventListener("click", sendMessage);
inputEl.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
        e.preventDefault();
        sendMessage();
    }
});

// Fecha o widget (pode recarregar a pagina para reabrir)
closeBtn.addEventListener("click", () => {
    const widget = document.getElementById("pizza-chat-widget");
    if (widget) widget.style.display = "none";
});

// Mensagem inicial opcional
addMessage("assistant", "Ola! Posso ajudar com seu pedido?");
