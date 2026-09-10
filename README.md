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

## Sistema de orçamentos

Painel interno em `/sistema/`, no mesmo domínio do site. Copiado do sistema da
Marcenaria Costa e adaptado: mesma estrutura, textos e papéis da marmoraria,
tema escuro da marca. Não entra no Google (`noindex` + `Disallow` no robots).

Áreas: **Hoje** (resumo do dia), **Orçamentos** (com PDF e envio no WhatsApp),
**Agenda** (visitas), **Equipe** (papéis) e **Histórico** (quem mexeu no quê).
A fila de cobrança do sistema da marcenaria não veio nesta versão.

### Onde ficam os dados

O plano free da Supabase dá duas vagas de projeto, e elas já estavam ocupadas.
Em vez de assinar, a marmoraria divide o projeto da Marcenaria Costa mas mora
num **schema separado, `jk`** — tabelas, numeração, equipe e histórico próprios.
Nada aqui encosta no que já existe no `public` da marcenaria.

Três coisas são compartilhadas com a marcenaria por serem do projeto, não do
schema, e por isso levam nome próprio aqui:

| O quê | Nome na marmoraria |
|---|---|
| Gatilho em `auth.users` | `jk_ao_criar_usuario` |
| Bucket de PDF no Storage | `jk-orcamentos` |
| Políticas em `storage.objects` | prefixadas com `jk:` |

Sem esses nomes próprios, rodar os `.sql` aqui derrubaria o gatilho e as
políticas da marcenaria — os `drop ... if exists` apagam por nome.

Como `auth.users` é a mesma, um usuário novo criado para a marcenaria aparece
também na Equipe da marmoraria, inativo, esperando liberação. É só ignorar.

### Ligar pela primeira vez

1. Em `sistema/config.js`, preencha `SUPABASE_URL` e `SUPABASE_CHAVE` com os
   dados do projeto (a chave é a *anon public* / *publishable*, nunca a
   service_role). `SUPABASE_SCHEMA` já vem como `jk`.
2. No SQL Editor do Supabase, rode nesta ordem:
   `banco.sql`, `banco-agenda.sql`, `banco-equipe.sql`, `banco-historico.sql`,
   `banco-custos.sql`, `banco-link.sql`, `banco-arquivos.sql`.
3. Em **Settings → API → Exposed schemas**, acrescente `jk` à lista.
   É o passo que todo mundo esquece — sem ele o sistema entra mas não acha
   as tabelas.
4. Em **Authentication → Users → Add user**, crie seu usuário com
   *Auto Confirm User* marcado. O primeiro usuário entra como admin.

Enquanto a URL e a chave não estiverem preenchidas, o sistema abre uma tela
explicando o que falta em vez de quebrar. Se o `jk` não estiver exposto, o
aviso de erro diz exatamente isso.

### Um dia, um projeto só da marmoraria

Se abrir vaga no plano free e você criar um projeto separado: aponte a URL e a
chave para ele, troque `SUPABASE_SCHEMA` para `'public'` e `SUPABASE_BUCKET`
para `'orcamentos'`, e rode os mesmos `.sql` trocando `jk.` por `public.`.
O resto do sistema não muda.

### Papéis

| Papel | Alcança |
|---|---|
| admin | tudo, incluindo custo e margem |
| marmorista | tudo, menos mexer na equipe |
| vendedor | orçamentos e agenda |
| instalador | só a agenda |

O custo do marmorista e a sua margem ficam numa tabela separada que **só o
admin consegue ler** — não é a tela que esconde, é o banco que não entrega.
Esses números nunca saem no PDF nem no link que o cliente abre.

### PDF

O corpo do PDF é claro, para o cliente imprimir e encaminhar; só a faixa do
topo é escura, que é onde a logo dourada aparece como ela é. A logo vem
embutida em `sistema/logo-dados.js` para o PDF sair certo mesmo sem internet.
Trocou a logo? Regere esse arquivo — o comando está no comentário dele.

## Marca

O arquivo original da logo esta em `img/logo` (PNG com fundo transparente,
1536x1024). O que o site usa fica em `assets/marca/`:

| Arquivo | Onde aparece |
|---|---|
| `monograma-jk` (png/webp) | marca do cabecalho — so o "JK", sem a palavra MARMORARIA, que ficaria ilegivel nesse tamanho |
| `logo-jk` (png/webp) | rodape, em 190px de largura |
| `favicon-32.png`, `icone-512.png` | icone da aba e do schema |
| `apple-touch-icon.png` | icone ao salvar na tela inicial do iPhone |

Para regerar tudo a partir de um arquivo novo em `img/logo`:

```bash
cd img
convert logo -trim +repage -resize 720x ../assets/marca/logo-jk.png
convert ../assets/marca/logo-jk.png -quality 88 ../assets/marca/logo-jk.webp
convert logo -trim +repage -gravity north -crop 100%x85%+0+0 +repage -trim +repage \
  -resize 280x ../assets/marca/monograma-jk.png
convert ../assets/marca/monograma-jk.png -quality 90 ../assets/marca/monograma-jk.webp
convert ../assets/marca/logo-jk.png -colors 200 -depth 8 PNG8:../assets/marca/logo-jk.png
```

O recorte de 85% e o que separa o monograma da palavra MARMORARIA sem cortar
o rabinho do J.

A imagem de compartilhamento (`assets/og-image.png`) sai de
`assets/_og-source.html`: sirva a pasta localmente e tire um print de
1200x630 dessa pagina.

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
