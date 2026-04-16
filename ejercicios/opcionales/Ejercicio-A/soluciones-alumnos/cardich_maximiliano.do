///////////////////////////////////////
// TRABAJO PRÁCTICO 1 - Curso STATA/R
// Ejercicio 1
// Alumno: Cardich Maximiliano Nicolás
///////////////////////////////////////

////////////////////////////////////
// Parte 1: Carga y exploración  ///
////////////////////////////////////

* Cargo la base de datos
sysuse auto.dta , clear

* Realizo una exploración de la base
describe
display as text "La cantidad de variables de la base son: " as result r(k)
display as text "La cantidad de observaciones de la base son: " as result r(N)

* Obtengo un resumen estadístico general de las variables numéricas
ds, has(type numeric) // guarda las variables numericas en la memoria
summarize `r(varlist)' // usa la lista de variables numericas para mostrar sus estadisticas

//////////////////////////////////////
// Parte 2: Variables y etiquetas  ///
//////////////////////////////////////

* Renombro la variable weight a peso y le asigno la etiqueta correspondiente
rename weight peso
label variable peso "Peso (libras)"

* Genero la variable precio_miles, y le asigno la etiqueta correspondiente
gen precio_miles = price/1000
label variable precio_miles "Precio (miles de USD)"

* Creo la variable pesado, que vale 1 si el peso es mayor a 3 mil libras (y no es missing). Por defecto vale 0
gen pesado = 0
replace pesado = 1 if peso>=3000 & peso!=.

* Creo la etiqueta para la variable pesado y le asigno valores según la variable
label variable pesado "Vehículo pesado"
label define pesado_label 0 "Liviano" 1 "Pesado"
label values pesado pesado_label

///////////////////////////////////////
// Parte 3: Limpieza y ordenamiento ///
///////////////////////////////////////

*Elimino las variables headroom y trunk
drop headroom trunk
*Elimino las observaciones cuya variable rep78 sea missing
drop if rep78 ==.
*Ordeno la base por precio, de mayor a menor
gsort -price

// Parte 4: Estadísticas descriptivas
* Tabla de frecuencia y porcentaje según origen del auto, para precios mayores a 4000
table foreign pesado if price > 4000 & price != ., statistic(frequency) statistic(percent, across(foreign))

*Tabla de promedio y desvío estandar de precio_miles y peso según origen del auto
table foreign, ///
    stat(mean precio_miles peso) ///
    stat(sd precio_miles peso) ///
    nformat(%9.2fc mean) ///  2 decimales y coma para las medias
    nformat(%9.1f sd) ///  1 decimal para los desvíos
	
* Nota: En mi versión de Stata la fila de total no se visualiza si se incluye la opción totals(). Por defecto sí lo hace.


////////////////////////
// Parte 5: Gráfico  ///
////////////////////////

twoway scatter precio_miles peso, ///
    title("Precio vs. Peso del vehículo") ///
    ytitle("Precio (miles de USD)") ///
    xtitle("Peso (libras)") ///
    msymbol(oh) mcolor("87 126 114") ///
    xlabel(1000(500)5000, grid glpattern(dot) glcolor(gs12)) /// 
    ylabel(0(5)20, grid glpattern(dot) glcolor(gs12)) ///       
    xscale(range(1000 5000)) yscale(range(0 20)) ///         
    graphregion(fcolor(white)) plotregion(fcolor(white))
	
	
////////////////////////////
// Parte 6: Exportación  ///
////////////////////////////

* Guardo la imagen del grafico	
graph export scatter_ejercicio1.png, replace
* Guardo la base modificada
save auto_modificada.dta, replace
	
	////////////////////// Realizado en STATA 17 ////////////////////////////////
