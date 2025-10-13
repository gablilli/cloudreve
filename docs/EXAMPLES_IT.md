# Esempi di Configurazione WOPI

Questa guida fornisce esempi pratici di configurazione per diversi scenari di utilizzo di WOPI con Cloudreve.

## Scenario 1: Setup Locale per Test (Docker)

### Collabora Online + Cloudreve in Locale

```bash
# 1. Avvia Collabora Online
docker run -t -d -p 9980:9980 \
  -e "aliasgroup1=http://localhost:8080" \
  -e "username=admin" \
  -e "password=admin123" \
  --name collabora \
  collabora/code

# 2. Avvia Cloudreve
./cloudreve

# 3. Configura in Cloudreve
# Endpoint WOPI: http://localhost:9980/hosting/discovery
```

**Nota:** Questo è solo per test. Per produzione usa sempre HTTPS!

## Scenario 2: Produzione con SSL/TLS

### Setup con Nginx come Reverse Proxy

#### docker-compose.yml

```yaml
version: '3'
services:
  cloudreve:
    image: cloudreve/cloudreve:latest
    ports:
      - "5212:5212"
    volumes:
      - ./cloudreve/uploads:/cloudreve/uploads
      - ./cloudreve/config:/cloudreve/config
      - ./cloudreve/db:/cloudreve/db
    restart: always

  collabora:
    image: collabora/code
    ports:
      - "9980:9980"
    environment:
      - aliasgroup1=https://files.tuodominio.com:443
      - username=admin
      - password=${COLLABORA_PASSWORD}
      - extra_params=--o:ssl.enable=false --o:ssl.termination=true
    restart: always
    cap_add:
      - MKNOD

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
    depends_on:
      - cloudreve
      - collabora
    restart: always
```

#### nginx.conf

```nginx
events {
    worker_connections 1024;
}

http {
    # Configurazione SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Server per Cloudreve
    server {
        listen 443 ssl http2;
        server_name files.tuodominio.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        client_max_body_size 20G;

        location / {
            proxy_pass http://cloudreve:5212;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    # Server per Collabora Online
    server {
        listen 443 ssl http2;
        server_name office.tuodominio.com;

        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;

        # WebSocket configuration
        location / {
            proxy_pass http://collabora:9980;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;

            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            
            # Timeouts
            proxy_read_timeout 3600s;
            proxy_connect_timeout 3600s;
            proxy_send_timeout 3600s;
        }
    }

    # Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name files.tuodominio.com office.tuodominio.com;
        return 301 https://$host$request_uri;
    }
}
```

#### Configurazione WOPI in Cloudreve

```
Endpoint WOPI: https://office.tuodominio.com/hosting/discovery
```

## Scenario 3: ONLYOFFICE Document Server

### docker-compose.yml con ONLYOFFICE

```yaml
version: '3'
services:
  cloudreve:
    image: cloudreve/cloudreve:latest
    ports:
      - "5212:5212"
    volumes:
      - ./cloudreve/uploads:/cloudreve/uploads
      - ./cloudreve/config:/cloudreve/config
      - ./cloudreve/db:/cloudreve/db
    restart: always

  onlyoffice:
    image: onlyoffice/documentserver
    ports:
      - "8080:80"
      - "8443:443"
    environment:
      - JWT_ENABLED=true
      - JWT_SECRET=${ONLYOFFICE_JWT_SECRET}
      - JWT_HEADER=Authorization
    volumes:
      - ./onlyoffice/data:/var/www/onlyoffice/Data
      - ./onlyoffice/logs:/var/log/onlyoffice
    restart: always
```

**Nota:** ONLYOFFICE ha supporto WOPI limitato. Potrebbe essere necessario usare l'integrazione nativa ONLYOFFICE invece di WOPI.

## Scenario 4: Microsoft Office Online Server

### Requisiti

- Windows Server 2016 o superiore
- Office Online Server installato
- Certificato SSL valido
- Licenza Office valida

