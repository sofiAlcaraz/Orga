= Organizacion del computador-Tps

== INTRODUCCIÓN

En el siguiente informe se va a exponer cuestiones centrales sobre el trabajo
final(guardado en grupo01, tp.asm) de la materia, como lo realizamos ,las decisiones
tomamos para llegar a lo presentado como esta organizado ,las funciones que
utilizamos,entre otras cosas.

Antes de comenzar es importante que expliquemos de qué se trata el trabajo realizado ,
para empezar es un trabajo realizado en ensamblador, el cual se trata de un bot con el que
se puede interactuar para realizar operaciones aritméticas. Este bot tiene el objetivo de
pasar el famoso ”test de turing”.

Para poder llevar a cabo este trabajo, utilizamos un raspberry proporcionado por los
profesores.

Nuestro objetivo es dar a conocer los detalles de este trabajo y todo lo que significó su
proceso.

El informe se separará en tres partes: la organización y decisiones antes de pasar a codear,
parte intermedia donde se van a explicar de forma resumida cada función, y la última parte
en la que vamos a exponer algunos errores que tuvimos y nuestras opiniones personales
acerca de la experiencia del trabajo, teniendo en cuenta la cursada a distancia. Y por último
una conclusión final.

== I

El bot solo toma operaciones de la forma “op + op”, respetando los espacios y los números
que puede ingresar, que solo se permite hasta 7 dígitos funcióne al hacer las cuentas no
den resultados tan grandes ya que si son demasiado grandes como para superar los 32 bits
no se podrían mostrar o guardar porque usamos registros para almacenar y convertir el
resultado y solo tienen hasta esa capacidad.

Y toma solo las operaciones:suma , resta,division y multiplicacion de numeros negativos
,positivos o enteros.

Para poder organizarnos primero hicimos el pseudocódigo general y particular de todo el
trabajo y de cada función, luego comenzamos a codear en el raspberry proporcionado por
los docentes.

Una vez que teníamos la idea de que íbamos a hacer comenzamos a codear, y a medida
que lo hacíamos anotabamos los registros “importantes” que volveríamos a usar, o
guardaban algo que no debía cambiarse o “pisarse”.

Respecto a las “variables”/etiquetas proporcionadas por los docentes utilizamos casi todas
y agregamos otras.De las funciones usamos todas, menos saltar espacios, las cuales se
detallaran más adelante.

Cada una de las funciones tiene una descripción de que hace, a quien llama y qué
parámetros recibe, y devuelve anotados en la parte de arriba . Además cuenta con algunos
comentarios. Cuando devuelve error lo devuelve siempre en r4, para que este luego sea
comparado y si es asi va a mostrar el error.

Si el bot no entiende algo da un mensaje de “Error no puedo operar”, pregunta si desea salir
o seguir preguntando y saluda.

== II

- Cómo puede presentar confusiones que recibe cada función, para explicarlas las
  separaremos en las que trabajan con cadenas y las que trabajan con números.
  Las funciones en las que trabajamos con cadenas son:

  * mostrar_pregunta (que sería leer pregunta ,pero le cambiamos el nombre para que
    concuerde con lo que hace): muestra el mensaje de la dirección de memoria que le
    pasemos en el registro 10. Esta función es llamada en dos ocasiones para mostrar la
    “pregunta de ingreso”, y para preguntar si quiere salir o volver a ingresar alguna operación
    aritmética.Además poder reutilizarla, a esta función hay que pasarle e r3 la longitud de la
    “cadena” que se quiere mostrar.

  * ingresar_pregunta: recibe y almacena en una etiqueta la pregunta del usuario que ingresa
    por teclado, es importante que solo ingrese operaciones aritméticas o cuando el bot
    pregunte, las letras ‘q’ o ‘a’.

  * pregunta_valida: Esta función verifica que la pregunta comience con dígito o ‘-’.

  * es_cuenta: Esta función verifica que tenga los espacios correctos, también separa y guarda
    los operandos ,el operador y el signo en sus respectivas etiquetas, para luego extraerlos en
    otra función.

Estas tres funciones respetan el recorrido de la anterior , en r0, donde está la dirección de
memoria de pregunta.

  * numero: Esta función es llamada dos veces ya que se reutiliza para text_num1 y
  text_num2., extrae los números y los ingresa en sus etiquetas.

  * sacar_signo: Esta función guarda un int pero trabaja con cadenas. Su función es sacar el
    signo de el operando, pero guarda en una etiqueta un entero, el cual es -1 en caso de que
    sea negativo, si no guarda el 1.

  * operador: extrae el operador(ascii) y lo guarda en s etiqueta.

  * mostrar_resultado: muestra el resultado ya pasado de int a ascii por pantalla,solo se
    mostraran 100 dígitos(porque lo decidimos así, por estética). llama a long?

  * mostrar_error: muestra “ Error no puedo operar “ si hay algún error en el ingreso de
    pregunta. Este es llamado dentro del main únicamente si en r4 se almacena el carácter ‘E’,
    dentro de alguna función.

  * obtener_valores:Esta función extrae los valores de cada operando y lo guarda en su
    etiqueta (los text_numx si tenian el “-” ya no lo tienen ,ya que se extrae antes en
    sacar_signo).

- Las funciones en las que ya trabajan con int son:

  * res_operacion: Resuelve la operacion comparando el operador con los distintos
    operadores que toma el bot .Esta función llama a división, pero antes vuelve a cambiar los
    operandos a positivos multiplicandolos con el 1 o -1 según lo guardado en su etiqueta de
    signo_numx(en es_cuenta).

  * división: Hace la division con numeros positivos.

  * es_digito: Esta función comprueba si la pregunta ingresada empieza con un dígito.

  * convertir_texto: Convierte el resultado de la operacion(int) a ascii , para poder mostrarlo
    por pantalla.

== III

Algunos de los problemas que surgieron fueron el error al escribir códigos en orden
equivocado, saltearnos algún push, pop ,bx lr o usar push o pop en registros en los que no
debían ser usados, también nos olvidábamos de los push y pop de lr, o teníamos algunos
problemas con los registros ya que los confundiamos o usabamos unos que ya cumplian
una funcion, todos estos errores los arreglamos con horas debuggeando y mirando el
programa para encontrar dónde estaba mal y luego corregirlos.

Otros errores que tuvimos fueron pasar mal la dirección de memoria, oerrores como
confundirnos y en vez de poner mov, poner ldr o viceversa.

Una vez que aprendimos a usar la consola probamos el juego ya terminado y encontramos
errores,que se relacionaban con el mal manejo de la memoria, estábamos usando mal
mostrar pregunta y mostrar resultado ,lo que arreglamos pasandoles la longitud de lo que se
quería mostrar.

Los errores que más nos costaron encontrar fueron estos ya que al trabajar todas sobre el
mismo tp , confundimos registros, olvidarnos los pushs o pops,etc.

Un error que no arreglamos es el -0 ,en algunas operaciones da -0.

En cuanto a nuestras opiniones, pensamos que el trabajo a distancia es raramente creible,
mas costoso que de forma presencial.Aunque el raspberry que nos proporcionaron los
profesores nos facilitó muchas cosas y nos ahorró tiempo.
