-- =====================================================================
-- Marmoraria JK — guarda dos PDFs de orçamento
-- Cole no SQL Editor do Supabase e clique em RUN. Roda uma vez só.
-- =====================================================================

-- Espaço onde o PDF de cada orçamento fica guardado.
-- É "público" no sentido de que o link abre sem senha — é isso que
-- permite o cliente abrir o PDF pelo WhatsApp. O caminho do arquivo
-- inclui o id do orçamento (um UUID), então ninguém descobre o link
-- de outro cliente por tentativa.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('jk-orcamentos', 'jk-orcamentos', true, 10485760, array['application/pdf'])
on conflict (id) do update
  set public = true,
      file_size_limit = 10485760,
      allowed_mime_types = array['application/pdf'];

-- ---------------------------------------------------------------------
-- Quem pode fazer o quê
-- ---------------------------------------------------------------------
drop policy if exists "jk: qualquer um le os pdfs"  on storage.objects;
drop policy if exists "jk: dono envia os pdfs"      on storage.objects;
drop policy if exists "jk: dono atualiza os pdfs"   on storage.objects;
drop policy if exists "jk: dono apaga os pdfs"      on storage.objects;

-- leitura: aberta, para o link funcionar no WhatsApp do cliente
create policy "jk: qualquer um le os pdfs"
  on storage.objects for select
  using (bucket_id = 'jk-orcamentos');

-- gravação: só você, e só dentro da sua própria pasta
create policy "jk: dono envia os pdfs"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'jk-orcamentos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "jk: dono atualiza os pdfs"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'jk-orcamentos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "jk: dono apaga os pdfs"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'jk-orcamentos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );


-- ---------------------------------------------------------------------
-- O schema jk não é o public: as permissões que a Supabase já dá lá
-- precisam ser dadas aqui na mão. O RLS acima continua mandando em quem
-- enxerga o quê — isto só abre a porta do schema.
-- ---------------------------------------------------------------------
grant usage on schema jk to anon, authenticated, service_role;
grant all on all tables    in schema jk to anon, authenticated, service_role;
grant all on all sequences in schema jk to anon, authenticated, service_role;
grant execute on all functions in schema jk to anon, authenticated, service_role;
