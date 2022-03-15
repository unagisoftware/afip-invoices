# Changelog
Todo los cambios notables relacionados al proyecto serán documentados en este archivo.

El formato está basado el la guía de [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y seguimos [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.6] - 2022-03-15
### Security
- Actualización de Rails de 6.1.4.4 a 6.1.4.7
- Actualización de varias dependencias con los últimos parches de seguridad

## [1.0.5] - 2022-02-03
### Fixed
- Corrección de log de warning de obtención de categoría de persona de AFIP al intentar representarla en formato JSON

## [1.0.4] - 2022-01-25
### Fixed
- Corrección de generación de previsualizaciones de comprobantes cuando sus items no tienen unidades

### Security
- Actualización de Ruby de 2.7.4 a 2.7.5
- Actualización de Rails de 6.1.4.1 a 6.1.4.4

## [1.0.3] - 2021-11-18
### Security
- Actualización de Puma por vulnerabilidad de seguridad

## [1.0.2] - 2021-09-30
### Added
- Corrección de generación de PDF para notas de crédito
- Agregado de información sobre caché en entorno desarrollo en README
- Agregado de tests para diferentes tipos de comprobantes en generación de PDF

## [1.0.1] - 2021-09-17
### Added
- Traducción al español del código de conducta
- Agregado de templates de issues para GitHub
- Agregado de badges de estado de RSpec, Rubocop y coverage en README
- Agregado de sección de contribución en README

## [1.0.0] - 2021-09-10
### Added
- Obtener y crear comprobantes en AFIP
- Exportar y previsualizar comprobante en formato PDF
- Administrar entidades para representar personas jurídicas o físicas de AFIP
- Consultar datos con CUIT de persona física o jurídica en AFIP
- Documentación inicial: README, código de conducta, guía de contribución y colección de Postman
- Configuración de Capistrano para deploy
- Configuración de Docker
- Configuración de GitHub Actions