### Configurazione Office Online Server

```powershell
# Installa Office Online Server
# Vedi: https://docs.microsoft.com/en-us/officeonlineserver/deploy-office-online-server

# Crea farm Office Online Server
New-OfficeWebAppsFarm `
    -InternalUrl "https://office.azienda.local" `
    -ExternalUrl "https://office.azienda.com" `
    -CertificateName "Office Online Server Certificate" `
    -EditingEnabled

# Aggiungi dominio Cloudreve alla allowlist
New-OfficeWebAppsHost -Domain "files.azienda.com"
```

### Configurazione WOPI in Cloudreve

```
Endpoint WOPI: https://office.azienda.com/hosting/discovery
```

## Scenario 5: Multi-Tenant con Isolamento

### Configurazione per Più Organizzazioni

```yaml
version: '3'
services:
  # Cloudreve per Organizzazione A
  cloudreve_org_a:
    image: cloudreve/cloudreve:latest
    ports:
      - "5212:5212"
    volumes:
      - ./org_a/uploads:/cloudreve/uploads
      - ./org_a/config:/cloudreve/config
      - ./org_a/db:/cloudreve/db
    environment:
      - SITE_NAME=Org A Files
    restart: always

  # Cloudreve per Organizzazione B
  cloudreve_org_b:
    image: cloudreve/cloudreve:latest
    ports:
      - "5213:5212"
    volumes:
      - ./org_b/uploads:/cloudreve/uploads
      - ./org_b/config:/cloudreve/config
      - ./org_b/db:/cloudreve/db
    environment:
      - SITE_NAME=Org B Files
    restart: always

  # Collabora condiviso
  collabora:
    image: collabora/code
    ports:
      - "9980:9980"
    environment:
      - aliasgroup1=https://files-a.esempio.com:443,https://files-b.esempio.com:443
      - username=admin
      - password=${COLLABORA_PASSWORD}
    restart: always
```

## Variabili d'Ambiente Utili

### Collabora Online

```bash
# Domini consentiti (separa con virgola)
aliasgroup1=https://dominio1.com:443,https://dominio2.com:443

# Credenziali admin
username=admin
password=SecurePassword123

# Disabilita SSL (se dietro reverse proxy)
extra_params=--o:ssl.enable=false --o:ssl.termination=true

# Limita connessioni simultanee
extra_params=--o:user_interface.mode=classic --o:num_prespawn_children=4

# Abilita logging debug
extra_params=--o:logging.level=debug
```

### ONLYOFFICE

```bash
# Abilita JWT
JWT_ENABLED=true
JWT_SECRET=TuoSecretMoltoSicuro123

# Header JWT personalizzato
JWT_HEADER=Authorization

# Lingua di default
DEFAULT_LANGUAGE=it-IT

# Tema
DEFAULT_THEME=theme-dark
```

## Script di Deploy Automatizzato

### deploy-wopi.sh

```bash
#!/bin/bash
set -e

# Configurazione
DOMAIN="${1:-files.tuodominio.com}"
OFFICE_DOMAIN="${2:-office.tuodominio.com}"
EMAIL="${3:-admin@tuodominio.com}"

echo "Deploying WOPI setup for $DOMAIN"

# 1. Installa Docker se non presente
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    systemctl enable docker
    systemctl start docker
fi

# 2. Installa Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 3. Crea directory
mkdir -p nginx/ssl
mkdir -p cloudreve/{uploads,config,db}

# 4. Ottieni certificati Let's Encrypt
if [ ! -f "nginx/ssl/fullchain.pem" ]; then
    echo "Obtaining SSL certificates..."
    docker run -it --rm \
        -v "$(pwd)/nginx/ssl:/etc/letsencrypt" \
        certbot/certbot certonly --standalone \
        -d "$DOMAIN" -d "$OFFICE_DOMAIN" \
        --email "$EMAIL" --agree-tos --no-eff-email
    
    cp nginx/ssl/live/$DOMAIN/fullchain.pem nginx/ssl/
    cp nginx/ssl/live/$DOMAIN/privkey.pem nginx/ssl/
fi

# 5. Crea configurazione
cat > .env <<EOF
COLLABORA_PASSWORD=$(openssl rand -base64 32)
DOMAIN=$DOMAIN
OFFICE_DOMAIN=$OFFICE_DOMAIN
EOF

# 6. Avvia servizi
docker-compose up -d

echo ""
echo "✓ Deploy completato!"
echo ""
echo "Configurazione WOPI in Cloudreve:"
echo "  Endpoint: https://$OFFICE_DOMAIN/hosting/discovery"
echo ""
echo "Accedi a Cloudreve: https://$DOMAIN"
echo "Credenziali Collabora admin: admin / $(grep COLLABORA_PASSWORD .env | cut -d= -f2)"
```

