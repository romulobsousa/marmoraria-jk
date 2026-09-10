-- =====================================================================
-- Marmoraria JK — leitura pública de um orçamento pelo link
-- Cole no SQL Editor do Supabase e clique em RUN. Roda uma vez só.
--
-- Por que uma função e não uma permissão de leitura na tabela:
-- liberar a tabela deixaria qualquer pessoa com a chave pública do site
-- listar TODOS os seus orçamentos. Esta função devolve um, e só um,
-- e apenas quando quem chama já sabe o UUID exato — que só existe no
-- link que você mandou para aquele cliente.
-- =====================================================================

create or replace function jk.orcamento_por_link(p_id uuid)
returns json
language sql
security definer
set search_path = jk, public
as $$
  select json_build_object(
    'numero',          o.numero,
    'criado_em',       o.criado_em,
    'cliente_nome',    o.cliente_nome,
    'cliente_endereco',o.cliente_endereco,
    'itens',           o.itens,
    'desconto',        o.desconto,
    'prazo_entrega',   o.prazo_entrega,
    'forma_pagamento', o.forma_pagamento,
    'observacoes',     o.observacoes,
    'validade_dias',   o.validade_dias,
    'status',          o.status,
    -- caminho do PDF dentro da guarda de arquivos, para o botão "Baixar em PDF"
    'pdf',             o.user_id::text || '/' || o.id::text || '.pdf'
  )
  from jk.orcamentos o
  where o.id = p_id
    and o.status in ('enviado','aprovado')   -- rascunho não vaza por link
  limit 1;
$$;

-- Repare no que NÃO sai: telefone e e-mail do cliente, e nada de outros
-- orçamentos. Rascunhos e recusados também não abrem.

revoke all on function jk.orcamento_por_link(uuid) from public;
grant execute on function jk.orcamento_por_link(uuid) to anon, authenticated;


-- ---------------------------------------------------------------------
-- O schema jk não é o public: as permissões que a Supabase já dá lá
-- precisam ser dadas aqui na mão. O RLS acima continua mandando em quem
-- enxerga o quê — isto só abre a porta do schema.
-- ---------------------------------------------------------------------
grant usage on schema jk to anon, authenticated, service_role;
grant all on all tables    in schema jk to anon, authenticated, service_role;
grant all on all sequences in schema jk to anon, authenticated, service_role;
grant execute on all functions in schema jk to anon, authenticated, service_role;
