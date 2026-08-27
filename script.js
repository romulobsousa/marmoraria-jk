/* Marmoraria JK — interações leves, sem dependências */
(function () {
  "use strict";

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

  /* Ponto único para plugar Meta Pixel / Google Ads depois */
  document.querySelectorAll("[data-cta]").forEach(function (el) {
    el.addEventListener("click", function () {
      var origem = el.getAttribute("data-cta");
      if (typeof window.fbq === "function") {
        window.fbq("track", "Contact", { content_name: origem });
      }
      if (typeof window.gtag === "function") {
        window.gtag("event", "contato_whatsapp", { origem: origem });
      }
    });
  });
})();
