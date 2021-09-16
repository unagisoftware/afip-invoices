[![Coverage Status](https://coveralls.io/repos/github/unagisoftware/afip-invoices/badge.svg?branch=main)](https://coveralls.io/github/unagisoftware/afip-invoices?branch=main)
[![Rubocop Status](https://github.com/unagisoftware/afip-invoices/actions/workflows/rubocop.yml/badge.svg?event=push)](https://github.com/unagisoftware/afip-invoices/actions/workflows/rubocop.yml)

## Introducción

Esta aplicación Rails resuelve la integración con los [web services de AFIP](https://www.afip.gob.ar/ws/) a través de una API JSON. Permite mediante la gestión de entidades facturadoras la posibilidad generar y listar comprobantes. El presente README tiene por finalidad introducir sobre las tecnologías utilizadas, la puesta en marcha, el proceso de deploy y algunos diagramas de flujo para entender el funcionamiento interno de la API.

La aplicación está preparada para ser ejecutada tanto de forma tradicional como también utilizando Docker. A su vez, viene configurada con Capistrano lista para el deploy simplemente configurando algunas variables de entorno. Dentro de este README se decriben los comandos y las variables necesarias para tal propósito.

Además de eso, este repositorio cuenta con una [wiki](https://github.com/unagisoftware/afip-invoices/wiki) en donde se puede encontrar más información relacionada a entender el funcionamiento de la API.

## Contribuir

Este es un proyecto open source, en el cual para que siga creciendo y mejorando necesitamos toda la ayuda posible. Nos podés ayudar desarrollando nuevas features, reportando errores, proponiendo ideas o simplemente siendo parte de la comunidad. En nuestra [guía de contribución](CONTRIBUTING.md) podés encontrar la información sobre cómo hacerlo.

## Documentación de endpoints

  [Ver documentación en Postman](https://documenter.getpostman.com/view/17046114/TzzHjXM3).

## Dependencias

Los pasos de configuración esperan que las siguientes herramientas se instalen en el sistema:
* Ruby 2.7.4.
* Rails 6.1.4.1.
* PostgreSQL ([instalar con Docker](https://towardsdatascience.com/local-development-set-up-of-postgresql-with-docker-c022632f13ea)).

## Setup inicial

#### 1. Clonar el repositorio

```bash
git clone git@github.com:unagisoftware/afip-invoices.git
```

#### 2. Crear el archivo `application.yml`

##### 2.1 Copiar el archivo de ejemplo `application.yml.sample` y completar con los valores correctos.

```bash
cp config/application.yml.sample config/application.yml
```

##### 2.2 Crear y configurar el token de autorización y el salt para la encriptación de tokens de entidad

Para crear el `AUTH_TOKEN` debés correr la siguiente tarea (copiá y pegá el valor resultante en tu `application.yml` o `.env` según corresponda):

```ruby
bundle exec rake credentials_generator:auth_token
```

Para crear el `ENCRYPTION_SERVICE_SALT` debés correr la siguiente tarea (copiá y pegá el valor resultante en tu `application.yml` o `.env` según corresponda):

```ruby
bundle exec rake credentials_generator:salt_encryptor
```

## Configuración y puesta en marcha

### Sin Docker

##### 1. Crear y configurar la base de datos

Correr los siguientes comandos para crear la base de datos y configuraciones (migraciones y seeds):

```ruby
bundle exec rake db:create
bundle exec rake db:setup
```

##### 2. Correr los tests

```ruby
bundle exec rspec
```
##### 3. Verificar test coverage

- Es necesario correr los tests para completar el reporte de coverage.
- Abrir en tu navegador `coverage/index.html`.

##### 4. Correr el servidor de Rails

Correr el siguiente comando, podés usar el parámetro `-p [puerto]` para cambiar el puerto en el que correr la aplicación:

```ruby
bundle exec rails server
```

### Con Docker

La aplicación utiliza Redis para almacenar en caché y no perder sus datos al apagar el contenedor.

#### 1. Crear el archivo `.env`

Copiar el archivo de ejemplo `application.yml.sample` y completar con los valores correctos.

Seguir los pasos del paso 2.2 pero copiando los valores en el `.env`

```bash
cp .env.sample .env
```

#### 2. Crear y configurar la base de datos

* Crear un volumen para persistir la información de nuestro PostgreSQL:

    ```bash
    docker volume create postgres-factura
    ```

* Correr los siguientes comando para crear y configurar la base de datos:

  ```bash
  docker-compose up -d db
  docker-compose run -e MIGRATE='false' app bundle exec db:create
  docker-compose run -e MIGRATE='false' app bundle exec db:setup
  docker-compose down
  ```

#### 3. Correr los tests

  ```bash
  docker-compose up -d db
  docker-compose run app bundle exec rspec
  docker-compose down
  ```
#### 4. Correr la aplicación y el servicio de base datos

Se corre un servidor Redis para no perder los datos de cache (cuando no se utiliza Docker la caché utilizada es el disco)

Correr el suguiente comando para correr los servicios (`app`, `postgresql` y `redis`):

  ```bash
  docker-compose up
  ```

## Deploy con Capistrano

La aplicación cuenta con la configuración necesaria para hacer deploy utilizando Capistrano. Para poder hacerlo funcionar, es necesario configurar algunas variables de entorno indicando parámetros relacionados a los servidores en donde se tiene que hacer el deploy. Por defecto, existentes configurados dos entornos: staging y producción.

Las variables de entorno a agregar son las siguientes:
- `APPLICATION_NAME`: Nombre de la aplicación (ejemplo: `afip-invoices`).
- `PRODUCTION_SERVER_SSH_NAME`: Nombre del host de SSH del servidor de producción (ejemplo: `unagi-production`).
- `REPO_URL`: Dirección del repositorio (ejemplo: `git@github.com:unagisoftware/afip-invoices.git`).
- `SERVER_APPLICATION_DIRECTORY`: Directorio en donde se instala la aplicación en el servidor (ejemplo: `$HOME/apps/afip-invoices`).
- `SERVER_PG_SYSTEM_DB`: Nombre de la DB del sistema en el servidor (ejemplo: `postgres`).
- `SERVER_PG_SYSTEM_USER`: Usuario del sistema de la base de datos del servidor (ejemplo: `postgres`).
- `SERVER_RBENV_BIN_PATH`: Dirección del ejecutable de rbenv en el servidor (ejemplo: `$HOME/.rbenv/bin/rbenv`).
- `SERVER_USER`: Usuario del servidor (ejemplo: `deploy`).
- `STAGING_SERVER_SSH_NAME`: Nombre del host de SSH del servidor de staging (ejemplo: `unagi-staging`).

Una vez configuradas las variables de entorno para Capistrano, el primer deploy se realiza con los siguientes comandos (usar el entorno correspondiente, en este caso usaremos `staging`). Es importante que la clave SSH pública del servidor sea agregada al respositorio configurado en `REPO_URL` en caso de que sea privado para poder hacer un pull desde el servidor.

```bash
cap staging deploy:initial
cap staging puma:make_dirs
cap staging puma:config
cap staging puma:systemd:config puma:systemd:enable
```

Luego, se creará en el directorio especificado en `SERVER_APPLICATION_DIRECTORY` del servidor un directorio con la configuración inicial de la aplicacción. En este momento, es necesario agregar las variables de entorno en `shared/config/application.yml` antes de hacer un deploy completo.

Luego de agregarlas, el servidor quedará listo para cualquier deploy, el cual se realiza con el siguiente comando:

```bash
cap staging deploy
```

## Postman

Se puede importar la colección de Postman con los endpoints del sistema. La misma se localiza en el siguiente path: `postman/api_afip.postman_collection.json`. [Aquí](https://learning.postman.com/docs/getting-started/importing-and-exporting-data/#importing-data-into-postman) podrás encontrar las intrucciones para importar una colección.

Podés configurar un nuevo ambiente en Postman o bien [importar](https://learning.postman.com/docs/getting-started/importing-and-exporting-data/#importing-data-into-postman) el que se encuentra como ejemplo en el repositorio (`postman/environment_example.postman_environment.json`). Es necesario tener configuradas las siguientes variables de entorno:
* `ADMIN_TOKEN`: el token de autorización que se utiliza para la gestión de entidades.
* `TOKEN`: el token de alguna de las entidades configuradas.
* `HOST`: el host o dominio donde correr tu aplicación (ejemplo http://localhost).

Podés revisar la [documentación dentro de Postman](https://learning.postman.com/docs/publishing-your-api/documenting-your-api/#accessing-doc-views) o abrir el [siguiente link](https://documenter.getpostman.com/view/17046114/TzzHjXM3).

## Diagramas de flujo

### Crear un nuevo comprobante

![Alta de comprobante](flowcharts/generar_comprobante.png?raw=true "New Invoice")

### Autenticación contra la API de AFIP

![Autenticación con AFIP](flowcharts/autenticacion_afip.png?raw=true "AFIP autentication")


Sobre Unagi
----------------

![unagi](https://unagi.com.ar/img/logo-nav.svg)

`afip-invoices` fue creada y es mantenida por Unagi SAS. Los nombres y logos de Unagi son marcas registradas de Unagi SAS.

Sentimos un orgullo inmenso por colaborar con la comunidad open source. Visitá [nuestra web](https://unagi.com.ar/en) para ver algunos de nuestros proyectos más recientes o [escribinos](mailto:info@unagi.com.ar?subject=[GitHub]%20afip-invoice%20) para diseñar, desarrollar y hacer crecer tu proyecto junto a nuestro equipo.

[Blog](https://medium.com/unagi) | [Linkedin](https://www.linkedin.com/company/unagisoftware) | [Twitter](https://twitter.com/unagisoftware) | [Clutch](https://clutch.co/profile/unagi)
