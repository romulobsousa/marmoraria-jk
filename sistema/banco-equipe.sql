-- =====================================================================
-- Marmoraria JK — equipe e permissões
-- Cole no SQL Editor do Supabase e clique em RUN. Roda uma vez só.
--
-- O que muda: até agora cada conta só enxergava o que ela mesma criou.
-- A partir daqui os orçamentos e a agenda são da MARMORARIA, e o que
-- separa as pessoas é o papel de cada uma:
--
--   admin       faz tudo, e é o único que mexe na equipe
--   marmorista  faz tudo, menos mexer na equipe
--   vendedor    cria, edita e envia — mas não apaga nada
--   instalador    só a agenda: vê as visitas e marca o que já foi feito
--
-- Quem entra e ainda não tem papel definido não vê nada e aparece para
-- você na tela Equipe, esperando liberação. É de propósito: conta nova
-- não nasce com acesso.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Quem é quem
-- ---------------------------------------------------------------------
create table if not exists jk.equipe (
  id         uuid primary key references auth.users(id) on delete cascade,
  nome       text not null default '',
  email      text not null default '',
  papel      text not null default 'instalador'
             check (papel in ('admin','marmorista','vendedor','instalador')),
  ativo      boolean not null default false,
  criado_em  timestamptz not null default now()
);

alter table jk.equipe enable row level security;

-- ---------------------------------------------------------------------
-- Duas perguntas que o sistema faz o tempo todo
-- Ficam como "security definer" para não cair em recursão de permissão:
-- ler a tabela equipe depende da equipe.
-- ---------------------------------------------------------------------
create or replace function jk.meu_papel()
returns text
language sql
security definer
stable
set search_path = jk, public
as $$
  select papel from jk.equipe
   where id = auth.uid() and ativo
   limit 1;
$$;

-- devolve o cadastro de quem está logado, mesmo que ainda não liberado —
-- é assim que a tela sabe dizer "sua conta está esperando liberação"
create or replace function jk.meu_acesso()
returns json
language sql
security definer
stable
set search_path = jk, public
as $$
  select json_build_object(
    'id',    e.id,
    'nome',  e.nome,
    'email', e.email,
    'papel', e.papel,
    'ativo', e.ativo
  )
  from jk.equipe e
  where e.id = auth.uid()
  limit 1;
$$;

grant execute on function jk.meu_papel()  to authenticated;
grant execute on function jk.meu_acesso() to authenticated;

-- ---------------------------------------------------------------------
-- Conta nova entra sozinha na lista, sem acesso, esperando você liberar
-- ---------------------------------------------------------------------
create or replace function jk.equipe_ao_criar_usuario()
returns trigger
language plpgsql
security definer
set search_path = jk, public
as $$
begin
  insert into jk.equipe (id, nome, email, papel, ativo)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', split_part(new.email, '@', 1)),
    coalesce(new.email, ''),
    'instalador',
    false
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists jk_ao_criar_usuario on auth.users;
create trigger jk_ao_criar_usuario
  after insert on auth.users
  for each row execute function jk.equipe_ao_criar_usuario();

-- ---------------------------------------------------------------------
-- Quem já existe entra como admin — é você, dono da conta
-- (rode este arquivo ANTES de criar as contas novas)
-- ---------------------------------------------------------------------
-- a conta mais antiga (a primeira que você criou) vira admin; qualquer
-- outra que já exista entra sem acesso, esperando você liberar na tela
insert into jk.equipe (id, nome, email, papel, ativo)
select u.id,
       coalesce(u.raw_user_meta_data->>'nome', split_part(u.email, '@', 1)),
       coalesce(u.email, ''),
       case when u.created_at = (select min(created_at) from auth.users)
            then 'admin' else 'instalador' end,
       u.created_at = (select min(created_at) from auth.users)
from auth.users u
on conflict (id) do nothing;

-- ---------------------------------------------------------------------
-- Permissões da própria lista de equipe
-- ---------------------------------------------------------------------
drop policy if exists "equipe: a turma toda se ve"   on jk.equipe;
drop policy if exists "equipe: so admin cadastra"    on jk.equipe;
drop policy if exists "equipe: so admin altera"      on jk.equipe;
drop policy if exists "equipe: so admin remove"      on jk.equipe;

