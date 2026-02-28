async function checkPayment() {
    const urlParams = new URLSearchParams(window.location.search);
    const paymentId = urlParams.get("payment_id");

    if (!paymentId) {
        document.getElementById("payment-result").innerHTML =
            "<h2>Pagamento não encontrado.</h2>";
        return;
    }

    try {
        const response = await fetch(
            `https://pizzaria-demo.onrender.com/payment-status/${paymentId}`
        );

        const data = await response.json();

        renderStatus(data.payment_status);

    } catch (error) {
        document.getElementById("payment-result").innerHTML =
            "<h2>Erro ao verificar pagamento.</h2>";
    }
}

function renderStatus(status) {
    const container = document.getElementById("payment-result");

    if (status === "approved") {
        container.innerHTML = `
            <h1 style="color: green;">Pagamento aprovado ✅</h1>
            <p>Seu pedido foi confirmado.</p>
        `;
    } else if (status === "rejected") {
        container.innerHTML = `
            <h1 style="color: red;">Pagamento não aprovado ❌</h1>
            <p>Tente novamente.</p>
        `;
    } else {
        container.innerHTML = `
            <h1 style="color: orange;">Pagamento pendente ⏳</h1>
            <p>Aguardando confirmação.</p>
        `;
    }
}

checkPayment();