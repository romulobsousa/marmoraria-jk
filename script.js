/* Marmoraria JK — interações leves, sem dependências */
(function () {
  "use strict";

  /* =========================================================
     Rastreamento de conversao — Google Ads
     ---------------------------------------------------------
     A tag AW fica no <head> do index.html. Aqui vai so o que
     dispara quando alguem clica para falar no WhatsApp.

     conversaoWhatsapp: o rotulo da acao de conversao. No Google
     Ads o snippet vem como send_to: 'AW-18133557925/AbC-dEfGhIj'
     — cole aqui SO o que vem depois da barra.
     Enquanto estiver vazio o site funciona normal, so nao
     registra a conversao.
     ========================================================= */
  var ADS = {
    id: "AW-18133557925",
    conversaoWhatsapp: "GkH7CIeH3ukcEKXF4MZD",
    valor: 1.0,
    moeda: "BRL"
  };

  /* Ano no rodapé */
  var ano = document.getElementById("ano");
  if (ano) ano.textContent = new Date().getFullYear();

  /* Sombra no header ao rolar */
  var header = document.querySelector(".site-header");
  function marcarHeader() {
    header.classList.toggle("is-scrolled", window.scrollY > 12);
  }

  /* ---------------------------------------------------------------
     Revelar elementos ao entrar na tela.
     Feito na base de getBoundingClientRect (e não de IntersectionObserver)
     de propósito: um salto de âncora pode fazer o observer nunca registrar
     o elemento como visível, e o conteúdo fica invisível para sempre.
     Aqui a varredura roda a cada rolagem, então não existe estado preso.
  --------------------------------------------------------------- */
  var alvos = [].slice.call(
    document.querySelectorAll(
      ".section-head, .card, .step, .stone, .gal-item, .region, .strip-item, .faq details, .cta-inner"
    )
  );
  alvos.forEach(function (el) {
    el.classList.add("reveal");
  });

  var pendentes = alvos.slice();
  var agendado = false;

  function varrer() {
    agendado = false;
    marcarHeader();

    var limite = window.innerHeight * 0.92;
    var restantes = [];
    var naVez = 0;

    pendentes.forEach(function (el) {
      if (el.getBoundingClientRect().top < limite) {
        if (naVez) el.style.transitionDelay = Math.min(naVez * 60, 240) + "ms";
        el.classList.add("is-visible");
        naVez++;
      } else {
        restantes.push(el);
      }
    });

    pendentes = restantes;
  }

  function pedirVarredura() {
    if (agendado) return;
    agendado = true;
    requestAnimationFrame(varrer);
  }

  window.addEventListener("scroll", pedirVarredura, { passive: true });
  window.addEventListener("resize", pedirVarredura);
  window.addEventListener("hashchange", pedirVarredura);
  window.addEventListener("load", pedirVarredura);
  /* Foto que carrega empurra o conteudo: revarre quando a altura muda */
  document.addEventListener("load", pedirVarredura, true);
  if ("ResizeObserver" in window) {
    new ResizeObserver(pedirVarredura).observe(document.body);
  }
  [100, 400, 900, 1800, 3000].forEach(function (t) {
    setTimeout(pedirVarredura, t);
  });
  varrer();

  /* Rede de seguranca: nada dentro da tela pode continuar invisivel */
  setTimeout(function () {
    if (!pendentes.length) return;
    pendentes.slice().forEach(function (el) {
      if (el.getBoundingClientRect().top < window.innerHeight) {
        el.classList.add("is-visible");
      }
    });
  }, 3500);

  /* Fecha as outras perguntas do FAQ ao abrir uma */
  var faqs = document.querySelectorAll(".faq details");
  faqs.forEach(function (d) {
    d.addEventListener("toggle", function () {
      if (!d.open) return;
      faqs.forEach(function (o) {
        if (o !== d) o.open = false;
      });
    });
  });

  /* Esconde o botão flutuante quando o CTA final está visível (evita sobreposição) */
  var flutuante = document.querySelector(".wa-float");
  var ctaFinal = document.querySelector(".cta");
  if (flutuante && ctaFinal && "IntersectionObserver" in window) {
    new IntersectionObserver(
      function (entries) {
        entries.forEach(function (e) {
          flutuante.style.transition = "opacity .3s ease, transform .25s ease";
          flutuante.style.opacity = e.isIntersecting ? "0" : "1";
          flutuante.style.pointerEvents = e.isIntersecting ? "none" : "auto";
        });
      },
      { threshold: 0.35 }
    ).observe(ctaFinal);
  }

  /* Todo botao de contato dispara os eventos de conversao.
     data-cta diz de qual bloco da pagina veio o clique. */
  document.querySelectorAll("[data-cta]").forEach(function (el) {
    el.addEventListener("click", function () {
      var origem = el.getAttribute("data-cta");

      /* Meta Pixel — passa a valer sozinho se o pixel for colado no <head> */
      try {
        if (typeof window.fbq === "function") {
          window.fbq("track", "Contact", { content_name: origem });
        }
      } catch (e) {}

      if (typeof window.gtag !== "function") return;

      /* Evento nomeado: serve para relatorio e para o GA4, se houver */
      try {
        window.gtag("event", "clique_whatsapp", { origem: origem });
      } catch (e) {}

      /* Conversao do Google Ads — so dispara com o rotulo preenchido */
      try {
        if (ADS.id && ADS.conversaoWhatsapp) {
          window.gtag("event", "conversion", {
            send_to: ADS.id + "/" + ADS.conversaoWhatsapp,
            value: ADS.valor,
            currency: ADS.moeda,
            origem: origem
          });
        }
      } catch (e) {}
    });
  });
})();
