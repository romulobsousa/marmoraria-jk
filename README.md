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
| Domínio (SEO, OG, sitemap) | Procure por `marmoraria-jk.vercel.app` em `index.html`, `robots.txt` e `sitemap.xml` |
| Horário de atendimento | Seção `#contato` e o bloco JSON-LD no `<head>` |
| Cidades atendidas | Seção `#regioes` e `areaServed` no JSON-LD |
| Cores do tema | Bloco `:root` no topo de `styles.css` |

## Fotos

As fotos ficam em `assets/fotos/`, cada uma em dois formatos: `.webp` (servido a
quem suporta) e `.jpg` (fallback). Os originais ficam em `img/`, que **nao vai
para o repositorio** (esta no `.gitignore`).

Onde cada foto aparece:

| Arquivo | Onde | Formato |
|---|---|---|
| `cozinha-ilha-granito-preto` | card "Cozinhas e areas gourmet" | 1200x540 |
| `banheiro-bancada-travertino` | card "Banheiros e lavabos" | 1200x540 |
| `cozinha-bancada-acabamento` | card "Acabamentos e escadas" | 1200x540 |
| `galeria-ilha-quartzo-branco` | galeria | 1000x1000 |
| `galeria-cozinha-completa` | galeria | 1000x1000 |
| `galeria-banheiro-cuba-apoio` | galeria | 1000x1000 |
| `galeria-lavabo-dourado` | galeria | 1000x1000 |

### Amostras de pedra

As seis amostras da secao "Materiais" ficam em `assets/pedras/`, no mesmo
esquema webp + jpg, em 4:3. Os originais estao em `img/pedras/`.

| Arquivo | Pedra |
|---|---|
| `preto-sao-gabriel` | Granito Preto Sao Gabriel |
| `branco-siena` | Branco Siena |
| `cinza-corumba` | Cinza Corumba |
| `verde-ubatuba` | Verde Ubatuba |
| `marmore-carrara` | Marmore tipo Carrara |
| `quartzo` | Quartzo |

Para trocar ou acrescentar uma pedra:

```bash
cd img/pedras
convert "SUA-PEDRA.jpg" -auto-orient -strip -resize "560x420^" \
  -gravity center -extent 560x420 -quality 72 ../../assets/pedras/NOME.jpg
convert "SUA-PEDRA.jpg" -auto-orient -strip -resize "560x420^" \
  -gravity center -extent 560x420 -quality 62 ../../assets/pedras/NOME.webp
```

Depois copie um bloco `<figure class="stone">` no `index.html`. Mantenha a
frase "As imagens sao ilustrativas" no fim da secao: as fotos mostram o tipo
de pedra, nao a chapa que o cliente vai levar.

### Adicionar uma foto nova na galeria

1. Jogue o original em `img/`
2. Gere os dois formatos (precisa do ImageMagick):

```bash
cd img
convert "SUA-FOTO.jpg" -auto-orient -strip -resize "1000x1000^" \
  -gravity center -extent 1000x1000 -quality 82 ../assets/fotos/NOME.jpg
convert ../assets/fotos/NOME.jpg -quality 78 ../assets/fotos/NOME.webp
```

3. Copie um bloco `<figure class="gal-item">` no `index.html` e troque o nome do
   arquivo, o `alt` e a legenda. Sempre escreva um `alt` que descreva a peca e o
   material - e o que o Google le.

Se a foto sair deitada, acrescente `-rotate 90` ou `-rotate -90` ao primeiro
comando. Se estiver torta, `-rotate 15` (ou outro angulo) resolve, mas corte
depois com `-crop`.

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
