# Guida Rapida - WOPI e Compilazione

## Editing Online con Office - È Già Disponibile! 🎉

**Buone notizie:** Il supporto WOPI per l'editing online dei documenti Office è **già completamente implementato** in Cloudreve. Non serve modificare nulla nel codice!

### Cosa Devi Fare

Solo 3 passi:

#### 1. Installa un Server WOPI (5 minuti)

Il modo più semplice è usare **Collabora Online** con Docker:

```bash
docker run -t -d -p 9980:9980 \
  -e "aliasgroup1=https://tuo-dominio.com:443" \
  -e "username=admin" \
  -e "password=SecurePassword123" \
  --restart always \
  --name collabora \
  collabora/code
```

**Importante:** Sostituisci `tuo-dominio.com` con il dominio dove gira Cloudreve.

#### 2. Configura Cloudreve (2 minuti)

1. Accedi come amministratore
2. Vai a: **Dashboard Admin** → **Strumenti** → **WOPI**
3. Inserisci l'URL: `http://localhost:9980/hosting/discovery` (o l'URL del tuo server Collabora)
4. Clicca **Recupera**
5. Abilita i visualizzatori che vuoi usare

#### 3. Prova! (30 secondi)

1. Carica o apri un file .docx, .xlsx, o .pptx
2. Clicca sul file
3. Dovrebbe aprirsi nell'editor online!

### Risoluzione Rapida dei Problemi

**Non funziona?**

1. **Verifica che Collabora sia in esecuzione:**
   ```bash
   docker ps | grep collabora
   curl http://localhost:9980/hosting/discovery
   ```

2. **Controlla i domini:** Il parametro `aliasgroup1` deve includere il dominio di Cloudreve

3. **Controlla i log:**
   ```bash
   docker logs collabora
   ```

---

## Compilare Cloudreve (Opzionale)

### Quando Compilare?

Devi compilare solo se:
- Vuoi modificare il codice sorgente
- Vuoi una versione personalizzata
- Stai sviluppando nuove funzionalità

**Per l'uso normale, scarica semplicemente il binario precompilato dalle [release ufficiali](https://github.com/cloudreve/Cloudreve/releases).**

### Compilazione Veloce (Solo Backend)

Se hai già il file `assets.zip` o stai solo modificando il backend:

```bash
# Clona il repo
git clone https://github.com/gablilli/cloudreve.git
cd cloudreve

# Compila
go build -o cloudreve \
  -ldflags="-s -w -X 'github.com/cloudreve/Cloudreve/v4/application/constants.BackendVersion=4.7.0-custom'"

# Esegui
./cloudreve
```

### Compilazione Completa (Backend + Frontend)

**Nota:** Richiede il submodule `assets` che contiene il frontend React.

```bash
# Clona con submodules
git clone --recurse-submodules https://github.com/gablilli/cloudreve.git
cd cloudreve

# Usa lo script di build
chmod +x build.sh
./build.sh 4.7.0-mia-versione
```

Se il submodule non è presente, puoi inizializzarlo:

```bash
git submodule update --init --recursive
```

### Compilazione Cross-Platform

Per compilare per un altro sistema operativo:

```bash
# Windows
GOOS=windows GOARCH=amd64 go build -o cloudreve.exe

# macOS
GOOS=darwin GOARCH=amd64 go build -o cloudreve-mac

# Linux ARM (es. Raspberry Pi)
GOOS=linux GOARCH=arm64 go build -o cloudreve-arm64
```

---

## Struttura dei File

```
cloudreve/
├── build.sh                    # Script di build automatico
├── docs/
│   ├── README_IT.md           # Indice documentazione italiana
│   ├── WOPI_SETUP_IT.md       # Guida WOPI completa
│   ├── BUILD_INSTRUCTIONS_IT.md # Istruzioni build dettagliate
│   └── QUICK_START_IT.md      # Questa guida
├── routers/
│   └── controllers/
│       └── wopi.go            # Controller WOPI
├── service/
│   └── explorer/
│       └── viewer.go          # Logica WOPI
├── pkg/
│   └── wopi/                  # Package WOPI
└── application/
    └── statics/
        └── assets.zip         # Frontend compilato
```

---

## Link Utili

- 📚 [Documentazione Completa WOPI](./WOPI_SETUP_IT.md)
- 🔨 [Istruzioni Build Dettagliate](./BUILD_INSTRUCTIONS_IT.md)
- 📖 [Documentazione Italiana](./README_IT.md)
- 🌐 [Documentazione Ufficiale](https://docs.cloudreve.org/)

---

## Server WOPI Consigliati

### Per Uso Personale/Piccole Organizzazioni
- **Collabora Online CODE** (Gratuito, Open Source)
  - Facile da installare con Docker
  - Supporta tutti i formati Office e OpenDocument
  - Buone prestazioni

### Per Uso Aziendale
- **Collabora Online Enterprise** (A pagamento)
  - Supporto professionale
  - Più funzionalità
  
- **Microsoft Office Online Server** (Richiede licenze Microsoft)
  - Migliore compatibilità con formati Microsoft
  - Richiede Windows Server

### Alternative
- **ONLYOFFICE Document Server**
  - Supporto WOPI limitato
  - Ha il suo protocollo nativo (più semplice)

---

## FAQ Rapida

**Q: Devo pagare qualcosa?**  
A: No! Collabora Online CODE è completamente gratuito e open source. Cloudreve stesso è open source.

**Q: Funziona su Raspberry Pi?**  
A: Sì! Puoi compilare Cloudreve per ARM. Collabora potrebbe essere più pesante, considera alternative più leggere.

**Q: Posso editare file in più persone contemporaneamente?**  
A: Sì! WOPI supporta l'editing collaborativo. Più utenti possono modificare lo stesso file.

**Q: È sicuro?**  
A: Sì, se usi HTTPS. Per la produzione, configura sempre SSL/TLS sia per Cloudreve che per il server WOPI.

**Q: Quanta RAM serve?**  
A: 
- Cloudreve: ~100-500 MB
- Collabora Online: ~2-4 GB
- Totale consigliato: 4+ GB RAM

---

## Supporto

Hai problemi? Chiedi aiuto:

- [GitHub Discussions](https://github.com/cloudreve/cloudreve/discussions)
- [Telegram](https://t.me/cloudreve_official)
- [Discord](https://discord.com/invite/WTpMFpZT76)

**Ricorda:** Il supporto WOPI è già nel codice. Se qualcosa non funziona, è probabilmente un problema di configurazione del server WOPI, non di Cloudreve! 😊
