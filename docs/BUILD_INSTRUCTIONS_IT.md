# Guida alla Compilazione di Cloudreve

Questa guida ti mostra come compilare Cloudreve dal codice sorgente, inclusa la creazione di una versione personalizzata.

## Requisiti

### Software Necessario

1. **Go** - Versione 1.23.0 o superiore
   ```bash
   # Verifica la versione
   go version
   ```

2. **Node.js e Yarn** - Per compilare il frontend
   ```bash
   # Installa Node.js (versione 16 o superiore)
   # Su Ubuntu/Debian:
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   
   # Installa Yarn
   npm install -g yarn
   ```

3. **Git** - Per clonare il repository
   ```bash
   git --version
   ```

4. **Zip** - Per impacchettare gli assets
   ```bash
   # Su Ubuntu/Debian:
   sudo apt-get install zip
   ```

## Compilazione Completa (Backend + Frontend)

### Passo 1: Clona il Repository

```bash
git clone https://github.com/gablilli/cloudreve.git
cd cloudreve
```

### Passo 2: Compila il Frontend

Il frontend è un'applicazione React che deve essere compilata prima.

```bash
# Naviga nella directory assets
cd assets

# Installa le dipendenze
yarn install --network-timeout 1000000

# Compila il frontend
yarn run build

# Torna alla directory principale
cd ..
```

### Passo 3: Crea l'Archivio degli Assets

```bash
# Crea l'archivio zip dei file compilati del frontend
zip -r assets.zip assets/build

# Sposta l'archivio nella directory corretta
mkdir -p application/statics
mv assets.zip application/statics/
```

### Passo 4: Compila il Backend

```bash
# Scarica le dipendenze Go
go mod download

# Genera il codice ent (ORM)
go generate ./ent

# Compila il binario
go build -o cloudreve \
  -ldflags="-s -w \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom' \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.LastCommit=$(git rev-parse --short HEAD)'"
```

Questo creerà un file eseguibile chiamato `cloudreve` nella directory corrente.

## Compilazione Solo Backend (Sviluppo)

Se stai lavorando solo sul backend e hai già gli assets:

```bash
# Assicurati che assets.zip esista in application/statics/
ls -lh application/statics/assets.zip

# Compila
go build -o cloudreve
```

## Compilazione Cross-Platform

Per compilare per diversi sistemi operativi e architetture:

### Per Linux (amd64)
```bash
GOOS=linux GOARCH=amd64 go build -o cloudreve-linux-amd64 \
  -ldflags="-s -w -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom'"
```

### Per Windows (amd64)
```bash
GOOS=windows GOARCH=amd64 go build -o cloudreve-windows-amd64.exe \
  -ldflags="-s -w -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom'"
```

### Per macOS (Apple Silicon - arm64)
```bash
GOOS=darwin GOARCH=arm64 go build -o cloudreve-darwin-arm64 \
  -ldflags="-s -w -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom'"
```

### Per macOS (Intel - amd64)
```bash
GOOS=darwin GOARCH=amd64 go build -o cloudreve-darwin-amd64 \
  -ldflags="-s -w -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom'"
```

## Utilizzo di GoReleaser (Metodo Avanzato)

GoReleaser compila automaticamente per tutte le piattaforme:

```bash
# Installa GoReleaser
go install github.com/goreleaser/goreleaser@latest

# Assicurati che gli assets siano stati compilati
cd assets && yarn install && yarn run build && cd ..
zip -r assets.zip assets/build
mkdir -p application/statics
mv assets.zip application/statics/

# Compila con GoReleaser (crea release in locale)
goreleaser build --snapshot --clean

# I binari saranno in ./dist/
ls -lh dist/
```

## Script di Compilazione Automatica

Puoi creare uno script bash per automatizzare il processo:

