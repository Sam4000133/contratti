# Contesto progetto — `contratti`

Software di **generazione contratti Rent To Buy** integrato con **Perfex CRM**.
Questa repo è l'app **Next.js (tema Metronic completo)** con **NextAuth + Prisma + RBAC**, che
fa da pannello operatori/admin e (in prospettiva) portale cliente.

## Documentazione (in questa repo)
- `docs/PIANO.md` — architettura completa, modello dati, flusso, mappatura campi, impostazioni.
- `docs/PANNELLO-ADMIN-UI.md` — menu laterale, pagine e dialog del pannello.

## Stack
Next.js 16 · React 19 · Tailwind 4 · TypeScript · **NextAuth (credentials + Google)** ·
**Prisma** su **PostgreSQL 18** · tema Metronic.

## Avvio in locale (Docker)
```bash
docker compose up -d --build      # → http://localhost:3200
```
Lo stack avvia **PostgreSQL 18** + l'app; al primo start esegue `prisma migrate deploy` e il
**seed** (idempotente).

**Login superadmin (seed):** `owner@kt.com` / `12345` (ruolo *owner*, accesso completo).
Anche `demo@kt.com` / `demo123`. Pagina di login: `/signin`.

### Note Docker importanti
- **PostgreSQL 18**: il volume va montato su `/var/lib/postgresql` (NON `/var/lib/postgresql/data`).
- **`.npmrc` con `legacy-peer-deps=true` è necessario** (conflitto peer @auth/core ↔ nodemailer):
  va copiato prima di `npm ci`.
- `DATABASE_URL`/`DIRECT_URL` e `NEXTAUTH_*` sono l'**eccezione di bootstrap** (vedi PIANO):
  arrivano dal docker-compose, non da `.env` nel repo.

## Convenzioni — DA RISPETTARE SEMPRE
- **Commit Git: autore SOLO `Sam4000133`.** Mai co-autori né trailer (niente `Co-Authored-By`,
  niente "Generated with…"). Messaggi di commit in italiano.
- **Commenti del codice in italiano.**
- **Niente hardcoded e niente `.env`** per la config applicativa: tutto in **database**,
  modificabile dal pannello (URL/sottodomini, endpoint e credenziali API, parametri).
  Unica eccezione: connessione DB + secret di NextAuth (bootstrap).
- Sistema **multi-locatore (multi-tenant)** con **ruoli dinamici**.
- Integrazioni esterne via **OpenAPI** (data certa, visure, …); SMS e AI di visione con provider
  configurabile.
