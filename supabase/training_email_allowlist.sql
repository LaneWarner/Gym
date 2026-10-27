-- Approved-email list for the training plan app.
-- Run once in Supabase → Healthy Choices → SQL Editor. Safe to run again.

create table if not exists public.training_allowed_emails (
  email text primary key check (email = lower(email)),
  added_at timestamptz not null default now()
);
alter table public.training_allowed_emails enable row level security;
revoke all on public.training_allowed_emails from anon, authenticated;

insert into public.training_allowed_emails (email) values ('lanewarner@gmail.com'), ('aimeelwarner@gmail.com')
on conflict do nothing;

create or replace function public.training_email_allowed(p_email text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (select 1 from public.training_allowed_emails where email = lower(trim(p_email)));
$$;
revoke all on function public.training_email_allowed(text) from public;
grant execute on function public.training_email_allowed(text) to anon, authenticated;

drop policy if exists "Users can read own training data" on public.training_user_data;
drop policy if exists "Users can insert own training data" on public.training_user_data;
drop policy if exists "Users can update own training data" on public.training_user_data;
drop policy if exists "Users can delete own training data" on public.training_user_data;
drop policy if exists "Allowed users read own training data" on public.training_user_data;
drop policy if exists "Allowed users insert own training data" on public.training_user_data;
drop policy if exists "Allowed users update own training data" on public.training_user_data;
drop policy if exists "Allowed users delete own training data" on public.training_user_data;

create policy "Allowed users read own training data" on public.training_user_data
  for select to authenticated
  using (auth.uid() = user_id and public.training_email_allowed(auth.jwt() ->> 'email'));
create policy "Allowed users insert own training data" on public.training_user_data
  for insert to authenticated
  with check (auth.uid() = user_id and public.training_email_allowed(auth.jwt() ->> 'email'));
create policy "Allowed users update own training data" on public.training_user_data
  for update to authenticated
  using (auth.uid() = user_id and public.training_email_allowed(auth.jwt() ->> 'email'))
  with check (auth.uid() = user_id and public.training_email_allowed(auth.jwt() ->> 'email'));
create policy "Allowed users delete own training data" on public.training_user_data
  for delete to authenticated
  using (auth.uid() = user_id and public.training_email_allowed(auth.jwt() ->> 'email'));
