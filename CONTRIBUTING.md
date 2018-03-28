# Guía de contribución

Antes que nada, ¡muchas gracias por ayudarnos a mejorar el proyecto!

Antes de comenzar a colaborar te pedimos que leas algunos documentos:

* [Guía de contribución](CONTRIBUTING.md)
* [Código de conducta](CODE_OF_CONDUCT.md)
* [Guía de estilos de Rubocup](https://github.com/github/rubocop-github/blob/master/STYLEGUIDE.md)

### ¿Cómo nos podés ayudar?

* [Reporte de un problema de seguridad](#reporte-de-un-problema-de-seguridad)
* [Reporte de un bug](#reporte-de-un-bug)
* [Sugerencias de mejoras](#sugerencias-de-mejoras)
* [Revisión de pull requests](#revision-de-pull-requests)
* [Mejora de la documentación](#mejora-de-la-documentación)


## Reporte de un problema de seguridad

Si encontraste un problema de seguridad, por favor, te pedimos que **no lo reportes como un issue** en el repositorio. Lo podés hacer a través de nuestra cuenta de email: info@unagi.com.ar.

## Reporte de un Bug

**Podés revisar si ya alguien lo reporto** en los [issues](https://github.com/unagisoftware/afip-invoices/issues). Si no encontraste el bug en los issues, podés [abrir uno nuevo](https://github.com/unagisoftware/afip-invoices/issues/new). Es necesario incluir un título y una descripción clara del bug, con toda la información relevante y, si es posible, con un ejemplo, y cuál debería ser el comportamiento esperado.

## Sugerencias de mejoras

Las mejoras se reportan como [issues](https://github.com/unagisoftware/afip-invoices/issues) en nuestro repositorio, y deben contemplar lo siguiente:

* Usar un **título y descripción** que sean claros para describir la mejora propuesta.

* **Describir los pasos** con el mayor detalle posible necesarios para la mejora.

* **Incluir ejemplos** para describir los pasos, incluyendo snippets de código usando [bloques de código](https://help.github.com/articles/markdown-basics/#multiple-lines).

* **Describir el comportamiento actual y cuál sería el esperado aplicando la mejora**.

* **Explicar por qué considerás que esta mejora podría ser útil** para la mayoría que usa el proyecto.

## Revisión de pull requests

Es **importante** que primero revises tu PR vos mismo.  Asegurate de que:

- [ ] Los cambios cumplan con lo descrito en el issue.
- [ ] Revisar que no falle ningún test.
- [ ] Revisar el code coverage de los tests.
- [ ] Revisar aspectos técnicos.
- [ ] Revisar que el código se adecue a la [guía de estilos de Rubocup](https://github.com/github/rubocop-github/blob/master/STYLEGUIDE.md).
- [ ] Usar los labels correspondientes: bug, enhancement (mejora) o documentation.
- [ ] Si agregás un nuevo endpoint o modificás los parámetros de entrada y/o de salida de un endpoint, recordá modificar la colección de Postman.

## Mejora de la documentación

  Si creés que falta algo en la documentación o que se puede mejorar, podés [abrir un nuevo issue](https://github.com/unagisoftware/afip-invoices/issues/new) con el label **documentation** modificando algunos de los documentos que tenemos en el repositorio:

  - `README.md`.
  - `api_afip.postman_collection.json`.
  - `CONTRIBUING.md`.

  O simplemente reportando que pensás que se puede mejorar o si es necesario mejorar algo en la [wiki](https://github.com/unagisoftware/afip-invoices/wiki).

## Mensajes en los commits de Git

* **Usar tiempo presente** ("Add feature" NO "Added feature").
* **Usar modo imperativo** ("Move cursor to" NO "Moves cursor to").
* **Limitar la primera línea a 60 caracteres** o menos.
* **Referenciar al issue** al final de la primer línea.
* **Separar sujeto y cuerpo** del mensaje con una línea en blanco.
* Usar el cuerpo del mensaje para **explicar el qué y el porqué en vez del cómo**.
