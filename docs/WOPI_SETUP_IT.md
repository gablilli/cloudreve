# Configurazione WOPI per l'Editing Online con Office

Cloudreve ha già il supporto integrato per WOPI (Web Application Open Platform Interface Protocol), che consente l'editing online dei file con Microsoft Office Online, LibreOffice Online (Collabora), ONLYOFFICE e altri client compatibili WOPI.

## Cos'è WOPI?

WOPI è un protocollo che consente alle applicazioni web di interagire con i server di archiviazione file. Permette l'editing collaborativo in tempo reale dei documenti Office direttamente nel browser.

## Requisiti

1. **Cloudreve** - Già installato e funzionante
2. **Server WOPI compatibile** - Scegli uno tra:
   - **Microsoft Office Online Server** (solo per uso aziendale con licenza)
   - **LibreOffice Online / Collabora Online** (open source, consigliato)
   - **ONLYOFFICE Document Server** (supporta WOPI con configurazione aggiuntiva)

## Opzioni per il Server WOPI

### Opzione 1: Collabora Online (Consigliato - Open Source)

Collabora Online è basato su LibreOffice ed è completamente open source.

#### Installazione con Docker

```bash
# Installa Collabora Online CODE (Community version)
docker run -t -d -p 9980:9980 \
  -e "aliasgroup1=https://tuo-dominio.com:443" \
  -e "username=admin" \
  -e "password=TuaPasswordSicura" \
  --name collabora \
  collabora/code
```

**Nota:** Sostituisci `tuo-dominio.com` con il dominio dove Cloudreve è in esecuzione.

#### URL Discovery di Collabora

Dopo l'installazione, l'endpoint di discovery sarà disponibile a:
```
https://tuo-server-collabora.com/hosting/discovery
```

### Opzione 2: Microsoft Office Online Server

Richiede:
- Windows Server
- Licenza Microsoft Office valida
- Configurazione più complessa

**Nota:** Non consigliato per uso personale a causa dei requisiti di licenza.

### Opzione 3: ONLYOFFICE Document Server

ONLYOFFICE ha il suo protocollo nativo, ma può essere configurato per supportare WOPI.

```bash
# Installa ONLYOFFICE con Docker
docker run -i -t -d -p 80:80 \
  -e JWT_ENABLED=true \
  -e JWT_SECRET=TuoSecretJWT \
  --name onlyoffice \
  onlyoffice/documentserver
```

## Configurazione in Cloudreve

### Passo 1: Accedi come Amministratore

1. Accedi a Cloudreve con un account amministratore
2. Vai al pannello di amministrazione

### Passo 2: Configura il Server WOPI

1. Nel pannello admin, vai su **Impostazioni** → **Strumenti** → **WOPI**
2. Inserisci l'URL dell'endpoint di discovery del tuo server WOPI:
   - Per Collabora: `https://tuo-server-collabora.com/hosting/discovery`
   - Per Office Online: `https://tuo-office-online-server.com/hosting/discovery`

3. Fai clic su **Recupera** per ottenere le configurazioni dei visualizzatori supportati

### Passo 3: Abilita i Visualizzatori

Dopo aver recuperato con successo le configurazioni WOPI:
1. Vai su **Impostazioni** → **Visualizzatori**
2. Vedrai i nuovi visualizzatori per i formati Office (.docx, .xlsx, .pptx, ecc.)
3. Attiva i visualizzatori che desideri utilizzare

## Utilizzo

Una volta configurato:

1. **Visualizzazione dei File**: 
   - Clicca su qualsiasi file Office (.docx, .xlsx, .pptx, ecc.)
   - Si aprirà automaticamente nel visualizzatore online

2. **Modifica dei File**:
   - Clicca sull'icona di modifica
   - Il file si aprirà in modalità modifica
   - Le modifiche vengono salvate automaticamente

## Formati di File Supportati

A seconda del server WOPI, sono tipicamente supportati:

### Documenti di Testo
- .docx, .doc
- .odt
- .rtf

### Fogli di Calcolo
- .xlsx, .xls
- .ods
- .csv

### Presentazioni
- .pptx, .ppt
- .odp

## Risoluzione dei Problemi

### Problema: "Endpoint WOPI non disponibile"

**Soluzione:**
1. Verifica che il server WOPI sia in esecuzione
2. Controlla che l'URL dell'endpoint sia corretto
3. Assicurati che Cloudreve possa raggiungere il server WOPI (firewall, rete)

### Problema: "Impossibile caricare il documento"

**Soluzione:**
1. Controlla i log del server WOPI
2. Verifica che il dominio di Cloudreve sia nella allowlist del server WOPI
3. Per Collabora, assicurati che il parametro `aliasgroup1` includa il tuo dominio

### Problema: "Impossibile salvare le modifiche"

**Soluzione:**
1. Verifica che l'utente abbia i permessi di scrittura sul file
2. Controlla che il file non sia bloccato da un altro utente
3. Verifica i log di Cloudreve per errori di lock o permessi

## Configurazione SSL/TLS

Per la produzione, è **fortemente consigliato** utilizzare HTTPS per entrambi:
- Server Cloudreve
- Server WOPI

Esempio con Let's Encrypt e Nginx come reverse proxy per Collabora:

```nginx
server {
    listen 443 ssl;
    server_name collabora.tuo-dominio.com;

    ssl_certificate /etc/letsencrypt/live/collabora.tuo-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/collabora.tuo-dominio.com/privkey.pem;

    location / {
        proxy_pass http://localhost:9980;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeout settings
        proxy_read_timeout 3600s;
        proxy_connect_timeout 3600s;
        proxy_send_timeout 3600s;
    }
}
```

## Configurazione Avanzata

### Timeout dei Lock

I file in fase di modifica vengono bloccati automaticamente per 30 minuti. Questo può essere configurato nel codice se necessario.

### Sessioni dei Visualizzatori

Le sessioni scadono dopo un certo periodo. Gli utenti devono riaprire il file se la sessione scade.

## Sicurezza

1. **Sempre usa HTTPS** in produzione
2. **Configura un firewall** per limitare l'accesso al server WOPI
3. **Usa password forti** per l'amministrazione del server WOPI
4. **Abilita JWT/autenticazione** se supportato dal tuo server WOPI
5. **Esegui backup regolari** dei tuoi file

## Riferimenti

- [Protocollo WOPI di Microsoft](https://docs.microsoft.com/en-us/microsoft-365/cloud-storage-partner-program/rest/)
- [Collabora Online](https://www.collaboraoffice.com/)
- [ONLYOFFICE](https://www.onlyoffice.com/)
- [Documentazione Cloudreve](https://docs.cloudreve.org/)
