/* Marmoraria JK — interações leves, sem dependências */
(function () {
  "use strict";

  /* Ano no rodapé */
  var ano = document.getElementById("ano");
  if (ano) ano.textContent = new Date().getFullYear();

  /* Sombra no header ao rolar */
  var header = document.querySelector(".site-header");
  var ticking = false;
  function onScroll() {
    if (ticking) return;
    ticking = true;
    requestAnimationFrame(function () {
      header.classList.toggle("is-scrolled", window.scrollY > 12);
      ticking = false;
    });
  }
  if (header) {
    window.addEventListener("scroll", onScroll, { passive: true });
    onScroll();
  }

  /* Revelar seções ao entrar na tela */
  var alvos = document.querySelectorAll(
    ".section-head, .card, .step, .stone, .gal-item, .region, .strip-item, .faq details, .cta-inner"
  );
  if ("IntersectionObserver" in window) {
    var io = new IntersectionObserver(
      function (entries) {
        entries.forEach(function (e, i) {
          if (!e.isIntersecting) return;
          setTimeout(function () {
            e.target.classList.add("is-visible");
          }, Math.min(i * 60, 240));
          io.unobserve(e.target);
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.08 }
    );
    alvos.forEach(function (el) {
      el.classList.add("reveal");
      io.observe(el);
    });
  }

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
          flutuante.style.opacity = e.isIntersecting ? "0" : "1";
          flutuante.style.pointerEvents = e.isIntersecting ? "none" : "auto";
          flutuante.style.transition = "opacity .3s ease, transform .25s ease";
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
