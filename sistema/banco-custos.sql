-- =====================================================================
-- Marmoraria JK — custo do marmorista e sua margem
-- Cole no SQL Editor do Supabase e clique em RUN. Roda uma vez só.
-- Precisa do banco-equipe.sql rodado antes.
--
-- Por que uma tabela separada, e não umas colunas a mais no orçamento:
-- o que você paga ao marmorista e o quanto põe em cima são SEUS, e não
-- da equipe. Numa tabela à parte, com permissão só de admin, o vendedor
-- e o próprio marmorista nem conseguem pedir esses números ao banco —
-- não é a tela que esconde, é o banco que não entrega.
--
-- E como o custo não mora dentro do orçamento, ele não tem como escapar
-- pelo link que o cliente abre nem pelo PDF. O que o cliente vê é o
-- preço já com a margem, e só.
-- =====================================================================

create table if not exists jk.orcamento_custos (
  orcamento_id  uuid primary key references jk.orcamentos(id) on delete cascade,

  -- { "<id do peça>": 18500.00, ... } — o custo unitário de cada peça
  custos        jsonb not null default '{}'::jsonb,

  -- quanto você põe em cima, em porcentagem
  margem        numeric(5,2) not null default 20 check (margem >= 0 and margem <= 100),

  atualizado_em timestamptz not null default now()
);

alter table jk.orcamento_custos enable row level security;

drop policy if exists "custos: so admin le"     on jk.orcamento_custos;
drop policy if exists "custos: so admin cria"   on jk.orcamento_custos;
drop policy if exists "custos: so admin edita"  on jk.orcamento_custos;
drop policy if exists "custos: so admin apaga"  on jk.orcamento_custos;

create policy "custos: so admin le"
  on jk.orcamento_custos for select to authenticated
  using (jk.meu_papel() = 'admin');

create policy "custos: so admin cria"
  on jk.orcamento_custos for insert to authenticated
  with check (jk.meu_papel() = 'admin');

create policy "custos: so admin edita"
  on jk.orcamento_custos for update to authenticated
  using (jk.meu_papel() = 'admin');

create policy "custos: so admin apaga"
  on jk.orcamento_custos for delete to authenticated
  using (jk.meu_papel() = 'admin');

-- carimbo de atualização (a função já existe desde o banco.sql)
drop trigger if exists tg_custos_atualizacao on jk.orcamento_custos;
create trigger tg_custos_atualizacao
  before update on jk.orcamento_custos
  for each row execute function jk.marca_atualizacao();

-- ---------------------------------------------------------------------
-- No histórico entra que a margem mudou — nunca o custo em si.
-- O histórico é lido só pelo admin, mas não custa nada ser cuidadoso:
-- número de custo não precisa ficar espalhado.
-- ---------------------------------------------------------------------
do $$
begin
  if exists (select 1 from information_schema.tables
              where table_schema = 'public' and table_name = 'historico') then

    execute $gatilho$
      create or replace function jk.historia_custo()
      returns trigger
      language plpgsql
      security definer
      set search_path = jk, public
      as $corpo$
      declare v_num text;
      begin
        if TG_OP = 'UPDATE' and NEW.margem is not distinct from OLD.margem then
          return null;
        end if;

        select lpad(coalesce(o.numero,0)::text, 3, '0') ||
               case when coalesce(o.cliente_nome,'') <> '' then ' · ' || o.cliente_nome else '' end
          into v_num
          from jk.orcamentos o where o.id = NEW.orcamento_id;

        perform jk.anota('orcamento_margem', 'Orçamento ' || coalesce(v_num, '?'),
                             'margem de ' || NEW.margem || '%', NEW.orcamento_id);
        return null;
      end;
      $corpo$;
    $gatilho$;

    execute 'drop trigger if exists historia on jk.orcamento_custos';
    execute 'create trigger historia after insert or update on jk.orcamento_custos
             for each row execute function jk.historia_custo()';
  end if;
end $$;

-- =====================================================================
-- Pronto. Abra um orçamento e o bloco "Sua conta" aparece no lado —
-- só para você.
-- =====================================================================


-- ---------------------------------------------------------------------
-- O schema jk não é o public: as permissões que a Supabase já dá lá
-- precisam ser dadas aqui na mão. O RLS acima continua mandando em quem
-- enxerga o quê — isto só abre a porta do schema.
-- ---------------------------------------------------------------------
grant usage on schema jk to anon, authenticated, service_role;
grant all on all tables    in schema jk to anon, authenticated, service_role;
grant all on all sequences in schema jk to anon, authenticated, service_role;
grant execute on all functions in schema jk to anon, authenticated, service_role;
