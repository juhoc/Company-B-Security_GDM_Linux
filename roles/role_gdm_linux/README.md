# Ansible Proyecto GDM Linux

# 📘 README

## Sinopsis

Playbook - Para gestionar evidencias previas, intermedias, baja de programas producto y/o aplicaciones, IPL, alta de programas producto y/o aplicaciones y evidencia posteriores al IPL en SSOO Linux.

El Playbook es funcional para OS Linux que se menciona en la tabla abajo, su finalidad es apoyar en las tarea de reinicio de equipos Linux, cuando pasan por un proceso de actualizacion de parches de SSOO y requieran de un IPL's para que tomen los cambios.

## 🖥️ Alcance actual - SSOO:

| SSOO | Release |
| :--------  | :-------: |
| Linux RHEL | 7, 8 y 9 |
| Linux SuSE | 12 y 15 |

## 🖥️ Alcance actual - Programas Prodducto y Aplicaciones:

| Insumos | Software | Tarea |
| :--------  | :-------: | :-------: |
| Programas Prodcuto | PatrolAgent, CapacityAgent, ConttrolMAgent, Dimensions, ConnectDirect (Solo status de SentinelOne) | Baja y Alta |
| Aplicaciones | Apaches Stanalone/Dedicados 80, 85 y 90, WebSphere 80, 85 y 90, WebSphere MQ 80, 90 y 93 | Baja y Alta |


| Tarea|Descripción |
| :-------- | :-------|
|0_Crear_snapshot | Crea snapshot de los servidores antes del IPL (lanza job 147292) |
|1_BlackOut_PatrolAgentes | Silencia alertas de monitoreo para evitar falsas alarmas |
|2_Uptime_previo_IPL | Obtiene el UPTIME antes del IPL |
|3_Foto_previa_IPL | Genera la foto previa al IPL y obtiene información del equipo, Fecha, Uptime, hostname, IP's, %CPU, %Memoria, Firewall, FileSystem, Programas Producto y Aplicaciones |
|4_Baja_Programas_Producto_Aplicaciones | Baja de Programas Producto y Aplicaciones |
|5_Foto_intermedia  | Genera la foto intermedia al IPL y obtiene información del equipo, Fecha, Uptime, hostname, IP's, %CPU, %Memoria, Firewall, FileSystem, Programas Producto y Aplicaciones |
|\*6_IPL_Total | Realiza la ejecucion de IPL (Reboot) completo con evidencias |
|7_Alta_Programas_Producto_Aplicaciones | Alta de Programas Producto y Aplicaciones |
|8_Foto_posterior_IPL | Genera la foto posterior al IPL y obtiene información del equipo, Fecha, Uptime, hostname, IP's, %CPU, %Memoria, Firewall, FileSystem, Programas Producto y Aplicaciones |
|9_Uptime_posterior_IPL | Obtiene el UPTIME despues del IPL |
|10_Reiniciar_OS_Linux | Ejecuta un IPL solamente |
|11_Actualizar_parches_RHEL | Ejecuta script de actualizacion de parches para RHEL 8 |
|12_BlackIn_PatrolAgentes | Reactiva alertas de monitoreo |

\*\* 6_IPL_Total, ejecuta de forma embebida las tareas 1_BlackOut_PatrolAgentes, 3_Foto_previa_IPL, 4_Baja_Programas_Producto_Aplicaciones, 5_Foto_intermedia, 10_Reiniciar_OS_Linux, 7_Alta_Programas_Producto_Aplicaciones, 8_Foto_posterior_IPL, 9_Uptime_posterior_IPL y 12_BlackIn_PatrolAgentes


## Variables

No requiere variables.

|Variable|Default|Comments|
|:----------|:----------|:----------|
|N/A|N/A|N/A|

## Encuesta
Durante el lazamiento del JobTemplate GDM Linux le solicitara llenar una encuesta, donde se requiere ingresar un CRQ, INC o REQ y el tipo de tarea de forma mandatorio.

