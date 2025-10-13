#!/bin/bash
# build.sh - Script di compilazione automatica per Cloudreve

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
if [ -f "cloudreve" ]; then
    echo -e "Dimensione: ${YELLOW}$(du -h cloudreve | cut -f1)${NC}"
fi
