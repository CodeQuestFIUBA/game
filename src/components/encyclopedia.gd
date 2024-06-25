extends Control
signal closeOptions
@onready var label_container = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options/ScrollContainer/VBoxContainer
@onready var label_subOptions_container = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions/ScrollContainer/VBoxContainer
@onready var labelButton: Button = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options/ScrollContainer/VBoxContainer/Button
@onready var labelSubptionsButton: Button = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions/ScrollContainer/VBoxContainer/Button
@onready var fistScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/Options;
@onready var secondScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/SubOptions
@onready var thirdScreen = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer
@onready var title = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/Label
@onready var content = $PanelContainer/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/Label
@onready var backContainer = $PanelContainer/MarginContainer/MarginContainer
@onready var closeButton = $PanelContainer/MarginContainer/MarginContainer2

var options = [
	{
		"title": "Introducción a la algoritmia",
		"subtemas": [
		{
			"title": "Definición de Algoritmo",
			"content": "Un algoritmo es una secuencia finita de instrucciones bien definidas y ordenadas que permiten resolver un problema o realizar una tarea."
		},
		{
			"title": "Tipos de Algoritmos",
			"content": "Existen diferentes tipos de algoritmos, como los algoritmos de búsqueda, algoritmos de ordenamiento, algoritmos de optimización y algoritmos recursivos, cada uno diseñado para resolver problemas específicos."
		},
		{
			"title": "Complejidad Algorítmica",
			"content": "La complejidad algorítmica se refiere al análisis de la eficiencia de los algoritmos en términos de tiempo y espacio, utilizando notaciones como la Notación Big O para describir su comportamiento."
		},
		{
			"title": "Diseño de Algoritmos",
			"content": "El diseño de algoritmos involucra técnicas como divide y vencerás, programación dinámica y backtracking, y también incluye la prueba de corrección y la verificación y validación de los algoritmos."
		}
		]
	},
	{
		"title": "Bases de la programación",
		"subtemas": [
		{
			"title": "Tipos de Datos",
			"content": "Los tipos de datos básicos incluyen enteros, flotantes, caracteres y booleanos, y las estructuras de datos más complejas como arreglos, listas, tuplas y diccionarios."
		},
		{
			"title": "Estructuras de Control",
			"content": "Las estructuras de control en programación incluyen condicionales (if, else, else if) y bucles (for, while, do-while), que permiten controlar el flujo de ejecución de un programa."
		},
		{
			"title": "Sintaxis y Semántica",
			"content": "La sintaxis se refiere a las reglas gramaticales del lenguaje de programación, mientras que la semántica se ocupa del significado de las construcciones del lenguaje."
		},
		{
			"title": "Entornos de Desarrollo",
			"content": "Los entornos de desarrollo integrados (IDE) proporcionan herramientas para escribir, depurar y ejecutar programas, facilitando el proceso de desarrollo de software."
		}
		]
	},
	{
		"title": "Matrices",
		"subtemas": [
		{
			"title": "Definición y Representación",
			"content": "Una matriz es una estructura de datos bidimensional que almacena elementos en filas y columnas, y se representa comúnmente como una lista de listas en muchos lenguajes de programación."
		},
		{
			"title": "Operaciones Básicas",
			"content": "Las operaciones básicas con matrices incluyen la creación, acceso, modificación y recorrido de elementos, así como operaciones matemáticas como suma, resta y multiplicación de matrices."
		},
		{
			"title": "Aplicaciones de Matrices",
			"content": "Las matrices se utilizan en una amplia variedad de aplicaciones, incluyendo procesamiento de imágenes, resolución de sistemas de ecuaciones lineales y representación de grafos en algoritmos de teoría de grafos."
		},
		{
			"title": "Optimización y Complejidad",
			"content": "La optimización en el uso de matrices involucra técnicas para reducir el consumo de memoria y mejorar la eficiencia de las operaciones, teniendo en cuenta la complejidad temporal y espacial de los algoritmos que las manipulan."
		}
		]
	},
	{
		"title": "Recursividad",
		"subtemas": [
		{
			"title": "Concepto de Recursividad",
			"content": "La recursividad es una técnica de programación en la que una función se llama a sí misma para resolver subproblemas más pequeños del problema original."
		},
		{
			"title": "Tipos de Recursividad",
			"content": "Existen diferentes tipos de recursividad, como la recursividad directa, indirecta, final y no final, cada una con sus propias características y usos."
		},
		{
			"title": "Ventajas y Desventajas",
			"content": "Las ventajas de la recursividad incluyen la simplificación de la solución de problemas complejos y la facilidad de comprensión, mientras que sus desventajas pueden incluir un mayor uso de memoria y potenciales problemas de rendimiento."
		},
		{
			"title": "Casos de Uso Comunes",
			"content": "Los casos de uso comunes de la recursividad incluyen algoritmos como la búsqueda binaria, el cálculo de factoriales, la generación de permutaciones y combinaciones, y la resolución de problemas de división y conquista como el algoritmo de Quicksort."
		}
		]
	},
	{
		"title": "Funciones y procedimientos",
		"subtemas": [
		{
			"title": "Definición y Diferencias",
			"content": "Las funciones son bloques de código que realizan una tarea específica y devuelven un valor, mientras que los procedimientos también realizan tareas específicas pero no devuelven un valor."
		},
		{
			"title": "Parámetros y Argumentos",
			"content": "Los parámetros son variables que se definen en la declaración de una función o procedimiento, y los argumentos son los valores reales que se pasan a estos parámetros cuando la función o procedimiento es llamado."
		},
		{
			"title": "Alcance de las Variables",
			"content": "El alcance de una variable se refiere a la región del programa en la que una variable puede ser accedida. Puede ser local, si está definida dentro de una función o procedimiento, o global, si está definida fuera de ellos."
		},
		{
			"title": "Recursividad en Funciones",
			"content": "La recursividad en funciones implica que una función se llame a sí misma directa o indirectamente, lo cual es útil para resolver problemas que pueden dividirse en subproblemas similares."
		}
		]
	},
	{
		"title": "Búsquedas",
		"subtemas": [
		{
			"title": "Búsqueda Lineal",
			"content": "La búsqueda lineal es un algoritmo de búsqueda que recorre cada elemento de una lista hasta encontrar el elemento buscado o llegar al final de la lista."
		},
		{
			"title": "Búsqueda Binaria",
			"content": "La búsqueda binaria es un algoritmo de búsqueda eficiente que se aplica en listas ordenadas, dividiendo repetidamente el espacio de búsqueda a la mitad hasta encontrar el elemento buscado."
		},
		{
			"title": "Búsquedas en Grafos",
			"content": "Las búsquedas en grafos incluyen algoritmos como la búsqueda en profundidad (DFS) y la búsqueda en amplitud (BFS), que se utilizan para recorrer o buscar nodos en estructuras de grafos."
		},
		{
			"title": "Algoritmos de Búsqueda Heurística",
			"content": "Los algoritmos de búsqueda heurística, como A* y Greedy, utilizan información adicional (heurísticas) para encontrar soluciones de manera más eficiente en problemas de búsqueda complejos."
		}
		]
	},
	{
		"title": "Buenas prácticas",
		"subtemas": [
		{
			"title": "Código Legible y Mantenible",
			"content": "Escribir código legible y mantenible incluye usar nombres de variables descriptivos, seguir convenciones de estilo de código, y añadir comentarios claros y útiles."
		},
		{
			"title": "Modularidad y Reutilización",
			"content": "La modularidad implica dividir el código en módulos o funciones que realizan tareas específicas, lo que facilita la reutilización del código y mejora su mantenibilidad."
		},
		{
			"title": "Pruebas y Depuración",
			"content": "Las pruebas y la depuración son esenciales para asegurar que el código funcione correctamente. Incluyen la escritura de pruebas unitarias, pruebas de integración y el uso de herramientas de depuración para encontrar y corregir errores."
		},
		{
			"title": "Gestión de Versiones",
			"content": "El uso de sistemas de control de versiones, como Git, permite rastrear cambios en el código, colaborar con otros desarrolladores y mantener un historial de versiones del proyecto."
		}
		]
	}
]



# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(options.size()):
		var newLabel = labelButton.duplicate()
		newLabel.text = options[i].title
		newLabel.visible = true
		newLabel.pressed.connect(_on_button_2_pressed.bind(i))
		label_container.add_child(newLabel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_2_pressed(index: int):
	var first = true
	for n in label_subOptions_container.get_children():
		if !first:
			label_subOptions_container.remove_child(n)
			n.queue_free()
		first = false
	for i in range(options[index].subtemas.size()):
		var newLabel = labelSubptionsButton.duplicate()
		newLabel.text = options[index].subtemas[i].title
		newLabel.visible = true
		newLabel.pressed.connect(_on_button_pressed.bind(index, i))
		label_subOptions_container.add_child(newLabel)
		fistScreen.visible = false
		secondScreen.visible = true
		backContainer.visible = true


func _on_button_pressed(i: int, j: int):
	title.text = options[i].subtemas[j].title
	content.text = options[i].subtemas[j].content
	fistScreen.visible = false
	secondScreen.visible = false
	thirdScreen.visible = true
	backContainer.visible = true


func _on_back_pressed():
	if secondScreen.visible:
		fistScreen.visible = true
		secondScreen.visible = false
		backContainer.visible = false
	elif thirdScreen.visible:
		thirdScreen.visible = false
		secondScreen.visible = true


func _on_close_pressed():
	emit_signal("closeOptions")