## Monitoraggio e Debugging

### Comandi Utili

```bash
# Visualizza log Collabora
docker logs -f collabora

# Visualizza log Cloudreve
docker logs -f cloudreve

# Controlla stato servizi
docker-compose ps

# Testa endpoint WOPI discovery
curl -s http://localhost:9980/hosting/discovery | head -20

# Monitora uso risorse
docker stats

# Riavvia Collabora
docker restart collabora

# Pulisci cache Collabora
docker exec collabora coolforkit --cleanup
```

### Debug WOPI in Cloudreve

Abilita logging debug nel file `conf.ini`:

```ini
[System]
; Debug mode
Debug = true
; Log level
Level = debug
```

## Ottimizzazione Prestazioni

### Collabora Online

```bash
# Aumenta numero di processi pre-spawn
docker run ... \
  -e "extra_params=--o:num_prespawn_children=10" \
  collabora/code

# Limita memoria per documento
docker run ... \
  -e "extra_params=--o:per_document.max_concurrency=4" \
  collabora/code

# Timeout più breve per documenti inattivi
docker run ... \
  -e "extra_params=--o:per_document.idle_timeout_secs=900" \
  collabora/code
```

### Nginx Cache

```nginx
# Aggiungi cache per risorse statiche
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=static_cache:10m max_size=1g;

location ~* \.(js|css|png|jpg|jpeg|gif|ico|woff|woff2)$ {
    proxy_cache static_cache;
    proxy_cache_valid 200 1d;
    proxy_pass http://cloudreve:5212;
}
```

## Backup

### Script di Backup

```bash
#!/bin/bash
BACKUP_DIR="/backup/cloudreve-$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Backup database e configurazione Cloudreve
tar czf "$BACKUP_DIR/cloudreve.tar.gz" cloudreve/

# Backup volumi Docker
docker run --rm \
    -v cloudreve_uploads:/data \
    -v "$BACKUP_DIR":/backup \
    alpine tar czf /backup/uploads.tar.gz /data

echo "Backup completato in $BACKUP_DIR"
```

## Troubleshooting

### Problema: "WOPI discovery failed"

```bash
# Verifica connettività
curl -I http://localhost:9980/hosting/discovery

# Controlla log Collabora
docker logs collabora | grep -i error

# Verifica che Collabora sia in ascolto
netstat -tlnp | grep 9980
```

### Problema: "Unable to load document"

```bash
# Verifica che il dominio Cloudreve sia nella allowlist
docker logs collabora | grep -i "allowed"

# Aggiungi dominio manualmente
docker exec collabora \
    coolconfig set net.post_allow.host "files.tuodominio.com"
```

## Riferimenti

- [Collabora Online Admin Console](https://localhost:9980/browser/dist/admin/admin.html)
- [Documentazione WOPI Microsoft](https://docs.microsoft.com/en-us/microsoft-365/cloud-storage-partner-program/rest/)
- [Collabora Online Documentation](https://sdk.collaboraonline.com/)
- [ONLYOFFICE API](https://api.onlyoffice.com/)
