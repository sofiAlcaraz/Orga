//grupo 01 integrantes: Alcaraz sofia, Veron Lucrecia    com:04
//Organizador del computador
.data
pregunta:	.space 100
mensaje_ing:	.asciz "Ingrese una operacion de la forma: dddd op dddd \n"
mensaje_error:	.asciz "Error no puedo operar \n"
text_num1:	.ascii "               "
text_num2:	.ascii "               "
text_result:	.space 10
op:		.byte 0
num1:		.int 0
num2:		.int 0
resultado:	.int 0
resto:		.int 0
mensaje:	.asciz "\nPresione 'q' para salir o 'a' para comenzar de nuevo\n"
respo:		.space 2
es_negativo:	.byte 0
signo_num1:	.int 0
signo_num2:	.int 0
saludo:		.asciz "Adios , que tengas un lindo dia!\n"
.text

/*--------------muestra por pantalla el primer mensaje ----------*/
//funcion llamada en el main, muestra mensaje de ingreso,no devuelve nada,
// toma en r10 lo que se quiere mostrar y en r3 su longitud.
mostrar_pregunta:
	push {lr}
	push {r0,r1, r2, r7}
	mov r7, #4
	mov r0, #1
	mov r2, r3                    //logitud de cadena
	mov r1, r10		     //r10=lo que se quiere mostrar
	swi 0
	pop {r0, r1, r2, r7}
	pop {lr}
	bx lr

/*----------------el usuario ingresa por teclado------------*/
//funcion llamada en el main, ingresa la pregunta, no devuelve nada solo
// guarda.toma en r5, la direccion de memoria de la pregunta
	ingresa_pregunta:
		push {r0, r1, r2, r7}
		mov r7, #3
		mov r0, #0
		mov r2, #100
		mov r1,r5
		swi 0
		pop {r0, r1, r2, r7}
		bx lr

/*-------------verifica si la pregunta ingresada es valida-----------*/
//Funcion llamada en el main, devuelve nada /error.
//Verifica que la pregunta comienze con - /digito.
//Llama a digito. Toma en r0 la direccion de memoria de la pregunta
	pregunta_valida:
		push {lr}
		push {r1}
		ldrb r1, [r0]		// primer caracter de la pregunta

		cmp r1, #'-'
		beq true		//si es igual a - entonces sale

		bl es_digito
		pop {r1}
		pop {lr}
		bx lr

		true:
		pop {r1}
		pop {lr}
		bx lr

/*------------verifica si es un digito -----------------*/
//Funcion llamada por pregunta_valida
//devuelve nada/error.toma parametro r1,direccion de memoria de preg en r0
//verifica  que el primer caracter sea digito ,sino es error
	es_digito:
		cmp r1,#0x30
		blt false
					//compara que este en el rando de 0 a 9
		cmp r1, #0x39
		bgt false

		bx lr

		false:
		mov r4, #'E'		//en caso de que no sea digito, ni -
		bx lr

