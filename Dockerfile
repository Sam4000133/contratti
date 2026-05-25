# App "contratti" — Metronic Next.js completo (NextAuth + Prisma + PostgreSQL).
# Immagine unica con TUTTE le dipendenze (incluse devDeps): a runtime servono
# la CLI Prisma e lo script di seed, quindi non facciamo il prune.
FROM node:22-alpine

# openssl richiesto da Prisma; build tools per i moduli nativi (bcrypt)
RUN apk add --no-cache libc6-compat openssl python3 make g++

WORKDIR /app
ENV NEXT_TELEMETRY_DISABLED=1

# Dipendenze dal lockfile (.npmrc imposta legacy-peer-deps per il conflitto
# peer nodemailer di @auth/core)
COPY package.json package-lock.json .npmrc ./
RUN npm ci

# Codice + generazione client Prisma
COPY . .
RUN npx prisma generate

# Valori SOLO per il build (nessuna connessione reale): quelli veri arrivano a
# runtime dal docker-compose. Nessun segreto resta nell'immagine.
ENV DATABASE_URL="postgresql://build:build@localhost:5432/build?schema=public" \
    DIRECT_URL="postgresql://build:build@localhost:5432/build?schema=public" \
    NEXTAUTH_SECRET="placeholder-build" \
    NEXTAUTH_URL="http://localhost:3000/" \
    NEXT_PUBLIC_BASE_PATH=""
RUN npm run build

EXPOSE 3000
ENV PORT=3000 HOSTNAME=0.0.0.0

# A runtime: applica le migrazioni, esegue il seed (idempotente) e avvia Next.
CMD ["sh", "-c", "npx prisma migrate deploy && (node prisma/seed.js || echo 'seed saltato/gia presente') && npm run start"]