|Campos/combos|Opcional/Mandatorio|
|:--------|:-------|
|Ingrese el CRQ INC o REQ ID|Mandatorio|
|¿Qué acción quieres ejecutar?|Mamdatorio|

## Resultados de la ejecucción

|Return Code Group|Return Code|Comments|
|:----------|:--------------|:---------|
|N/A|N/A|N/A

## INDICE

## 1. [Como lanzar el JobTemplate GDM Linux](#como-lanzar-el-jobtemplate-gdm-linux)
## 2. [Como lanzar el JobTemplate GDM Linux Evidencias](#como-lanzar-el-jobtemplate-gdm-linux-evidencias)

## Como lanzar el JobTemplate GDM Linux.

1. Clic en el enlace Acceso a Ansible Automation Platform.

    [Acceso a Ansible Automation Platform](https://ansible-tower.eu1.cacf.kyndryl.net/#/login)

![ Marcado 1](/roles/role_gdm_linux/imagenes/screenshot_000001.png)

2. Inicie sesion dando clic en "**Iniciar sesión SAML KyndrylOKTA**".

![ Marcado 2](/roles/role_gdm_linux/imagenes/screenshot_000002.png)

3. En el menu contextual del lado izquierdo, clic el Plantillas si se muestra en español o Template si se muestra en ingles.

![ Marcado 3](/roles/role_gdm_linux/imagenes/screenshot_000003.png)

4. En Plantilla (Template), en el campo de busqueda escribir gdm_linux y clic en la lupa.

![ Marcado 4](/roles/role_gdm_linux/imagenes/screenshot_000004.png)

5. Continuando en Plantilla (Template), el resultado de la busqueda se muetra el nombre de la plantilla [bvm_jobtemplate_gdm_linux ](https://ansible-tower.eu1.cacf.kyndryl.net/#/templates/job_template/116754).

![ Marcado 5](/roles/role_gdm_linux/imagenes/screenshot_000005.png)

6. Al dar clic en la [bvm_jobtemplate_gdm_linux ](https://ansible-tower.eu1.cacf.kyndryl.net/#/templates/job_template/116754/details), podre ver a detalle la informacion de la plantilla.

    6.1 Para lanzar la plantilla, clic en Ejecutar si el boton se muetra en español o Launch si se muestra en ingles.

![ Marcado 6](/roles/role_gdm_linux/imagenes/screenshot_000006.png)

7. Al dar clic en Ejecutar (Launch), se motrara una ventana emergente, en **Otros avisos** el campo **Limite** (**Limit**) escribir la lista de servidores donde se ejecutara la plantilla separados por espacion o por comas:

- Ejemplo 1:
  - lvtwshhstermx01.* latwsextranmx01.* ladwsaaccmx02.* lvtpdhhstermx01.* latpdaaccmx01.*

- Ejemplo 2:
  - lvtwshhstermx01.\*, latwsextranmx01.\*, ladwsaaccmx02.\*, lvtpdhhstermx01.\*, latpdaaccmx01.*

![ Marcado 7](/roles/role_gdm_linux/imagenes/screenshot_000007.png)

8. En la **Encuesta**, ingresar el **CRQ**, **INC** o **REQ**, son tres carateteres alfabeticos + doce numericos en total quince caracteres y en **¿Qué acción vas a ejecutar?** seleccione la tarea que necesite ejecutar.

![ Marcado 8](/roles/role_gdm_linux/imagenes/screenshot_000008.png)

9. En **Vista previa**, se muestra un resumen general de la plantilla que se ejecutara.

![ Marcado 9](/roles/role_gdm_linux/imagenes/screenshot_000009.png)

**IMPORTANTE**: Solo como validacion, con la barra de desplazamiento baje y en **Valores Solicitados**, en **Limite** se muestra la lista de servidores, en **Variables** el valor del **CRQ**, **INC** o **REQ** que ingreso y la **tarea** que haya seleccionado.

![ Marcado 10](/roles/role_gdm_linux/imagenes/screenshot_0000010.png)

10. Clic en Ejecutar (Launch), para iniciar con el procesos de ejecucion de acuerdo a la **tarea** que haya seleccionado.

### Como lanzar el JobTemplate GDM Linux Evidencias.

1. Sin salir de la consola de Ansible y necesita ejecutar Plantilla de trabajo bvm_jobtemplate_gdm_linux_evidencias.

2. En el menu contextual del lado izquierdo, clic el Plantillas si se muestra en español o Template si se muestra en ingles.

![ Marcado 11](/roles/role_gdm_linux/imagenes/screenshot_000003.png)

3. En Plantilla (Template), en el campo de busqueda escribir bvm_jobtemplate_gdm_linux_evidencias y clic en la lupa.

![ Marcado 12](/roles/role_gdm_linux/imagenes/screenshot_000004.png)

4. Continuando en Plantilla (Template), el resultado de la busqueda se muetra el nombre de la plantilla [bvm_jobtemplate_gdm_linux_evidencias](https://ansible-tower.eu1.cacf.kyndryl.net/#/templates/job_template/125826).

![ Marcado 13](/roles/role_gdm_linux/imagenes/screenshot_0000011.png)

5. Al dar clic en la [bvm_jobtemplate_gdm_linux_evidencias](https://ansible-tower.eu1.cacf.kyndryl.net/#/templates/job_template/125826/details), podre ver a detalle la informacion de la plantilla.

    6.1 Para lanzar la plantilla, clic en **Ejecutar** si el boton se muetra en español o **Launch** si se muestra en ingles.

![ Marcado 14](/roles/role_gdm_linux/imagenes/screenshot_0000012.png)

6. Al dar clic en **Ejecutar** (**Launch**), se motrara una ventana emergente, en **Otros avisos** el campo **Limite** (**Limit**) escribir la lista de servidores donde se ejecutara la plantilla separados por espacion o por comas:

- Ejemplo 1:
  - lvtwshhstermx01.* latwsextranmx01.* ladwsaaccmx02.* lvtpdhhstermx01.* latpdaaccmx01.*

- Ejemplo 2:
  - lvtwshhstermx01.\*, latwsextranmx01.\*, ladwsaaccmx02.\*, lvtpdhhstermx01.\*, latpdaaccmx01.*

![ Marcado 15](/roles/role_gdm_linux/imagenes/screenshot_0000013.png)

7. En **Encuesta**:

  7.1 Ingresar el **CRQ**, **INC** o **REQ**, que utilizo cuando lanzo la plantilla bvm_jobtemplate_gdm_linux, en **¿Qué acción vas a ejecutar?** seleccione **Enviar_evidencias** y en **¿Escriba las direcciones de correo?** escriba los correos de la siguiente forma **usuario1@dominio.com, usuario2@dominio.com, usuario3@dominio.com** separados por una coma y seguido de un espacio.

![ Marcado 16](/roles/role_gdm_linux/imagenes/screenshot_0000014.png)

8. En **Vista previa**, se muestra un resumen general de la plantilla y las opciones que haya ingresado.

![ Marcado 19](/roles/role_gdm_linux/imagenes/screenshot_0000015.png)

**IMPORTANTE**: Solo como validacion, con la barra de desplazamiento baje y en **Valores Solicitados**, en **Limite** se muestra la lista de servidores, en **Variables** el valor del **CRQ**, **INC** o **REQ** que ingreso en la plantilla de **bvm_jobtemplate_gdm_linux** y en **mail_to** las direcciones de correo.

![ Marcado 20](/roles/role_gdm_linux/imagenes/screenshot_0000016.png)

9. Clic en **Ejecutar** (**Launch**), para iniciar la plantilla de GDM Linux Evidencias.
