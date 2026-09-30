/* =====================================================================
   CONFIGURAÇÃO — mexa só aqui.

   Os dois valores do Supabase:

     URL   →  Settings → API → Project URL
              Ou monte a partir do endereço do painel:
              supabase.com/dashboard/project/SEU_ID  →  https://SEU_ID.supabase.co

     CHAVE →  Settings (engrenagem) → API Keys
              Copie a "anon public" OU a "Publishable key" (sb_publishable_...)
              NUNCA a service_role nem as Secret keys.

   A chave publishable/anon é pública de propósito, pode ficar aqui. Quem
   protege os dados é o RLS que os arquivos banco*.sql ativaram: sem login,
   o banco não devolve nada.

   Este sistema divide o projeto Supabase com a Marcenaria Costa, mas mora
   num schema só dele (jk). Tabelas, numeração, equipe e histórico são
   separados: nada aqui encosta no que já existe lá.

   Depois de rodar os .sql, vá em Settings → API → Exposed schemas e
   acrescente "jk" à lista. Sem isso o sistema não enxerga as tabelas.

   Um dia sobrou vaga no plano free e você criou um projeto só da
   marmoraria? Aponte a URL e a chave para ele e troque o schema para
   'public'. Só isso: o resto do sistema não muda.
   ===================================================================== */

window.CONFIG_ORCAMENTO = {

  SUPABASE_URL:    'COLE_AQUI_A_URL',
  SUPABASE_CHAVE:  'COLE_AQUI_A_CHAVE',
  SUPABASE_SCHEMA: 'jk',
  SUPABASE_BUCKET: 'jk-orcamentos',

  /* ---- dados que saem no PDF ---- */
  empresa: {
    nome:      'Marmoraria Modelo',
    subtitulo: 'Granito, mármore e quartzo sob medida',
    cidade:    'Curitiba · PR',
    telefone:  '(41) 99991-7485',
    whatsapp:  '5541999917485',
    site:      'marmoraria-modelo.vercel.app',
    email:     '',
    documento: ''          // CNPJ ou CPF, se quiser que apareça
  },

  /* ---- textos que já vêm preenchidos num orçamento novo ---- */
  padroes: {
    validade_dias:   15,
    prazo_entrega:   'Medição em até 3 dias úteis. Instalação em 7 a 10 dias úteis ' +
                     'após a escolha da chapa.',
    forma_pagamento: '50% na aprovação e 50% na instalação. Pix, dinheiro, débito ou cartão.',
    observacoes:     'Valores incluem medição no local, corte, polimento, entrega e instalação.\n' +
                     'A chapa é escolhida pelo cliente na pedreira; por ser pedra natural, a ' +
                     'veiação e o tom variam de chapa para chapa.\n' +
                     'Recortes para cuba, cooktop e torneira estão inclusos quando descritos no item.\n' +
                     'Medidas confirmadas na visita técnica podem ajustar o valor final.'
  }
};
