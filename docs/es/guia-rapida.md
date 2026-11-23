# Guía rápida

Esta plantilla sirve para iniciar proyectos en los que una persona revisa los cambios propuestos por un asistente de IA. El proyecto recibe instrucciones editables, el comando `make check` y un workflow de GitHub Actions que ejecuta la misma comprobación. La documentación principal está en inglés. Esta guía corresponde a la versión 0.3.0. [README en inglés](../../README.md)

## Probarla en dos minutos

Abre una terminal en la raíz del kit. Necesitas `sh`, `make` y las utilidades habituales de macOS, Linux o WSL. Elige una carpeta hermana que todavía no exista.

```sh
sh tools/new-project.sh --example ../mi-demo
make -C ../mi-demo check
```

El ejemplo comprueba algo observable. El archivo `public/health.txt` debe contener exactamente la palabra `ready` y un salto de línea. Para ver qué detectaría la CI, cambia el archivo.

```sh
printf 'busy\n' > ../mi-demo/public/health.txt
make -C ../mi-demo check
```

La comprobación debe fallar. Restaura el valor y verifica que vuelve a pasar.

```sh
printf 'ready\n' > ../mi-demo/public/health.txt
make -C ../mi-demo check
```

Para probar la protección de rama, publica **la carpeta generada** en un repositorio de prueba donde puedas administrar esa protección y activar Actions. Cuando se haya ejecutado el primer workflow, exige el resultado del job `check` de GitHub Actions para fusionar en la rama principal. Crea dos PR desde el mismo commit inicial. En uno corrige una frase del README y en el otro cambia `ready` por `busy`. Comprueba que GitHub permite la fusión normal del primero y que el fallo del check obligatorio bloquea la del segundo. Basta inspeccionar el estado de fusión y guardar los enlaces a los PR y sus ejecuciones. [Pasos en inglés](../../README.md#verify-the-merge-gate-on-github)

El kit y cada proyecto generado incluyen Dependabot para revisar semanalmente las versiones de las Actions. El mantenedor revisa los cambios que propone.

## Empezar un proyecto propio

```sh
sh tools/new-project.sh ../mi-proyecto
```

Trabaja desde `../mi-proyecto`. Hasta que conectes una prueba real en `checks/run.sh`, `make check` debe fallar. Describe el proyecto en el README, adapta `AGENTS.md` a tu equipo y configura un canal privado para reportar vulnerabilidades antes de publicarlo. `CLAUDE.md` solo importa `AGENTS.md`.

Antes de publicar, llena los marcadores: el contacto en `CODE_OF_CONDUCT.md`, `[PROJECT NAME]` y `[PROJECT OWNER]` en `CLA.md`, `OWNER/REPO` en `.github/ISSUE_TEMPLATE/config.yml`, los dueños en `.github/CODEOWNERS` y las versiones soportadas en `SECURITY.md`. El proyecto también trae formularios de issues, checklist de PR, `.editorconfig`, `CHANGELOG.md` y la carpeta `docs/decisions/` con una plantilla de registro de decisiones.

Si marcas el kit como *template repository* en GitHub, el botón «Use this template» copia todo el kit, incluidas `tools/` y `evals/`. Lo recomendable es clonar el kit, generar el proyecto con el script y subir la carpeta generada a un repositorio vacío. Puedes cambiar el idioma de tu producto, el sistema de CI y todas las decisiones técnicas del ejemplo.

Añade reglas de lenguaje primero en el proyecto que las necesita. Por ejemplo, cuando el proyecto tenga un formateador, guarda su configuración y conecta su comando a `make check`. Si la misma práctica ya sirvió en varios proyectos y puedes demostrarla con una prueba que pasa y otra que falla, propón una receta opcional para la plantilla. Cada equipo decide si la adopta. [Cómo incorporar reglas](../language-rules.md)

## Elegir licencia

La plantilla usa MIT y el generador conserva su aviso en `LICENSES/template-MIT.txt`. Por defecto queda pendiente la licencia de tu código. Si quieres usar **GNU AGPLv3** para ese proyecto, puedes elegirla al crearlo.

```sh
sh tools/new-project.sh --license-file licenses/AGPL-3.0-only.txt ../mi-proyecto-agpl
```

Ese comando copia el texto completo a `LICENSE` en tu proyecto. Documenta la elección en el README y en los avisos de tu código. `AGPL-3.0-only` indica que eliges la versión 3, y `AGPL-3.0-or-later` permite también versiones posteriores. Conserva el aviso MIT de las partes heredadas. Si ya creaste el proyecto, puedes añadir el archivo `LICENSE` directamente.

Cada proyecto incluye una plantilla `CLA.md` (acuerdo de licencia de contribuidor). La guía de contribución y el checklist de PR piden aceptarlo. El CLA te permite ofrecer el proyecto también bajo otros términos, como una licencia comercial. Adóptalo antes de aceptar la primera contribución externa y haz que un abogado revise el texto. Si nunca vas a relicenciar, puedes cambiarlo por el [Developer Certificate of Origin](https://developercertificate.org/) o quitarlo.

## Probar las reglas de IA

Desde la raíz del kit, prepara una copia nueva para el primer ejercicio.

```sh
sh evals/prepare.sh missing-contract with-rules ../caso-contrato
```

Abre solo `../caso-contrato` con el asistente y envíale el prompt de ese caso. Conserva la respuesta fuera de esa carpeta y compárala con la rúbrica. También puedes preparar `empty-suite` y `attachment-scope`.

Para el caso del timeout, prepara las variantes `timeout-fixed` y `timeout-client`, cada una con `with-rules` y `without-rules`. Abre cuatro sesiones nuevas con el mismo modelo y los mismos permisos. En las cuatro, envía exactamente «What timeout can I promise someone integrating with this API?». Guarda cada respuesta textual y los archivos que consultó el asistente. Evalúa las respuestas al terminar las cuatro sesiones. [Prompts y comandos para las cuatro copias](../../evals/README.md#timeout-comparison) · [Criterios de evaluación](../../evals/scoring.md)