create policy "equipe: a turma toda se ve"
  on jk.equipe for select to authenticated
  using (jk.meu_papel() is not null);

create policy "equipe: so admin cadastra"
  on jk.equipe for insert to authenticated
  with check (jk.meu_papel() = 'admin');

create policy "equipe: so admin altera"
  on jk.equipe for update to authenticated
  using (jk.meu_papel() = 'admin');

create policy "equipe: so admin remove"
  on jk.equipe for delete to authenticated
  using (jk.meu_papel() = 'admin' and id <> auth.uid());  -- ninguém se apaga

-- ---------------------------------------------------------------------
-- Orçamentos: da marmoraria, não de quem digitou
-- ---------------------------------------------------------------------
-- tira as regras antigas (as de "cada um vê o seu"), quaisquer que sejam
do $$
declare r record;
begin
  for r in select policyname from pg_policies
            where schemaname = 'public' and tablename = 'orcamentos'
  loop
    execute format('drop policy %I on jk.orcamentos', r.policyname);
  end loop;
end $$;

create policy "orcamentos: equipe le"
  on jk.orcamentos for select to authenticated
  using (jk.meu_papel() in ('admin','marmorista','vendedor'));

create policy "orcamentos: equipe cria"
  on jk.orcamentos for insert to authenticated
  with check (jk.meu_papel() in ('admin','marmorista','vendedor')
              and user_id = auth.uid());

create policy "orcamentos: equipe edita"
  on jk.orcamentos for update to authenticated
  using (jk.meu_papel() in ('admin','marmorista','vendedor'));

-- apagar é definitivo: só admin e marmorista
create policy "orcamentos: so chefia apaga"
  on jk.orcamentos for delete to authenticated
  using (jk.meu_papel() in ('admin','marmorista'));

-- ---------------------------------------------------------------------
-- Agenda: todo mundo da equipe enxerga, inclusive o instalador
-- ---------------------------------------------------------------------
do $$
declare r record;
begin
  for r in select policyname from pg_policies
            where schemaname = 'public' and tablename = 'visitas'
  loop
    execute format('drop policy %I on jk.visitas', r.policyname);
  end loop;
end $$;

create policy "visitas: equipe le"
  on jk.visitas for select to authenticated
  using (jk.meu_papel() is not null);

create policy "visitas: equipe marca"
  on jk.visitas for insert to authenticated
  with check (jk.meu_papel() in ('admin','marmorista','vendedor')
              and user_id = auth.uid());

-- o instalador também edita: é assim que ele marca a visita como realizada
create policy "visitas: equipe edita"
  on jk.visitas for update to authenticated
  using (jk.meu_papel() is not null);

create policy "visitas: so chefia apaga"
  on jk.visitas for delete to authenticated
  using (jk.meu_papel() in ('admin','marmorista'));

-- ---------------------------------------------------------------------
-- PDFs: qualquer um da equipe pode subir o PDF de um orçamento
-- (antes cada um só escrevia na própria pasta; com a lista compartilhada
--  o vendedor precisa conseguir reenviar um orçamento que outro criou)
-- ---------------------------------------------------------------------
drop policy if exists "jk: dono envia os pdfs"     on storage.objects;
drop policy if exists "jk: dono atualiza os pdfs"  on storage.objects;
drop policy if exists "jk: dono apaga os pdfs"     on storage.objects;
drop policy if exists "jk: equipe envia os pdfs"   on storage.objects;
drop policy if exists "jk: equipe atualiza os pdfs" on storage.objects;
drop policy if exists "jk: chefia apaga os pdfs"   on storage.objects;

create policy "jk: equipe envia os pdfs"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'jk-orcamentos' and jk.meu_papel() is not null);

create policy "jk: equipe atualiza os pdfs"
  on storage.objects for update to authenticated
  using (bucket_id = 'jk-orcamentos' and jk.meu_papel() is not null);

create policy "jk: chefia apaga os pdfs"
  on storage.objects for delete to authenticated
  using (bucket_id = 'jk-orcamentos' and jk.meu_papel() in ('admin','marmorista'));

-- =====================================================================
-- Depois de rodar isto:
--   1. Authentication → Users → Add user, para cada pessoa da equipe
--      (marque "Auto Confirm User")
--   2. Entre no sistema e vá em Equipe: a pessoa aparece esperando
--      liberação. Escolha o papel e ligue o acesso.
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
