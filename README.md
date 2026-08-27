# Marmoraria JK — site institucional

Site estático, mobile first, focado em conversão para WhatsApp.
Bancadas em granito, mármore e quartzo em **Curitiba, Fazenda Rio Grande, Araucária e São José dos Pinhais**.

## Stack

HTML + CSS + JavaScript puro. Sem build, sem framework, sem dependência.
Carrega rápido em 4G e roda direto na Vercel como site estático.

## Estrutura

```
.
├── index.html        # página única com todas as seções
├── styles.css        # tema escuro premium, mobile first
├── script.js         # header, reveal, FAQ e hooks de conversão
├── vercel.json       # headers de cache e segurança
├── robots.txt
├── sitemap.xml
└── assets/
    ├── favicon.svg
    └── og-image.png  # imagem de compartilhamento (1200x630)
```

## Rodar localmente

```bash
npx serve .
# ou
python3 -m http.server 8000
```

## Como trocar as informações

| O que | Onde |
|---|---|
| Número de WhatsApp | Procure por `5541999917485` em `index.html` (formato internacional, sem `+`) |
| Telefone exibido | Procure por `(41) 99991-7485` em `index.html` |
| Domínio (SEO, OG, sitemap) | Procure por `marmorariajk.vercel.app` em `index.html`, `robots.txt` e `sitemap.xml` |
| Horário de atendimento | Seção `#contato` e o bloco JSON-LD no `<head>` |
| Cidades atendidas | Seção `#regioes` e `areaServed` no JSON-LD |
| Cores do tema | Bloco `:root` no topo de `styles.css` |

## Como colocar as fotos reais

Na seção `#trabalhos` do `index.html`, troque cada bloco:

```html
<div class="gal-item" data-stone="preto"><span>Bancada de cozinha em granito preto</span></div>
```

por:

```html
<div class="gal-item"><img src="/assets/foto-1.jpg" alt="Bancada de cozinha em granito preto São Gabriel" loading="lazy"><span>Bancada de cozinha em granito preto</span></div>
```

Recomendado: imagens em **.webp** ou **.jpg**, no máximo 1600px de largura e ~250KB cada.
Os mesmos `data-stone` valem para os cards de serviço (`.card-media`) e as amostras (`.swatch`).

## Depoimentos

Existe um modelo comentado no `index.html`, logo abaixo da galeria.
Use **apenas depoimentos reais de clientes reais** — texto inventado além de ser
propaganda enganosa costuma derrubar anúncio no Meta Ads.

## Rastreamento de conversão

Todo botão de contato tem `data-cta="..."`. O `script.js` já dispara:

- `fbq('track','Contact')` se o Meta Pixel estiver na página
- `gtag('event','contato_whatsapp')` se o Google Ads/GA4 estiver na página

Basta colar o script do pixel no `<head>` do `index.html` que o evento passa a ser registrado.

## Deploy

Deploy automático na Vercel a cada `git push` na branch `main`.
