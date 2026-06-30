# GDM Linux - Documentación Técnica

## Índice

1. [Descripción General](#descripción-general)
2. [Estructura del Rol](#estructura-del-rol)
3. [Flujo de Ejecución](#flujo-de-ejecución)
4. [Archivos de Estado (.asb)](#archivos-de-estado-asb)
5. [Tareas Disponibles](#tareas-disponibles)
6. [Variables](#variables)
7. [Scripts](#scripts)
8. [Programas Producto y Aplicaciones](#programas-producto-y-aplicaciones)
9. [Prerrequisitos](#prerrequisitos)
10. [Troubleshooting](#troubleshooting)

---

## Descripción General

El rol `role_gdm_linux` gestiona el proceso de **IPL (Initial Program Load / Reinicio)** controlado de servidores Linux durante actualizaciones de parches del sistema operativo. Automatiza:

- Captura de evidencias del estado del sistema (fotos)
- Gestión de Programas Producto (PP) y Aplicaciones
- Coordinación con sistemas de monitoreo (BlackOut/BlackIn)
- Reinicio seguro del servidor
- Validación post-reinicio

### Sistemas Operativos Soportados

| SSOO | Versiones |
|------|-----------|
| Red Hat Enterprise Linux | 7, 8, 9 |
| SUSE Linux Enterprise | 12, 15 |

---

## Estructura del Rol

```
role_gdm_linux/
├── main.yml                    # Entry point del rol
├── README.md                   # Documentación de usuario
├── TECHNICAL_README.md         # Este archivo
│
├── default/
│   └── main.yml                # Variables por defecto (vacío)
│
├── vars/
│   └── main.yml                # Variables del rol
│
├── files/
│   ├── main.yml
│   ├── pps_aps_status.sh
│   └── gdm/
│       ├── pps_status_posterior_os_ipl.sh
│       ├── pps_status_previa_os_ipl.sh
│       ├── ssoo_pps_aps_status.sh
│       ├── pre/                # Scripts para foto previa
│       │   ├── pp_status.sh    # Estado de Programas Producto
│       │   ├── aps_status.sh   # Estado de Aplicaciones
│       │   └── report_pp_aps.sh
│       ├── inter/              # Scripts para foto intermedia
│       │   └── report_pp_aps.sh
│       ├── post/               # Scripts para foto posterior
│       │   └── report_pp_aps.sh
│       ├── start/              # Scripts de arranque
│       │   ├── aps_sart.sh
│       │   └── pp_start.sh
│       └── stop/               # Scripts de parada
│           ├── aps_stop.sh
│           └── pp_stop.sh
│
├── tasks/
│   ├── main.yml                # Dispatcher principal
│   ├── 0_Crear_snapshot.yml    # Crea snapshot previo al IPL
│   ├── 1_BlackOut_PatrolAgentes.yml
│   ├── 2_Uptime_previo_IPL.yml
│   ├── 3_Foto_previa_IPL.yml
│   ├── 4_Baja_Programas_Producto_Aplicaciones.yml
│   ├── 5_Foto_intermedia.yml
│   ├── 6_IPL_Total.yml         # Flujo completo automatizado
│   ├── 7_Alta_Programas_Producto_Aplicaciones.yml
│   ├── 8_Foto_posterior_IPL.yml
│   ├── 9_Uptime_posterior_IPL.yml
│   ├── 10_Reiniciar_OS_Linux.yml
│   ├── 11_Actualizar_parches_RHEL.yml
│   ├── 12_BlackIn_PatrolAgentes.yml
│   ├── check_blackin.yml
│   ├── check_blackout.yml
│   ├── Comparar_fotos_IPL.yml
│   ├── crea_repositorio_mail.yml
│   ├── Enviar_evidencia_*.yml  # Tareas de envío de evidencias
│   ├── gdm_ipl_linux.yml
│   ├── gdm_ipl_na.yml
│   ├── gdm_parches_na.yml
│   ├── gdm_parches_rhel.yml
│   │
│   ├── altas_ppaps/            # Alta de servicios
│   │   ├── alta_patrol.yml
│   │   ├── alta_capacity.yml
│   │   ├── alta_controlm.yml
│   │   ├── alta_dimensions.yml
│   │   ├── alta_connectdirect.yml
│   │   └── reiniciar_*.yml
│   │
│   └── bajas_ppaps/            # Baja de servicios
│       ├── baja_patrol.yml
│       ├── baja_capacity.yml
│       ├── baja_controlm.yml
│       ├── baja_dimensions.yml
│       ├── baja_connectdirect.yml
│       └── baja_sentinelone.yml
│
├── templates/
│   └── main.yml
│
├── handlers/
│   └── main.yml
│
├── meta/
│   └── main.yml
│
└── imagenes/                   # Screenshots para documentación
```

---

## Flujo de Ejecución

### Flujo Principal (6_IPL_Total)

```
┌────────────────────────────────────────────────────────────────────────────────┐
│                           INICIO - Validación CRQ/INC/REQ                      │
│                    (Formato: CRQ|INC|REQ + 12 dígitos numéricos)               │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  1. BlackOut PatrolAgentes                                                     │
│     └── Silencia alertas de monitoreo para evitar falsas alarmas               │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  3. Foto Previa IPL                                                            │
│     ├── Copia scripts: pp_status.sh, aps_status.sh, report_pp_aps.sh           │
│     ├── Ejecuta scripts para detectar servicios activos                        │
│     ├── Genera archivos .asb (marcadores de estado)                            │
│     └── Guarda: {CRQ}__{hostname}_{IP}_foto_sso_pp_aps_previa.txt              │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  4. Baja Programas Producto y Aplicaciones                                     │
│     ├── Verifica existencia de archivos .asb                                   │
│     ├── Programas Producto:                                                    │
│     │   ├── PatrolAgent    (patrol.asb)                                        │
│     │   ├── CapacityAgent  (capacity.asb)                                      │
│     │   ├── ControlM       (ctm.asb)                                           │
│     │   ├── Dimensions     (dim.asb)                                           │
│     │   └── ConnectDirect  (cd.asb)                                            │
│     └── Aplicaciones:                                                          │
│         ├── HTTPServer 80/85/90 (standalone y dedicados)                       │
│         ├── WebSphere 80/85/90                                                 │
│         └── MQ 80/90/93                                                        │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  5. Foto Intermedia                                                            │
│     └── Captura estado después de bajar servicios (validación)                 │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  REBOOT (IPL)                                                                  │
│     ├── Módulo Ansible: reboot                                                 │
│     ├── Timeout: 3600 segundos                                                 │
│     └── Espera reconexión automática                                           │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  7. Alta Programas Producto y Aplicaciones                                     │
│     ├── Inicia servicios detectados en la foto previa                          │
│     └── Usa archivos .asb como referencia                                      │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  8. Foto Posterior IPL                                                         │
│     └── Guarda: {CRQ}_{hostname}_{IP}_foto_sso_pp_aps_posterior.txt            │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│  12. BlackIn PatrolAgentes                                                     │
│      └── Reactiva alertas de monitoreo                                         │
└────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌────────────────────────────────────────────────────────────────────────────────┐
│                              FIN - Reporte de Ejecución                        │
│                         (Hostname, IP, Uptime posterior)                       │
└────────────────────────────────────────────────────────────────────────────────┘
```

### Dispatcher Principal (tasks/main.yml)

```yaml
- name: Ejecutando tarea GDM Linux
  include_tasks: "{{ tarea }}.yml"
```

El playbook recibe la variable `tarea` que determina qué archivo de tareas ejecutar.

---

## Archivos de Estado (.asb)

Los archivos `.asb` son **marcadores de estado** que indican qué servicios estaban activos antes del IPL y deben ser reiniciados después. Se almacenan en `/var/opt/ansible/`.

### Programas Producto

| Archivo | Servicio | Contenido |
|---------|----------|-----------|
| `patrol.asb` | PatrolAgent | `ACTIVO` |
| `capacity.asb` | Capacity Agent (BGS) | `ACTIVO` |
| `ctm.asb` | Control-M Agent | `ACTIVO` |
| `dim.asb` | Dimensions | `{versión},ACTIVO` |
| `cd.asb` | Connect:Direct | `ACTIVO` |
| `s1.asb` | SentinelOne | `ACTIVO` (comentado) |

### Aplicaciones - WebSphere

| Archivo | Servicio |
|---------|----------|
| `websphere80.asb` | WebSphere 8.0 |
| `websphere85.asb` | WebSphere 8.5 |
| `websphere90.asb` | WebSphere 9.0 |

### Aplicaciones - HTTPServer (Apache)

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `httpserver80s.asb` | Standalone | Apache HTTP Server 8.0 |
| `httpserver80d.asb` | Dedicado | Instancias dedicadas 8.0 |
| `httpserver85s.asb` | Standalone | Apache HTTP Server 8.5 |
| `httpserver85d.asb` | Dedicado | Instancias dedicadas 8.5 |
| `httpserver90s.asb` | Standalone | Apache HTTP Server 9.0 |
| `httpserver90d.asb` | Dedicado | Instancias dedicadas 9.0 |

### Aplicaciones - MQ Series

| Archivo | Servicio | Archivos Relacionados |
|---------|----------|----------------------|
| `mqm.asb` | MQ Base | `mqma.asb` (start), `mqmb.asb` (stop) |
| `mqm8.asb` | MQ 8.x | `mqm8a.asb`, `mqm8b.asb` |
| `mqm9.asb` | MQ 9.x | `mqm9a.asb`, `mqm9b.asb` |
| `mqm90.asb` | MQ 9.0 | `mqm90a.asb`, `mqm90b.asb` |
| `mqm93.asb` | MQ 9.3 | `mqm93a.asb`, `mqm93b.asb` |

### Lógica de Detección (pp_status.sh)

```bash
# Ejemplo: Detección de PatrolAgent
PAFSC=$(df -h | awk '{print $6}' | grep \w*patrol$ | wc -l)  # Busca filesystem /patrol
PAAG=$(ps -eo args | grep -wi patrolagent | grep -v grep | wc -l)  # Proceso activo

if [ $PAFSC -gt 0 ]; then
    if [ $PAAG -eq 1 ] && [ $PAITLC -eq 1 ]; then
        echo "ACTIVO" > /var/opt/ansible/patrol.asb
    fi
fi
```

---

## Tareas Disponibles

| Tarea | Archivo | Descripción |
|-------|---------|-------------|
| `0_Crear_snapshot` | Snapshot VM | Crea snapshot de los servidores antes del IPL |
| `1_BlackOut_PatrolAgentes` | Silencia monitoreo | Evita alertas falsas durante el IPL |
| `2_Uptime_previo_IPL` | Uptime inicial | Registra tiempo de actividad antes del reinicio |
| `3_Foto_previa_IPL` | Snapshot pre-IPL | Captura estado completo del sistema |
| `4_Baja_Programas_Producto_Aplicaciones` | Detener servicios | Baja controlada de PP's y Apps |
| `5_Foto_intermedia` | Snapshot intermedio | Valida que servicios están abajo |
| `6_IPL_Total` | **Flujo completo** | Ejecuta todo el proceso automáticamente |
| `7_Alta_Programas_Producto_Aplicaciones` | Iniciar servicios | Levanta PP's y Apps |
| `8_Foto_posterior_IPL` | Snapshot post-IPL | Captura estado final |
| `9_Uptime_posterior_IPL` | Uptime final | Confirma reinicio exitoso |
| `10_Reiniciar_OS_Linux` | Solo reboot | Reinicio sin gestión de servicios |
| `11_Actualizar_parches_RHEL` | Parches RHEL | Actualización de parches RHEL 8 |
| `12_BlackIn_PatrolAgentes` | Reactiva monitoreo | Restaura alertas |

### Detalle: 0_Crear_snapshot

Esta tarea lanza el Job Template [147292](https://ansible-tower.eu4.cacf.kyndryl.net/#/templates/job_template/147292/) para crear snapshots de las VMs antes del IPL.

**Funcionamiento:**

1. Valida el formato del CRQ/INC/REQ
2. Construye la lista de equipos desde los facts del inventario
3. Lanza el job template 147292 via API

**Construcción de `equipos_lista`:**

```yaml
# Obtiene hostname e IP de los hosts en el play
equipos_lista: "{{ ansible_play_hosts | map('extract', hostvars) | map(attribute='inventory_hostname') | zip(ansible_play_hosts | map('extract', hostvars) | map(attribute='ipaddress')) | map('join', ':') | join(', ') }}"
```

**Formato de salida:**
```
servidor01:192.168.1.100, servidor02:192.168.1.101, servidor03:192.168.1.102
```

**Facts requeridos en el inventario:**
```json
{
  "ipaddress": "150.100.231.45",
  "ansible_host": "150.100.231.45",
  "ostype": "linux"
}
```

---

## Variables

### Definidas en `vars/main.yml`

```yaml
# Correo
smtp: 150.100.207.52
smtpport: 25
mailfrom: itoperationintegration.mx@bbva.com

# Sistema
gdmfsasb: /var/opt/ansible/         # Directorio de trabajo
asbgdm: /var/opt/ansible/lnxgdm

# Tower/AAP
tower_base_url: "http://tower-service.tower.svc.cluster.local"
tower_organization: "bvm"
tower_inventory: "bvm_inventory"
retries: 100
delay: 2
```

### Variables de Entrada (Encuesta)

| Variable | Descripción | Formato | Obligatorio |
|----------|-------------|---------|-------------|
| `idcrqincreq` | ID del cambio/incidente | `(CRQ\|INC\|REQ)[0-9]{12}` | Sí |
| `tarea` | Tarea a ejecutar | Nombre de archivo sin `.yml` | Sí |

### Validación del CRQ/INC/REQ

```yaml
- name: Validando Formato de Cambio o Incidente
  assert:
    that:
      - idcrqincreq | string | regex_search('(CRQ|INC|REQ)[0-9]{12}')
    fail_msg: "El CRQ, INC o REQ no cumplen con la condiciones del formato"
```

---

## Scripts

### `files/gdm/pre/pp_status.sh`

Detecta el estado de los **Programas Producto**:

| Servicio | Filesystem | Proceso |
|----------|------------|---------|
| PatrolAgent | `/patrol` | `patrolagent` |
| Capacity | `/performance` | `bgs*` |
| ControlM | `/controlm` | `ctma*` |
| Dimensions | `/dimensions` | `dimension*` |
| ConnectDirect | `/cdunix` | `cdpmgr` |
| SentinelOne | `/opt/sentinelone` | `sentinelone` |

### `files/gdm/pre/aps_status.sh`

Detecta el estado de las **Aplicaciones**:

| Aplicación | Filesystem | Detección |
|------------|------------|-----------|
| WebSphere | `/WebSphere{80,85,90}` | Procesos `WsServer` |
| HTTPServer | `/HTTPServer{80,85,90}` | Proceso Apache |
| MQ Series | `/opt/mqm*` | Queue Managers activos |

### `files/gdm/pre/report_pp_aps.sh`

Genera el reporte consolidado con:
- Información del servidor (hostname, IP, fecha)
- Estado del sistema (CPU, memoria, filesystem)
- Estado de todos los servicios detectados

---

## Programas Producto y Aplicaciones

### Programas Producto (PP)

| Programa | Usuario | Método de Baja | Método de Alta |
|----------|---------|----------------|----------------|
| PatrolAgent | `patrol` | `S50PatrolAgent.sh stop` | `S50PatrolAgent.sh start` |
| Capacity (BGS) | `bgs` | `bgsagent stop` | `bgsagent start` |
| ControlM | `controlm` | `shut-ag -u controlm` | `start-ag` |
| Dimensions | `dm` | `dmshutdown` | `dmstartup` |
| ConnectDirect | `cdadmin` | `cdpmgr -s` | `cdpmgr -i -n` |

### Aplicaciones

| Aplicación | Usuario | Método de Gestión |
|------------|---------|-------------------|
| HTTPServer 80 | `root` | `apachectl stop/start` |
| HTTPServer 85/90 | `was60` | `apachectl stop/start` |
| WebSphere 80 | `root` | wsadmin + Baja_Cluster.py |
| WebSphere 85/90 | `was60` | wsadmin + Baja_Cluster.py |
| MQ Series | `mqm` | `endmqm` / `strmqm` |

---

## Prerrequisitos

### En el Servidor Target

1. **Usuario Ansible**: `bvmuxat2` con grupo `automate`
2. **Directorio de trabajo**: `/var/opt/ansible/` con permisos 755
3. **Acceso sudo** para los usuarios de servicio
4. **Python** instalado para módulos Ansible

### En Ansible Tower/AAP

1. **Credenciales** configuradas para los hosts
2. **Inventario** con los servidores target
3. **Job Template** con encuesta habilitada

### Dependencias de Red

- Conectividad SSH al servidor target
- Acceso al servidor SMTP para notificaciones
- Conectividad con `tower-service.tower.svc.cluster.local`

---

## Troubleshooting

### Error: "El CRQ, INC o REQ no cumplen con las condiciones del formato"

**Causa**: El ID de cambio no cumple el patrón regex `(CRQ|INC|REQ)[0-9]{12}`

**Solución**: Verificar que el ID tenga exactamente:
- Prefijo: `CRQ`, `INC` o `REQ`
- Seguido de 12 dígitos numéricos
- Ejemplo válido: `CRQ000012345678`

### Error: Servicios no se detienen

**Verificar**:
1. Existencia del archivo `.asb` correspondiente
2. Permisos del usuario de servicio
3. Path de los scripts de control

```bash
# Verificar archivos .asb
ls -la /var/opt/ansible/*.asb

# Verificar proceso
ps -eo args | grep -i <servicio>
```

### Error: Timeout en el reboot

**Causa**: El servidor no responde en 3600 segundos

**Verificar**:
1. Estado del servidor en consola
2. Conectividad de red
3. Logs del sistema (`/var/log/messages`)

### Error: Foto no se genera

**Verificar**:
1. Permisos en `/var/opt/ansible/`
2. Ejecución de scripts con `become: true`
3. PATH correcto en el entorno

```bash
# Verificar permisos
ls -la /var/opt/ansible/
stat /var/opt/ansible/

# Verificar scripts
ls -la /var/opt/ansible/*.sh
```

### Logs útiles

| Log | Ubicación |
|-----|-----------|
| Foto previa | `/var/opt/ansible/{CRQ}_{host}_{IP}_foto_sso_pp_aps_previa.txt` |
| Foto intermedia | `/var/opt/ansible/{CRQ}_{host}_{IP}_foto_sso_pp_aps_intermedia.txt` |
| Foto posterior | `/var/opt/ansible/{CRQ}_{host}_{IP}_foto_sso_pp_aps_posterior.txt` |
| Ansible Tower | Job output en la UI |

---

## Autor

**BBVA Automation Team**
📧 itoperationintegration.mx@bbva.com

---

## Changelog

| Versión | Fecha | Descripción |
|---------|-------|-------------|
| 1.0 | - | Versión inicial |
