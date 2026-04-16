**************************
*TP2 Instrumentos computacionales
*Busso Jorgelina
**************************

clear all
set more off

cd "/Users/jorgelinabusso/Desktop/UNLP/Elementoscomputacionales/Stata/TP2-Busso/bases"

*** 1. Importar base comercios (carpeta actual: "bases")
import excel "comercios.xlsx", clear first 
*inspeccion y modificacion
describe
rename ID_comercio id_comercio 
*guardado temporal 
tempfile comercios
save comercios, replace

*** 2. Carga y union bases precios y productos
use "precios.dta"
describe
duplicates report id_producto
*merge: id_producto es la variable llave
merge m:1 id_producto using "productos.dta" , ///
label define lblmerge1 1 "precio" 2 "producto" 3 "match" ///
label values _merge lblmerge1
rename _merge _merge1
*mantener solo casos con match
keep if _merge1==3

*** 3. unifico con comercios (comercio y bandera)
merge m:1 id_comercio id_bandera using "comercios.dta" , ///
label define lblmerge2 1 "precio" 2 "comercio" 3 "match" ///
label values _merge lblmerge2
rename _merge _merge2
*mantener solo casos con match
keep if _merge2==3

*** 4. variable de identificacion de bandera 
egen store = group(id_bandera)
label variable store "store/bandera"

*---------------------------------------------*
*** 5. modificar base 
preserve
*detectar duplicados
duplicates tag id_producto store year, gen(dup)
*verlos
*list id_producto store year precio_promedio if dup
*como hay duplicados, se promedia el precio
collapse (mean) precio_promedio, by(id_producto store year)
*modificar base dejando producto-store como unidad de analisis
reshape wide precio_promedio, i(id_producto store) j(year)

*** 6. crear variacion porcentual entre 2024 y 2025
gen var_pct = (precio_promedio2025 - precio_promedio2024) / precio_promedio2024 * 100
label variable var_pct "variacion porcentual precio"

*** 7. indicadora variacion precio
gen subio = (var_pct > 0)
label variable subio "subio precio"

*** 8. productos que subieron de precio 
tab subio 

*** 9. productos que mantienen precio
count if var_pct == 0
*list id_producto store precio_promedio2024 precio_promedio2025 if var_pct == 0

*** 10. tabla promedio y desvio 
table store, contents(mean var_pct sd var_pct) format(%9.2f)

*---------------------------------------------*
*** 11. tablas desagregadas de la variacion promedio
*necesito recuperar variables rubro categoria y subcategoria 
restore
*filtro por variables necesarias
collapse (mean) precio_promedio, by(id_producto store year rubro categoria subcategoria)
*modificar base dejando producto-store como unidad de analisis
reshape wide precio_promedio, i(id_producto store rubro categoria subcategoria) j(year)
*vuelvo a crear variacion porcentual entre 2024 y 2025
gen var_pct = (precio_promedio2025 - precio_promedio2024) / precio_promedio2024 * 100
label variable var_pct "variacion porcentual precio"

*tabla 1: variacion promedio por store y rubro
table store rubro, contents(mean var_pct) format(%9.2f)

*tabla 2: variacion promedio por store y categoria
table store categoria, contents(mean var_pct) format(%9.2f)

*tabla 3: variacion promedio por store y subcategoria
table store subcategoria, contents(mean var_pct) format(%9.2f)

*---------------------------------------------*
*** 12. exportar tablas a excel 
*crear y guardar tablas resumidas en archivos temporales
tempfile tabla_rubro tabla_categoria tabla_subcategoria

*tabla 1: por rubro
preserve
collapse (mean) var_pct, by(store rubro)
save `tabla_rubro'
restore 

*tabla 2: por categoria
preserve
collapse (mean) var_pct, by(store categoria)
save `tabla_categoria'
restore 

*tabla 3: por subcategoria
preserve
collapse (mean) var_pct, by(store subcategoria)
save `tabla_subcategoria'
restore

* Exportar las tres tablas al mismo Excel (con codificación UTF‑8)
*hoja 1: rubro
use `tabla_rubro', clear
export excel using "tp2.xlsx", sheet("rubro") firstrow(variables) replace

*hoja 2: categoria
use `tabla_categoria', clear
export excel using "tp2.xlsx", sheet("categoria") firstrow(variables) sheetreplace

*hoja 3: subcategoria
use `tabla_subcategoria', clear
export excel using "tp2.xlsx", sheet("subcategoria") firstrow(variables) sheetreplace

*---------------------------------------------*
*** 13. Exportar usando bucle 
local tablas "`tabla_rubro' `tabla_categoria' `tabla_subcategoria'"
local nombres "rubro categoria subcategoria"
local contador = 0

foreach archivo of local tablas {
    local contador = `contador' + 1
    local nombre : word `contador' of `nombres'

    use "`archivo'", clear

    if `contador' == 1 {
        export excel using "tp2.xlsx", sheet("`nombre'") firstrow(variables) replace
    }
    else {
        export excel using "tp2.xlsx", sheet("`nombre'") firstrow(variables) sheetreplace
    }
}
