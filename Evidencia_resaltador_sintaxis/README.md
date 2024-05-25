# Evidencia: resaltador de sintaxis de Python

### Emiliano Romero López    A01028415

Este es un resaltador de sintaxis para procesar archivos de texto escritos en el lenguaje Python.

## Correr el programa
Para correr el programa, es necesario ingresar en terminal el siguiente comando: elixir .\syntax_highlighter.exs \<nombre del archivo a procesar>. El programa se encargará de generar un nuevo nombre para el archivo de salida, que será el mismo que el de entrada pero con extensión .html. En la carpeta Evidencia_resaltador_sintaxis se encuentra un archivo css para dar formato y color al archivo HTML resultante. 

## Ejemplos
Se han proporcionado 3 archivos de código de Python llamados py1.txt, py2.txt y py3.txt a manera de ejemplo para ser procesados por el programa. 

## Tabla de expresiones regulares

Algunas de las expresiones no son mostradas adecuadamente en la tabla, consultar el código de markdown o el archivo exs para verlas completas.

| Token    | Regex                                                                                         |
|--------------|------------------------------------------------------------------------------------------------------------------------------------------|
| Whitespace   | ~r/^\s+/                                                                                    |
| Reserved     | ~r/^\b(?:and|as|assert|async|await|break|class|continue|def|del|elif|else|except|False|finally|for|from|global|if|import|in|is|lambda|None|nonlocal|not|or|pass|raise|return|True|try|while|with|yield)\b/ |
| Function     | ~r/^\b\w+(?=\s*\()/                                                                               |
| Magic        | ~r/^\b__\w+__\b/                                                                                    |
| Variable     | ~r/^\b[a-zA-Z_][a-zA-Z0-9_]*\b/                                                                    |
| Operator     | ~r/^[-+*\/%=<>!&|^~]+/                                                                             |
| Number       | ~r/^[-+]?\b\d+\.?\d*\b/                                                                            |
| Comment      | ~r/^#.*?$/                                                                                          |
| Punctuation  | ~r/^[()\[\]{}:;.,\\]/                                                                               |
| String       | ~r/^(\'\'\'[\s\S]*?\'\'\'|"""[\s\S]*?"""|\'[^\n\']*\'|"[^\n"]*")/                                |


## Complejidad del algoritmo

El programa analiza línea por línea al código de texto de entrada. Podemos llamar n al número de líneas que tiene este archivo. Después, cada línea es procesada individualemente al hacer match con cada uno de sus tokens, podemos llamar m al número de tokens promedio por cada línea. Las operaciones que realiza posteriormente depende del número de tokens que haya por línea, por lo que por cada token en una línea, primero se realiza un match y después una operación. Se recorre dos veces la cantidad de tokens en una línea. Por esto, la complejidad del algoritmo es de O(n*2m).

Me parece que esta solución proporciona un tiempo de ejecución razonable dada la naturaleza de los requerimientos. Es necesario procesar cada línea de esta forma para poder extraer la información necesaria.

## Implicaciones éticas

En cuanto a temas de seguridad y privacidad, este programa me ha demostrado la facilidad con la que se puede filtrar y clasificar información una vez que se cuenta con el texto y caracteres puros. Creo que es importante tener en cuenta los requisitos de seguridad necesarios para garantizar que la información sensible o privada no sea accesible sin los permisos necesarios, de otra forma es fácil establecer patrones para encontrar contraseñas, números de teléfono, etc. 

Con temas relacionados a la justicia como en casos criminales, creo que esta tecnología puede ser una herramienta útil para encontrar evidencias y pruebas fácilmente mediante la investigación de documentos.

En general, creo que esta es una herramienta poderosa que debe ser utilizada con responsabilidad, y, siempre y cuando sea de manera ética, puede ser muy útil para tareas diarias. El manejo eficiente de este tipo de información puede ahorrar horas de búsqueda y clasificación, o para nosotros como programadores, facilitar el trabajo de correción y edición de código. 