```bash
#!/bin/bash
# build.sh - Script di compilazione automatica

set -e  # Esci in caso di errore

echo "=== Compilazione Cloudreve ==="

# Colori per l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ottieni la versione dal git tag o usa una versione predefinita
VERSION=${1:-"4.7.0-custom"}
COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

echo -e "${YELLOW}Versione: ${VERSION}${NC}"
echo -e "${YELLOW}Commit: ${COMMIT}${NC}"

# Passo 1: Compila il frontend
echo -e "\n${GREEN}[1/4] Compilazione frontend...${NC}"
cd assets
if [ ! -d "node_modules" ]; then
    echo "Installazione dipendenze yarn..."
    yarn install --network-timeout 1000000
fi
yarn run build
cd ..

# Passo 2: Crea l'archivio degli assets
echo -e "\n${GREEN}[2/4] Creazione archivio assets...${NC}"
rm -f assets.zip
zip -r -q assets.zip assets/build
mkdir -p application/statics
mv assets.zip application/statics/

# Passo 3: Scarica le dipendenze Go
echo -e "\n${GREEN}[3/4] Scaricamento dipendenze Go...${NC}"
go mod download

# Passo 4: Compila il backend
echo -e "\n${GREEN}[4/4] Compilazione backend...${NC}"
go build -o cloudreve \
  -ldflags="-s -w \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=${VERSION}' \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.LastCommit=${COMMIT}'"

echo -e "\n${GREEN}✓ Compilazione completata con successo!${NC}"
echo -e "Eseguibile creato: ${YELLOW}./cloudreve${NC}"
echo -e "Dimensione: ${YELLOW}$(du -h cloudreve | cut -f1)${NC}"
```

Salva questo script come `build.sh`, rendilo eseguibile e usalo:

```bash
chmod +x build.sh
./build.sh 4.7.0-mia-versione
```

## Esecuzione dopo la Compilazione

```bash
# Rendi il binario eseguibile (su Linux/macOS)
chmod +x cloudreve

# Esegui Cloudreve
./cloudreve

# Al primo avvio, verrà creato un file di configurazione conf.ini
# e verranno mostrate le credenziali admin di default
```

## Compilazione per Docker

Se vuoi creare un'immagine Docker:

```bash
# Usa il Dockerfile incluso
docker build -t cloudreve:custom .

# Oppure usa docker-compose
docker-compose build
```

## Variabili di Build Personalizzate

Puoi personalizzare la compilazione modificando le variabili in `application/constants/constants.go`:

```go
// BackendVersion - Versione corrente del backend
var BackendVersion = "4.7.0"

// IsPro - Se è la versione Pro
var IsPro = "false"

// LastCommit - ID dell'ultimo commit
var LastCommit = "000000"
```

Queste possono essere sovrascritte durante la compilazione con ldflags come mostrato sopra.

## Risoluzione dei Problemi

### Errore: "pattern assets.zip: no matching files found"

**Causa:** Il file assets.zip non esiste.

**Soluzione:**
```bash
# Compila il frontend e crea l'archivio
cd assets && yarn install && yarn run build && cd ..
zip -r assets.zip assets/build
mkdir -p application/statics
mv assets.zip application/statics/
```

### Errore: "cannot find package"

**Causa:** Dipendenze Go mancanti.

**Soluzione:**
```bash
go mod download
go mod tidy
```

### Errore di memoria durante la compilazione del frontend

**Causa:** Node.js ha memoria insufficiente.

**Soluzione:**
```bash
export NODE_OPTIONS="--max-old-space-size=8192"
cd assets && yarn run build
```

### Binario troppo grande

**Soluzione:** Usa i flag di compilazione per ridurre le dimensioni:
```bash
go build -ldflags="-s -w" -o cloudreve
# -s: rimuove la tabella dei simboli
# -w: rimuove le informazioni di debug DWARF

# Comprimi ulteriormente con UPX (opzionale)
upx --best --lzma cloudreve
```

## Test dopo la Compilazione

```bash
# Verifica la versione
./cloudreve -v

# Esegui i test
go test ./...

# Avvia in modalità di test
./cloudreve --debug
```

## Build per la Produzione

Per una build di produzione ottimizzata:

```bash
# Compila con ottimizzazioni
CGO_ENABLED=0 go build \
  -trimpath \
  -ldflags="-s -w -extldflags '-static' \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0' \
  -X 'github.com/cloudreve/Cloudreve/v4/application/constants.LastCommit=$(git rev-parse --short HEAD)'" \
  -o cloudreve

# Crea un archivio di distribuzione
tar -czf cloudreve-linux-amd64.tar.gz cloudreve
```

## Aggiornamento di una Build Esistente

```bash
# Backup dei dati attuali
cp -r cloudreve.db cloudreve.db.backup
cp conf.ini conf.ini.backup

# Sostituisci il binario
mv cloudreve cloudreve.old
cp /percorso/nuovo/cloudreve .
chmod +x cloudreve

# Riavvia il servizio
./cloudreve
```

## Riferimenti

- [Documentazione ufficiale di Go](https://golang.org/doc/)
- [Documentazione Yarn](https://yarnpkg.com/getting-started)
- [GoReleaser](https://goreleaser.com/)
- [Repository Cloudreve](https://github.com/cloudreve/Cloudreve)