/*-------------verifica si la pregunta es valida-------------*/
//Funcion llamada en el main
//devuelve nada/error/guarda.verifica que la pregunta tenga los dos espacios,
//guarda cada operando en su etiqueta,guarda el operador en su etiqueta y
//antes de esto saca los signos(+info en sacar_signo)y puede devolver error
//Toma en r0 la direccion de memoria de pregunta.
//Llama a las funciones operador ,numero y sacar_signo.

	es_cuenta:
		push {lr}
		push {r1, r2, r5}

		comienza_ciclo:
		ldrb r1, [r0]			//carga caracter de pregunta
		cmp r1, #0x20			//compara si caracter = espacio
		beq primerEspacio

		cmp r1, #0x10			//si caracter = salto de linea
		beq e

		add r0, r0, #1			//apunta al sig. caracter
		bal comienza_ciclo


	//-----en caso de que encuentre el primer espacio-------
		primerEspacio:
	//---para primer operando:
		push {r0, r1}
		ldr r0, =pregunta
		ldrb r1, [r0]			//se vuelve a cargar el primer
						//caracter
		ldr r2, =signo_num1
		bl sacar_signo			//verifica si es negativo

		ldr r5, =text_num1
		bl numero			//extrae el primer operando
		pop {r0, r1}			//devuelve las posiciones
						//anteriores

	//---saca operador:
		bl operador

	//---verifica el segundo espacio:
		ldrb r1, [r0,#1]		//sumamos uno para apuntar al
						//sig. espacio
		cmp r1, #0x20
		bne e

	//---para el operando 2:
		add r0, r0, #2			//sumamos 2 para cargar el
		ldrb r1, [r0]			//primer caracter del operando 2

		ldr r2, =signo_num2
		bl sacar_signo			//verifica si es negativo

		ldr r5, =text_num2
		bl numero			//extrae el segundo operando
		pop {r1, r2, r5}
		pop {lr}
		bx lr

	//----error en caso de que no encuentre los espacios-----
		e:
		mov r4, #'E'
		pop {r1, r2, r5}
		pop {lr}
		bx lr

/*-----------extrae num text-------------------------------------*/
//Funcion llamada por es_cuenta
//guarda los numeros(ascii)en sus etiquetas.Toma como parametros
//en r5 la direccion en la que vamos a guardar
// los valores, en r0 la direccion de la pregunta.

numero:
	extraer_num:
	ldrb r1,[r0]			//caracter a guardar de pregunta
	//en caso de que sea num1:
 	cmp r1,#0x20			//si es igual a espacio sale
	beq salir_de_numero

	//en caso de que sea num2:
	cmp r1,#10			//si es igual a salto de linea sale
	beq salir_de_numero

	strb r1, [r5]			//guarda caracter en text_numx
	add r0,#1			//sig. caracter
	add r5,#1			//sig. posicion en donde guardamos
	bal extraer_num

	salir_de_numero:
	push {r2}
	mov r2,#0x00			//añade null al final de text_numx
	strb r2, [r5]
	pop {r2}
	bx lr


/*-------------saca la longitud de los numeros---------------------*/
//Funcion llamada por obtener_valores
//devuelve longitud de lo que le pasemos en r3(int).Toma en r10 lo que le
// querramos pasar.
longitud:
	push {r5, r10}
	mov r3,#0			//contador
	cicloLongitud:
	ldrb r5,[r10]
	cmp r5, #0x00
	beq salirLongitud
	add r3, r3,#1
	add r10, r10, #1			//sig. caracter
	bal cicloLongitud

	salirLongitud:
	cmp r3, #7
	bgt longitudError
	pop {r5, r10}
	bx lr

	//en caso de que text_numx sea mayor a 7 caracteres
	longitudError:
	mov r4, #'E'
	pop {r5, r10}
	bx lr

/*------------hace la division----------------------------------------*/
//Es llamada por la funcion convertir_texto y res_operacion
//devuelve resultado en r0. En r1 toma el valor del dividendo y en r2 toma el
//valor del divisisor.
//Divide los operandos pasados

division:
	mov r0,#0 		//cont
menor:
	cmp r1,r2
	bge mayor
	bal es_menor
mayor:
	sub r1,r1,r2		//resto
	adds r0,r0,#1		//resultado
	bal menor
es_menor:
	bx lr

/*-----------mostrar el resultado por pantalla-----------------------*/
//Funcion llamada en el main
//solo muestra el resultado en ascii

mostrar_resultado:
	push {lr}
	push {r0,r1,r2,r7}
	mov r7,#4
	mov r0,#1
	mov r2, r3             //muestra hasta 100 numeros
	ldr r1,=text_result
	swi 0

	pop {r0,r1,r2,r7}
        pop {lr}
	bx lr
/*-----------convierte de decimal a ascii el resultado----------------*/
//Funcion llamada en el main
//toma en r4 la direccion de memoria de resultado, y en r5 la direccion de
//memoria de text_result
//cambia resultado(int)a resultado(ascii).solo guarda, no devuelve nada.
//Llama a division (devulve en r0)

convertir_texto:

	push {lr}
	ldr r1,[r4]		//r1 = valor de resultado
	mov r2,#10		//r2 es lo que va a dividir a r1
	mov r7,#-1
	mov r8, #0		//contador de cuantas veces se va a hacer push

	cmp r1,#0
	bgt ciclo3		//si es positivo empieza a convertir el num

	//en caso de que fuera negativo:
	mov r6,#'-'
	strb r6, [r5]		//agrego a text_result el - si es negativo
	add r5, #1 	//apunto a la sig posicion en la que queremos guardar
	mul r1, r7 		//pasamos el resultado a positivo

ciclo3:
//r1 es a quien vamos a dividir, r2(10) por quien lo vamos a dividir y r0 es el
//resultado de division
	add r8, #1
	cmp r1,#10
	blt ultimo_numero	//cuando el resultado tenga 1 digito, sale
	bl division
	push {r1}		//se guarda el resto
	str r0, [r4]		//guardamos el resultado en r4
	ldr r1,[r4]		//carga en r1 el resultado de la division
	bal ciclo3

ultimo_numero:
	push {r1}
	mov r6, #0		 //segundo contador
ciclo4:
	cmp r6, r8
	beq saliir
	pop {r1}
	add r6, #1
	add r1,#0x30
	strb r1,[r5]		//guardamos el caracter
	add r5, #1		//suma para apuntar la sig. posicion
	bal ciclo4

saliir:
	push {r7}
	mov r7, #0x10		//agrega un salto de linea
	strb r7, [r5]
	pop {r7}
	pop {lr}
	bx lr

/*-----------saca el signo----------------------------------------*/
//Funcion llamada en es_cuenta
//verifica si los numeros son negativos, en caso de que alguno
//sea negativo guarda un -1 en la etiqueta signo_num1 o signo_num2
// develve nada

sacar_signo:
	push {r6}
	cmp r1, #'-'
	beq es_negativo1
	mov r6, #1			//si es positivo guardamos 1
	str r6, [r2]
	termino:
	pop {r6}
	bx lr

	es_negativo1:
	mov r6, #-1
	str r6, [r2]		//guardamos -1 en signo_numx
	add r0, #1		//ya apunta al primer digito para extraer
	bal termino


/*-----------------mostrar el mensaje de error-----------------------------*/
//muestra error en caso de que haya.
//Funcion llamada en el main
mostrar_error:
		.fnstart

		push {r0, r1, r2, r7}
		mov r7,#4
		mov r0,#1
		mov r2,#24
		ldr r1,=mensaje_error
		swi 0
		pop {r0, r1, r2, r7}
		bx lr
		.fnend

/*-----------------extrae el operador-------------*/
//Funcion llamada por es_cuenta
//solo guarda el operador(ascii) en su etiqueta.toma en r0 la  direccion
// de memoria de pregunta.
	operador:
		push {r3}
		add r0, r0, #1
		ldrb r1, [r0]		//carga el sig caracter
		ldr r3, =op
		strb r1, [r3]		//guardamos el operador
		pop {r3}
		bx lr

/*---------------obtener valores---------------------------------*/
//Llama a la funcion longitud
//Funcion llamada por el main
//Carga el valor de el num(ascii) pasado en su etiqueta.Toma en r10 la
//direccion del numero(int) donde vamos a guardar y  en r1 la direccion
//del num(ascii)
//para obtener su valor.llama a longitud(devuelve en r3)y en r7 la direccion
//del signo del operando que le pasemos. Tambien verifica que el numero no
//tenga mas de 7 digitos.

obtener_valores:
	//r10: direccion de memoria
	push {lr}
	push {r5, r8, r9}
	mov r0 ,#1 		//Unidades
	mov r5,#10 		//numero base
	mov r8,#0 		//num de destino
	mov r11,#0 		//contador
	mov r6,#0 		//caracter a recorrer
	bl longitud		//r3 = longitud

	add r10, r3
ciclo1:
	cmp r11, r3
	beq listo

	add r11, #1
	sub r10, #1      	//retrocede uno  para llegar a caracter ant
	ldrb r6, [r10]    	//consigo ultimo caracter en r6

	sub r6,#0x30  		//resto para consegir num
	mul r6, r0     		//pos correspondiente
	add r8,r8, r6     	//sumo num de destino
	mul r0, r5
	bal ciclo1
listo:

	ldr r9, [r7]   		//"obtengo" signo
	mul r8, r9
	str r8, [r2]    	//guardo num en r2


	pop {r5, r8, r9}
	pop {lr}
	bx lr


/*--------------resolver operacion--------------------------*/
//Funcion llamada por el main
//Resuelve la operacion segun el operador.Toma en r6 la direccion del operador
//en r0 la direccion de num1,r3 num2 y el resultado en r5.guarda o devuelve
//error.Tambien llama a division(devuelve el resultado en r0).

res_operacion:

	ldrb r7, [r6]		//cargamos el operador en r7
	ldr r1,[r0]		//cargamos num1 en r1
	ldr r2,[r3]		//cargamos num2 en r2


	cmp r7,#'+'   /*COMPARA OPERADORES*/
	beq es_suma

	cmp r7,#'-'
	beq es_resta

	cmp r7,#'*'
	beq multiplicacion

	cmp r7,#'/'
	beq dividir

	mov r4,#'E'            //si no es ninguno es error
	bx lr

dividir:
	push {r0, r6, lr}

	ldr r4,=signo_num1
	ldr r6,=signo_num2
	ldr r4,[r4]          //obtengo "signo"
	ldr r6,[r6]


	mul r1,r4              //multiplicamos para obtener num positivos
	mul r2,r6

	bl division             //devuelve en r0 el resul

	mul r0,r4               //multiplico para obtener el signo
	mul r0,r6               //correspondiente

	str r0, [r5]            //guardo resul
	pop {r0, r6, lr}
	bx lr

multiplicacion:
	mul r1, r2
	str r1,[r5]	//guarda lo que da la multiplicacion en r5= resultado
	bx lr

es_resta:		//resto y guardo en resultado
	sub r1,r1, r2
	str r1,[r5]
	bx lr

es_suma:

	add r1,r1,r2  	//suma y guarda en resultado
	str r1,[r5]
	bx lr

/*----------------------limpia las etiquetas text_num------------*/
//Funcion llamada en el main
//No devuelve nada, solo  limpia las etiquetas text_num en caso de que se
//vuelva a preguntar
resetear:
	//r1 =direccion de text_numx
	push {r0, r3}
	mov r0, #0	//contador
	mov r3, #0x20	//para volver a rellenar con espacio
	limpiar:
	cmp r0, #7
	beq termino_de_limpiar
	add r0, #1
	strb r3, [r1]
	add r1, #1
	bal limpiar
	termino_de_limpiar:
	pop {r0, r3}
	bx lr

/*--------------------resetear text_result--------------------*/
//Funcion llamada en el main, no devuelve nada
//Solo reinicia el resultado en texto
resetear_resultado:
	push {r0}
	mov r0, #0
	str r0, [r1]
	pop {r0}
	bx lr

/*----------------------main------------------*/
.global main
main:

empezar_de_cero:

		ldr r10, =mensaje_ing
		bl longitud			//obtengo longitud
		bl mostrar_pregunta

		mov r4, #0

		ldr r5,=pregunta
		bl ingresa_pregunta

		ldr r0, =pregunta
		bl pregunta_valida	//llama a es_digito
		cmp r4,#'E'
		beq error

		//verificar si la pregunta ingresada es valida
		bl es_cuenta 	//llama a numero,sacar_sig,operador.
		cmp r4, #'E'
		beq error


		//pasar num1 de ascii a decimal
		ldr r2, =num1
		ldr r10, =text_num1	//antes era r1
		ldr r7, =signo_num1
		bl obtener_valores	//llama a long
		cmp r4, #'E'
		beq error

		//pasar num2 de ascii a decimal
		ldr r2, =num2
		ldr r10, =text_num2	//antes era r1
		ldr r7, =signo_num2
		bl obtener_valores	//llama a long
		cmp r4, #'E'
		beq error

		//resolver la operacion
		ldr r6,=op
		ldr r0,=num1
		ldr r3,=num2
		ldr r5,=resultado
		bl res_operacion 	//llama a division
		cmp r4,#'E'
		beq error

		//convierte   resul a ascii
		ldr r4, =resultado
		ldr r5, =text_result
		bl convertir_texto	//llama a division


		//muestra el resultado
		ldr r10, =text_result
		bl longitud		//obtengo longitud
		bl mostrar_resultado


		//pregunta si quiere salir
		ldr r10, =mensaje
		bl longitud
		bl mostrar_pregunta
		//ingresa la pregunta(respuesta en este caso)
		ldr r5, =pregunta
		bl ingresa_pregunta

		//ananalizamos si comenzar de nuevo o salir
		ldr r1,=pregunta
		ldrb r0,[r1]
		cmp r0, #113 //comparo la pos1 con q, si es termina el programa
		beq pulso_q

		cmp r0, #97 //si no, comparo con a y comienzo de nuevo.
		beq pulso_a
		bal error

		pulso_a:
		//limpia las etiquetas
		ldr r1, =text_num1
		bl resetear

		ldr r1, =text_num2
		bl resetear

		ldr r1, =text_result
		bl resetear_resultado

		bal empezar_de_cero

		pulso_q:
		//elijio salir

		ldr r10, =saludo
		bl longitud
		bl mostrar_pregunta
		bal termino_programa

//muestra el error en caso de que haya:
error:
		bl mostrar_error

//sale del programa:
termino_programa:
		mov r7,#1
		swi 0

