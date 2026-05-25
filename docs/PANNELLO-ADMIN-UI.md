# PANNELLO AMMINISTRATIVO — Menu, Pagine e Dialog

> Tema: **Metronic (Next.js / Tailwind / React)** · Backend: **NestJS**.
> Documento di design dell'interfaccia operatori/admin. Coerente con `PIANO.md`.

---

## 1. Layout generale (struttura Metronic)

```
┌───────────────────────────────────────────────────────────────────────┐
│ TOPBAR:  [☰]  Logo   |  ⌂ Locatore: [Revonet Holding SE ▾]   🔍  🔔  👤 │
├───────────┬───────────────────────────────────────────────────────────┤
│           │  Toolbar pagina: Titolo + breadcrumb        [Azioni ▸]      │
│  SIDEBAR  ├───────────────────────────────────────────────────────────┤
│  (menu)   │                                                             │
│           │  Contenuto: Card / KTDataTable / Tabs / Stepper             │
│           │                                                             │
└───────────┴───────────────────────────────────────────────────────────┘
```

Elementi chiave del tema:
- **Locatore switcher** nella topbar (dropdown): cambia il **tenant attivo**; tutto il
  contenuto è *scoped* sul Locatore selezionato. Visibile solo se l'utente ha ≥2 Locatori.
- **Sidebar** ad accordion con gruppi e icone; **voci filtrate per permesso** (RBAC).
- **Toolbar** di pagina con breadcrumb e pulsanti azione.
- **Drawer** laterali per dettaglio rapido, **Modal** per conferme/form brevi, **Stepper**
  per flussi multi-step.
- **Notifiche interne** (campanella 🔔): inbox operatori — cliente completato, **multa non
  associata**, firma effettuata, **data certa fallita**, **credito OpenAPI basso**, contratto in scadenza.

---

## 2. Menu laterale (sidebar)

```
▣ Dashboard

▣ PRATICHE
   • Tutte le pratiche
   • In attesa cliente
   • Da revisionare           (badge: n.)
   • Da firmare               (badge: n.)
   • Finalizzate
   • Scadute / Annullate

▣ Contratti                   (archivio PDF firmati + data certa)

▣ FLOTTA
   • Veicoli
   • Importa / Sincronizza

▣ Documenti & Verifiche

▣ MULTE                        [fines.manage]
   • Tutte le multe
   • Da associare              (badge: n.)
   • In attesa pagamento       (badge: n.)
   • Da rivedere               (badge: n.)
   • Pagate

──────────────────────────────  (sezione gestita da permessi)

▣ IMPOSTAZIONI                 [settings.manage]
   • Profilo Locatore
   • Template (contratto / condizioni / delega / email)
   • Parametri economici
   • Solleciti & Notifiche
   • Integrazioni (OpenAPI · SMTP · SMS · AI visione · Perfex)
   • Feature flag
   • Sicurezza & Retention

▣ AMMINISTRAZIONE
   • Utenti                    [users.manage]
   • Ruoli & Permessi          [roles.manage]
   • Locatori                  [locatori.manage]  (Super Admin)

▣ SISTEMA & LOG               [audit.view]
   • Audit log
   • Eventi webhook
   • Code / Job
```

> Le voci **Locatori**, **Utenti**, **Ruoli**, **Impostazioni**, **Sistema** compaiono solo
> se l'utente possiede il relativo permesso. Le icone seguono il set Metronic (Duotone).

---

## 3. Pagine

