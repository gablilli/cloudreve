# Documentazione Italiana di Cloudreve

Questa directory contiene documentazione in italiano per Cloudreve.

## Guide Disponibili

### 🚀 [Guida Rapida](./QUICK_START_IT.md)
Inizia subito! Guida veloce per:
- Abilitare l'editing online con Office in 3 passi (10 minuti)
- Compilazione rapida del backend
- FAQ e troubleshooting rapido

### 🎨 [Guida Visuale](./VISUAL_GUIDE_IT.md)
Diagrammi e illustrazioni per capire meglio:
- Architettura del sistema con diagrammi ASCII
- Flusso di lavoro completo (sequenza)
- Setup produzione Docker visualizzato
- Troubleshooting con diagrammi di flusso

### [Configurazione WOPI per Office Online](./WOPI_SETUP_IT.md)
Guida completa per configurare l'editing online dei documenti Office utilizzando il protocollo WOPI. Include:
- Installazione di server WOPI (Collabora Online, Office Online Server, ONLYOFFICE)
- Configurazione in Cloudreve
- Risoluzione dei problemi comuni
- Best practices per la sicurezza

### [Esempi di Configurazione](./EXAMPLES_IT.md)
Esempi pratici e pronti all'uso per diversi scenari:
- Setup locale per test con Docker
- Configurazione produzione con SSL/TLS e Nginx
- Multi-tenant con isolamento
- Script di deploy automatizzato
- Monitoraggio e troubleshooting

### [Istruzioni per la Compilazione](./BUILD_INSTRUCTIONS_IT.md)
Guida dettagliata per compilare Cloudreve dal codice sorgente. Include:
- Requisiti software
- Compilazione completa (frontend + backend)
- Compilazione cross-platform
- Script di automazione
- Risoluzione dei problemi di build

## Funzionalità WOPI Già Disponibili

**Importante:** Il supporto WOPI è già implementato in Cloudreve! Non è necessaria alcuna modifica al codice.

Le seguenti funzionalità WOPI sono già disponibili:

### Endpoint API
- `GET /api/v4/file/wopi/:id` - Ottieni informazioni sul file
- `GET /api/v4/file/wopi/:id/contents` - Ottieni contenuto del file
- `POST /api/v4/file/wopi/:id/contents` - Aggiorna contenuto del file
- `POST /api/v4/file/wopi/:id` - Operazioni sul file (lock, unlock, refresh)

### Operazioni Supportate
- **Lock/Unlock** - Blocca i file durante l'editing per evitare conflitti
- **RefreshLock** - Rinnova il lock per sessioni di editing lunghe
- **PutRelative** - Crea nuove versioni del file
- **GetFile** - Scarica contenuto del file per l'editing
- **PutFile** - Salva modifiche al file

### Gestione delle Sessioni
- Sessioni viewer con token di accesso temporanei
- Timeout automatico delle sessioni
- Supporto per più utenti simultanei

### Sicurezza
- Validazione delle sessioni viewer
- Hash ID per proteggere gli identificatori dei file
- Lock file per evitare modifiche concorrenti

## Come Iniziare

1. **Configura un Server WOPI**
   - Consulta [WOPI_SETUP_IT.md](./WOPI_SETUP_IT.md) per le istruzioni complete
   - Consigliamo Collabora Online per la facilità di installazione

2. **Configura Cloudreve**
   - Accedi come admin
   - Vai su Impostazioni → Strumenti → WOPI
   - Inserisci l'URL di discovery del tuo server WOPI

3. **Inizia a Modificare**
   - Apri qualsiasi documento Office
   - Vedrai l'opzione per modificarlo online

## Compilare una Versione Personalizzata

Se vuoi modificare il codice o compilare una versione personalizzata:

```bash
# Clona il repository
git clone https://github.com/gablilli/cloudreve.git
cd cloudreve

# Usa lo script di build incluso
chmod +x build.sh
./build.sh 4.7.0-mia-versione

# Oppure segui la guida completa
# Vedi docs/BUILD_INSTRUCTIONS_IT.md
```

## Architettura WOPI in Cloudreve

```
┌─────────────┐         ┌──────────────┐         ┌────────────────┐
│   Browser   │◄───────►│  Cloudreve   │◄───────►│  WOPI Server   │
│   (User)    │         │   Server     │         │ (Collabora/MS) │
└─────────────┘         └──────────────┘         └────────────────┘
      │                        │                          │
      │  1. Apri documento     │                          │
      │───────────────────────►│                          │
      │                        │                          │
      │  2. Crea viewer session│                          │
      │◄───────────────────────│                          │
      │                        │                          │
      │  3. Carica editor WOPI │                          │
      │────────────────────────┼─────────────────────────►│
      │                        │                          │
      │  4. Richiedi file info │                          │
      │                        │◄─────────────────────────│
      │                        │  GET /wopi/:id           │
      │                        │                          │
      │  5. Scarica contenuto  │                          │
      │                        │◄─────────────────────────│
      │                        │  GET /wopi/:id/contents  │
      │                        │                          │
      │  6. Editing...         │                          │
      │◄──────────────────────►│                          │
      │                        │                          │
      │  7. Salva modifiche    │                          │
      │                        │◄─────────────────────────│
      │                        │  POST /wopi/:id/contents │
```

## File Rilevanti nel Codice

Se vuoi esplorare o modificare l'implementazione WOPI:

- `routers/controllers/wopi.go` - Controller WOPI
- `service/explorer/viewer.go` - Logica business WOPI
- `pkg/wopi/` - Package WOPI (discovery, tipi, utilità)
- `middleware/wopi.go` - Middleware per validazione sessioni
- `pkg/filemanager/lock/` - Sistema di lock per editing concorrente

## Contribuire

Se vuoi contribuire miglioramenti al supporto WOPI:

1. Fork del repository
2. Crea un branch per la tua feature
3. Implementa le modifiche
4. Testa accuratamente
5. Invia una Pull Request

## Domande Frequenti (FAQ)

**Q: Devo modificare il codice per abilitare WOPI?**  
A: No! Il supporto WOPI è già completamente implementato. Devi solo configurare un server WOPI esterno.

**Q: Quale server WOPI dovrei usare?**  
A: Per uso personale o piccole organizzazioni, consigliamo Collabora Online (LibreOffice Online) perché è gratuito e open source.

**Q: Il WOPI funziona con tutti i formati di file?**  
A: Dipende dal server WOPI che usi. Collabora supporta .doc, .docx, .xls, .xlsx, .ppt, .pptx, .odt, .ods, .odp e altri formati OpenDocument.

**Q: Posso usare WOPI senza HTTPS?**  
A: Tecnicamente sì, ma è **fortemente sconsigliato** per la sicurezza. In produzione, usa sempre HTTPS.

**Q: Il file locking è automatico?**  
A: Sì, quando un utente apre un file in modalità edit, viene automaticamente bloccato per 30 minuti. Il lock viene rinnovato automaticamente durante l'editing.

## Supporto

- [Documentazione ufficiale Cloudreve](https://docs.cloudreve.org/)
- [GitHub Issues](https://github.com/cloudreve/Cloudreve/issues)
- [Discussions](https://github.com/cloudreve/cloudreve/discussions)
- [Telegram](https://t.me/cloudreve_official)
- [Discord](https://discord.com/invite/WTpMFpZT76)

## Licenza

Cloudreve è rilasciato sotto licenza GPL v3. Vedi [LICENSE](../LICENSE) per i dettagli.
