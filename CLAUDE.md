# Contesto progetto — `contratti`

Frontend del sistema di **generazione contratti Rent To Buy** integrato con **Perfex CRM**.
Questa repo contiene il **pannello operatori/admin** e il **portale cliente**, basati sul tema
**Metronic** (Next.js 16 / React 19 / Tailwind 4). Backend previsto: **NestJS + PostgreSQL +
Redis + MinIO** (da costruire nelle fasi successive).

## Documentazione (in questa repo)
- `docs/PIANO.md` — architettura completa, modello dati, flusso, mappatura campi, impostazioni.
- `docs/PANNELLO-ADMIN-UI.md` — menu laterale, pagine e dialog del pannello (Metronic).

## Convenzioni — DA RISPETTARE SEMPRE
- **Commit Git: autore SOLO `Sam4000133`.** Mai aggiungere co-autori né trailer di alcun tipo
  (niente `Co-Authored-By`, niente "Generated with…"). Messaggi di commit in italiano.
- **Commenti del codice in italiano.**
- **Niente hardcoded e niente `.env`:** *tutta* la configurazione (URL/sottodomini, endpoint e
  credenziali API, parametri) vive **nel database** ed è modificabile dal pannello. Unica
  eccezione di bootstrap: stringa di connessione al DB + master key (da runtime/secret manager).
- Sistema **multi-locatore (multi-tenant)** con **ruoli dinamici** e utenti assegnabili a uno o
  più Locatori.
- Integrazioni esterne via **OpenAPI** (data certa, visure, …); SMS e AI di visione con provider
  configurabile.

## Avvio in locale
```bash
docker compose up --build      # → http://localhost:3000
```

## Stack
Next.js 16 · React 19 · Tailwind 4 · TypeScript · tema Metronic. Build Docker multi-stage con
output `standalone`.