### 3.1 Dashboard
**Scopo:** colpo d'occhio operativo sul Locatore attivo.
- Card KPI: *Nuove*, *In attesa cliente*, *Da revisionare*, *Da firmare*, *Finalizzate (mese)*.
- Widget **pratiche per stato** (grafico a barre/timeline).
- Lista *“Azioni richieste”* (pratiche che aspettano l'operatore).
- Pannello *Integrazioni* con stato OpenAPI/SMTP/Perfex (pallino verde/rosso).

---

### 3.2 Pratiche — elenco
**Scopo:** tabella di tutte le pratiche con filtri rapidi (le voci di menu sono preset di filtro).
- **KTDataTable** con colonne: `Rif (PRO-…)`, `Conduttore`, `Veicolo/Targa`, `Stato (badge)`,
  `Aggiornata`, `Operatore`, `Azioni`.
- Toolbar: ricerca, filtro stato, filtro periodo, filtro operatore, export.
- Riga → apre la **pagina di dettaglio** (3.3).

**Dialog/Modal:**
- *Modal “Annulla pratica”* (motivo + conferma).
- *Drawer “Anteprima rapida”* (stato, conduttore, veicolo, timeline) senza lasciare l'elenco.

---

### 3.3 Pratica — dettaglio  ⟵ pagina centrale
**Scopo:** governare l'intero ciclo della pratica. Header con **Stepper** che riflette la
macchina a stati: `Nuova → Attesa cliente → Completata → Revisione → Generato → Firma →
Finalizzata`.

Layout a **Tabs**:
1. **Riepilogo** — dati chiave + timeline eventi + pulsanti azione contestuali allo stato.
2. **Conduttori** — lista (principale + aggiuntivi) con dati patente; stato compilazione.
3. **Veicolo** — veicolo agganciato dalla flotta + dati tecnici (modificabili in revisione).
4. **Economia** — canone, durata, acconto, SIP, fee marca, riscatto, totale (ricalcolo live).
5. **Documenti** — patente f/r, identità f/r, visura: anteprima + stato *verificato*.
6. **Verifiche** — confronto dati Perfex vs visura, con valori corretti (la visura fa fede).
7. **Contratto** — anteprima PDF base / firmato / con data certa; storico versioni.
8. **Audit** — log azioni sulla pratica.

**Azioni (gate per stato + permesso):**
- `Reinvia link cliente` · `Aggancia veicolo` · `Respingi al cliente` ·
  `Genera contratto` · `Invia per firma` · `Applica data certa` · `Scarica PDF` ·
  `Chiudi contratto` (`contract.close`).
- **Banner validazioni** prima della generazione: avvisi su VIES, IBAN, **patente scaduta**,
  **firmatario azienda mancante**.

**Dialog/Modal/Drawer collegati:**
- *Drawer “Aggancia veicolo”* — cerca per targa nella flotta o **crea veicolo** al volo.
- *Modal “Genera contratto”* — scelta template + conferma dati → genera anteprima.
- *Modal “Invia per firma”* — canale (email/SMS), messaggio, scadenza link.
- *Modal “Applica data certa”* — riepilogo costo/provider + conferma; mostra esito (numero data certa).
- *Modal “Respingi al cliente”* — campi da correggere + nota.
- *Modal “Correggi dato”* — su tab Verifiche, conferma/forza valore.
- *Modal “Firmatario”* — per conduttore azienda: nome + qualità (es. legale rappresentante).
- *Modal “Chiudi contratto”* — motivo (**riscatto / restituzione / inadempimento / accordo /
  sinistro**) + data → **avvia la retention** della pratica.
- *Lightbox documento* — visore patente/identità/visura con zoom.

---

### 3.4 Contratti — archivio e ciclo di vita
- Filtri rapidi (chip): **Attivi** · **In scadenza** · **Chiusi** (per motivo) · Tutti.
- **KTDataTable**: `Numero`, `Conduttore`, `Data firma`, `N° data certa`, `Stato (Attivo/Chiuso)`,
  `Motivo chiusura`, `Scadenza`, `Azioni`.
- Azioni: *Scarica PDF finale*, *Verifica contrassegno*, *Apri pratica*, *Chiudi contratto*.
- *Modal “Verifica data certa”*: esito validazione marca/contrassegno.
- *Modal “Chiudi contratto”*: motivo + data (riscatto/restituzione/inadempimento/accordo/sinistro).

---

### 3.5 Flotta — Veicoli
- **KTDataTable**: `Targa`, `Marca/Modello`, `Carburante`, `Telaio/VIN`, `Stato`, `Azioni`.
- *Drawer/Modal “Veicolo”* (crea/modifica): targa, marca, modello esteso, condizioni,
  motorizzazione, carburante, telaio/VIN, Euro, anno, note.
- *Modal “Importa veicoli”* (CSV) e *“Disattiva veicolo”*.
- *Tab “Storico assegnazioni”* nel dettaglio veicolo (pratiche + periodi `dal/al`) — usato anche
  per il **match delle multe “del periodo”**.

---

### 3.6 Documenti & Verifiche
- Coda dei documenti **da verificare** (cross-pratica): anteprima + `Approva` / `Richiedi
  reupload`.
- *Lightbox* documento; *Modal “Richiedi nuovo upload”* (motivo → email al cliente).

---

### 3.6.1 Multe — elenco
**Scopo:** smistare le multe dei veicoli al conduttore corretto. Le voci di menu sono preset di filtro per stato.
- **KTDataTable**: `Verbale`, `Targa`, `Veicolo`, `Conduttore`, `Importo`, `Scadenza`, `Stato (badge)`, `Azioni`.
- Toolbar: **Carica multa** (azione primaria), ricerca targa/verbale, filtro stato/periodo.

**Dialog/Drawer:**
- *Drawer “Carica multa”* — dropzone PDF/JPG → **anteprima estrazione AI** (targa, importo, ente, data, scadenza) → conferma; il sistema tenta il **match automatico** targa→veicolo→pratica/conduttore.
- *Modal “Associa manualmente”* — per le multe `NON_ASSOCIATA`: cerca veicolo/pratica/conduttore e associa.

### 3.6.2 Multa — dettaglio
- Header con **stepper multe** (`Nuova → Analizzata → Associata → Notificata → In attesa pagamento → Pagata`).
- Pannelli: documento multa (**lightbox**), **dati estratti AI** (editabili), veicolo+conduttore associati, **ricevuta di pagamento** con esito verifica AI.
- **Azioni:** `Associa/Riassocia` · `Invia/Reinvia link Area Cliente` · `Verifica pagamento` · `Segna pagata` · `Segna contestata`.
- *Modal “Verifica pagamento”*: confronto AI (importo/estremi) → conferma **pagata** o segna **da rivedere**.

---

### 3.7 Impostazioni → Profilo Locatore
- Form: ragione sociale, sede, P.IVA, C.F., IBAN/SWIFT/banca; **upload logo** e
  **timbro/firma** del Locatore (usati nel PDF).
- **Legale rappresentante**: nome, qualità (es. CEO) e **firma** (usati nella delega).
- **URL pubblici** (admin / portale / area cliente) — usati per costruire i link nelle email.
  *Tutto in DB, niente `.env`.*
- *Modal “Anteprima intestazione contratto”*.

### 3.8 Impostazioni → Template
- Elenco template per **tipo** (contratto, condizioni generali, delega, email) con **versioni**.
- **Editor** (HTML + lista segnaposto disponibili) con *Anteprima dati di esempio*.
- *Modal “Nuova versione”* · *Modal “Imposta come attivo”* · *Drawer “Segnaposto”* (catalogo variabili).

### 3.9 Impostazioni → Parametri economici
- Form: SIP default, fee marca temporale, extra-km default, durata default, regola di
  **ricalcolo totale**. Valori globali con **override per-Locatore** (toggle “usa default”).

### 3.9.1 Impostazioni → Solleciti & Notifiche
- Switch **abilita solleciti**; **canali** (email / SMS); **pianificazione** (primo dopo *N*
  giorni, ripeti ogni *M*, **max** *K* tentativi); fascia oraria; **rigenera link se scaduto** (on/off).
- Template dei messaggi di sollecito (email/SMS).
- *Modal “Invio di prova”* (manda un sollecito di test).

### 3.10 Impostazioni → Integrazioni
- Schede (tab): **OpenAPI** (data certa / visure / firma — chiavi + ambiente test/prod +
  **toggle** per servizio), **SMTP**, **SMS** (driver configurabile + credenziali),
  **AI di visione** (provider OCR multe + verifica pagamenti, chiavi + toggle),
  **Perfex** (URL, webhook secret).
- Pulsante *“Testa connessione”* per ciascuna; badge stato.
- *Modal “Rigenera webhook secret”*.

### 3.11 Impostazioni → Feature flag
- Switch: *Visure on/off*, *Firma on/off* + **metodo firma** (grafica / FEA-OTP),
  *Promemoria automatici*, ecc. Override per-Locatore.

### 3.12 Impostazioni → Sicurezza & Retention
- Scadenze link (compilazione/firma) e **Area Cliente OTP**; policy upload (MIME/dimensioni).
- **Soglia trigger pagamento** (saldo totale / primo acconto) e **frequenza reconciliation**.
- **Retention selettiva**: giorni di conservazione **documenti accessori dalla chiusura** +
  **anni di conservazione legale** del contratto/data certa.
- **2FA** pannello (obbligatorio/opzionale); credenziali integrazioni **cifrate a riposo**.
- *Modal “Conferma modifica retention”* (impatto sulle cancellazioni future).

---

### 3.13 Amministrazione → Utenti
- **KTDataTable**: `Nome`, `Email`, `Locatori assegnati`, `Ruolo`, `Stato`, `Azioni`.
- *Modal/Drawer “Utente”* (crea/modifica): dati + **assegnazione Locatori** (multi-select) +
  **ruolo per Locatore**.
- *Modal “Reset password”* · *Modal “Disattiva utente”*.

### 3.14 Amministrazione → Ruoli & Permessi
- Elenco ruoli + **matrice permessi** (griglia checkbox per area: settings, fleet, pratiche,
  contract, datacerta, documents, users, roles, audit, templates, integrations).
- *Modal “Nuovo ruolo”* · *Drawer “Modifica matrice permessi”*.

### 3.15 Amministrazione → Locatori  *(Super Admin)*
- **KTDataTable** dei Locatori (tenant): `Ragione sociale`, `P.IVA`, `Utenti`, `Stato`.
- *Drawer/Modal “Locatore”* (crea/modifica): dati base; al salvataggio **seed** delle
  impostazioni di default.
- *Modal “Disattiva Locatore”*.

---

### 3.16 Sistema & Log
- **Audit log**: tabella filtrabile (utente, azione, entità, periodo).
- **Eventi webhook**: stato (`ricevuto/processato/errore`), payload, *“Riprocessa”*.
- **Code / Job**: stato job BullMQ (email, PDF, data certa) con *“Riprova”* sui falliti.

---

## 4. Catalogo Dialog (riassunto)

| Tipo | Esempi |
|---|---|
| **Modal conferma** | Annulla pratica, Disattiva utente/veicolo/Locatore, Applica data certa, Rigenera secret |
| **Modal form breve** | Reset password, Nuovo ruolo, Nuova versione template, Invia per firma, Respingi al cliente |
| **Drawer (slide-over)** | Anteprima pratica, Aggancia veicolo, Utente, Locatore, Segnaposto template, Matrice permessi |
| **Stepper/Wizard** | Header pratica (stati), creazione guidata veicolo |
| **Lightbox** | Visore documenti (patente/identità/visura) |
| **Tabs** | Dettaglio pratica, Integrazioni |

---

## 5. Mappa pagina → permesso (RBAC)

| Pagina | Permesso |
|---|---|
| Pratiche (view/edit) | `pratiche.view` / `pratiche.edit` |
| Genera contratto / Invia firma | `contract.generate` / `contract.sign.manage` |
| Applica data certa | `datacerta.apply` |
| Chiusura contratto | `contract.close` |
| Documenti & Verifiche | `documents.verify` |
| Flotta | `fleet.manage` |
| Impostazioni (tutte) | `settings.manage` (+ `templates.manage`, `integrations.manage`) |
| Utenti / Ruoli / Locatori | `users.manage` / `roles.manage` / `locatori.manage` |
| Multe (gestione / verifica pagamento) | `fines.manage` / `fines.verify` |
| Solleciti & Notifiche | `reminders.manage` (+ `settings.manage`) |
| Sistema & Log | `audit.view` |

---

## 6. Appendice — Portale cliente (Next.js, fuori dal pannello admin)

### 6.1 Link monouso di compilazione
Accesso via **link tokenizzato** (`/p/[token]`), senza login, **a scadenza** (rigenerabile dai solleciti):
1. **Benvenuto** — riepilogo pratica (veicolo, durata) e cosa serve.
2. **Conducente principale** — dati anagrafici + patente.
3. **Autisti aggiuntivi** — aggiungi/rimuovi conducenti (stessi campi).
4. **Documenti** — upload patente f/r, identità f/r, **visura** (presigned MinIO).
5. **Riepilogo & invio** — conferma dati.
6. **Firma** (quando invitato) — **firma grafica** a schermo + accettazione → invio.

### 6.2 Area Cliente persistente (`/area/[token]`, accesso OTP)
Magic-link **senza scadenza** → il cliente richiede un **OTP via email** → sessione breve.
- **Le mie pratiche / contratti** — stato e download del contratto finale.
- **I miei documenti** — patente, identità, visura caricati.
- **Le mie multe** — elenco con importo/scadenza/stato; **upload ricevuta di pagamento**
  (verificata da AI). Notifica via questa area quando una multa viene associata.
- Mostra **solo** i dati del conduttore autenticato; OTP a scadenza breve + rate limiting.

Pattern Metronic riusabili anche qui (wizard/stepper, card, upload dropzone), ma con
**branding del Locatore** (logo/colori da impostazioni) e UX semplificata.
