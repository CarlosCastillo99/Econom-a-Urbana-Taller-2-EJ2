# Distribución Espacial de Composición Racial e Ingreso en Chicago

## Descripción

Este proyecto analiza la **distribución espacial de grupos raciales** (afroamericanos e hispanos) en Chicago y su relación con el **ingreso mediano** a nivel de census tract. El estudio examina la evolución de la segregación residencial entre 2000 y 2020, aplicando índices clásicos de segregación (Duncan & Duncan, 1955) y el análisis de **tipping points** de Schelling (1971) y Card et al. (2008).

## Autores

- **Luis Alejandro Rubiano Guerrero** - 202013482 - [la.rubiano@uniandes.edu.co](mailto:la.rubiano@uniandes.edu.co)
- **Andrés Felipe Rosas Castillo** - 202013471 - [a.rosas@uniandes.edu.co](mailto:a.rosas@uniandes.edu.co)
- **Carlos Andrés Castillo Cabrera** - 202116837 - [ca.castilloc1@uniandes.edu.co](mailto:ca.castilloc1@uniandes.edu.co)

**Universidad de los Andes** - Curso de Economía Urbana (2025)

## Estructura del Repositorio

```
├── README.md                         # Este archivo
├── LICENSE                           # Licencia MIT
├── main (2).tex                      # Documento principal en LaTeX
├── punto 2.R                         # Script de R con análisis completo
└── data/                             # (no incluido)
    ├── Boundaries - Census Tracts - 2010/
    │   └── geo_export_*.shp          # Shapefile de census tracts
    └── Combined_data_Panel (1).dta   # Panel demográfico 2000-2020
```

## Requisitos

### Software necesario
- **R** (versión ≥ 4.0)
- **LaTeX** (para compilar el documento)

### Paquetes de R
```r
library(sf)          # Datos espaciales
library(dplyr)       # Manipulación de datos
library(haven)       # Lectura de archivos .dta (Stata)
library(ggplot2)     # Visualización
library(scales)      # Formatos de escalas
```

### Datos requeridos

1. **Shapefile de census tracts** (Chicago 2010):
   - `geo_export_*.shp` con geometrías de los tracts
   - Variable clave: `geoid10`

2. **Panel demográfico** (`Combined_data_Panel.dta`):
   - Variables: `FIPS`, `year`, `Total_Pop`, `White_Pop`, `Black_Pop`, `Hispanic_Pop`, `Median_Inc`
   - Años disponibles: 2000, 2015, 2020

## Instrucciones de Uso

### 1. Configuración inicial
```r
# Establecer directorio de trabajo
setwd("ruta/a/tu/directorio")

# Cargar shapefile
tracts_chi <- st_read("Boundaries - Census Tracts - 2010/geo_export_*.shp") %>%
  mutate(geoid10 = as.character(geoid10))

# Cargar panel demográfico
panel <- read_dta("Combined_data_Panel (1).dta")
```

### 2. Estructura del análisis

El script `punto 2.R` está organizado en tres secciones principales:

#### **PUNTO 1**: Mapas de Composición Racial
- Construcción de `share_black` y `share_hispanic`
- Mapas por census tract (2000, 2015, 2020)
- Correlación con ingreso mediano
- Scatterplots con líneas de regresión

#### **PUNTO 2**: Índices de Segregación
- **Índice de Disimilitud (D)**: Mide qué % de un grupo debería reubicarse para igualar la distribución del otro
- **Índice de Aislamiento**: Probabilidad de que un miembro del grupo A tenga como vecino a alguien de su mismo grupo
- Cálculos para:
  - Afroamericanos vs Blancos
  - Hispanos vs Blancos

#### **PUNTO 3**: Tipping Points
- Identificación de umbrales de segregación
- Clasificación de tracts (por debajo/encima del tipping)
- Mapas con community areas superpuestas
- Análisis temporal de evolución de umbrales

### 3. Ejecutar el análisis completo
```r
# Fuente: punto 2.R
source("punto 2.R")

# O ejecutar por secciones según comentarios en el código
```

### 4. Compilar el documento
```bash
pdflatex main\ (2).tex
bibtex main\ (2)
pdflatex main\ (2).tex
pdflatex main\ (2).tex
```

## Principales Hallazgos

### Distribución Espacial

**Población Afroamericana:**
- Concentración extrema en **South Side** y **West Side**
- Subrepresentación en North Side y zonas costeras
- Patrón muy persistente entre 2000-2020
- Correlación con ingreso: **-0.51 a -0.56** (muy negativa)

**Población Hispana:**
- Corredor **Oeste-Suroeste** desde Pilsen/Little Village
- Expansión hacia Noroeste en 2015-2020
- Segregación moderada pero menor que afroamericanos
- Correlación con ingreso: **-0.06 a -0.12** (levemente negativa)

### Índices de Segregación (escala 0-100)

| Año  | D (Black-White) | Iso Black | D (Hispanic-White) | Iso Hispanic |
|------|-----------------|-----------|---------------------|--------------|
| 2000 | 85.5            | 89.8      | 59.2                | 68.5         |
| 2015 | 82.6            | 86.8      | 60.6                | 70.9         |
| 2020 | 81.8            | 85.6      | 59.4                | 69.5         |

**Interpretación:**
- **Segregación afroamericana**: Extremadamente alta y persistente (80-85% tendría que reubicarse)
- **Aislamiento afroamericano**: ~90% de vecinos son del mismo grupo
- **Segregación hispana**: Moderada-alta pero estable
- **Tendencia**: Ligera desegregación afroamericana, hispanos estables

### Tipping Points

| Año  | TP Minorías | TP Afroamericanos | TP Hispanos |
|------|-------------|-------------------|-------------|
| 2000 | 0.547       | 0.630             | 0.871       |
| 2015 | 0.076       | 0.392             | 0.505       |
| 2020 | 0.094       | 0.401             | 0.512       |

**Conclusiones:**
- **Chicago** se convierte en ciudad **majority-minority** (TP minorías cae de 55% a ~8%)
- **Tipping afroamericano** baja de 63% a 40%: umbrales más tempranos
- **Tipping hispano** cae drásticamente de 87% a 50%: expansión de enclaves latinos
- Evidencia de **dinámicas no lineales** al estilo Schelling

## Visualizaciones Generadas

El código produce automáticamente:

1. **Mapas de composición racial** (2000, 2015, 2020):
   - `map_black_facet.png`: % población afroamericana
   - `map_hisp_facet.png`: % población hispana

2. **Scatterplots ingreso vs composición**:
   - `scatter_black.png`: Correlación negativa fuerte
   - `scatter_hisp.png`: Correlación débil

3. **Mapas de tipping points**:
   - `tipping_minority_map.png`: Minorías en general
   - `tipping_minority_map_afro.png`: Afroamericanos
   - `tipping_minority_map_hispanos.png`: Hispanos

## Metodología

### Índice de Disimilitud (Duncan & Duncan, 1955)
$$D = \frac{1}{2} \sum_{i} \left| \frac{a_i}{A} - \frac{b_i}{B} \right|$$

- Rango: 0-100
- **Interpretación**: % del grupo minoritario que debe reubicarse para igualar distribución del mayoritario

### Índice de Aislamiento
$$P_A = \sum_{i} \left( \frac{a_i}{A} \right) \left( \frac{a_i}{a_i + b_i} \right)$$

- Rango: 0-100
- **Interpretación**: Probabilidad de que un miembro del grupo A tenga vecinos del mismo grupo

### Tipping Point (Card et al., 2008)
$$\text{TP} = \frac{x_{(k^*)} + x_{(k^*+1)}}{2}, \quad k^* = \arg\max_k (x_{(k+1)} - x_{(k)})$$

- Método: Mayor salto en distribución ordenada de shares
- Excluye extremos (< 1% y > 99%)
- Captura umbrales donde la segregación "salta"

## Interpretación Económica

### Persistencia de la segregación afroamericana
- Legado de **redlining** y **restrictive covenants**
- Concentración de vivienda pública en South/West Side
- **White flight** hacia suburbios (1960s-1980s)
- Desinversión y pérdida de empleo industrial

### Expansión de enclaves latinos
- Migración inicial a barrios industriales (Pilsen, Back of the Yards)
- Expansión por corredores de transporte (oeste/suroeste)
- **Gentrificación** cerca del CBD desplaza población hacia periferia
- Redes comunitarias refuerzan aglomeración

### Correlación con ingreso
- **Afroamericanos**: Fuerte penalización por concentración racial
- **Hispanos**: Relación más débil, mayor heterogeneidad de ingresos
- Consistente con modelos de **sorting residencial** con externalidades

## Referencias Principales

- **Duncan, O. D., & Duncan, B. (1955)**. A methodological analysis of segregation indexes. *American Sociological Review*, 20(2), 210-217.

- **Schelling, T. C. (1971)**. Dynamic models of segregation. *Journal of Mathematical Sociology*, 1(2), 143-186.

- **Card, D., Mas, A., & Rothstein, J. (2008)**. Tipping and the dynamics of segregation. *Quarterly Journal of Economics*, 123(1), 177-218.

## Notas Técnicas

### Supuestos clave
- **Census tracts** como unidad de análisis (geografía 2010)
- **Población total** como denominador para shares
- Exclusión de tracts con población cero
- Merge por `geoid10` (FIPS code a character)

### Consideraciones espaciales
- Community areas usadas como referencia geográfica
- Expansión del aeropuerto **O'Hare** explica desaparición de algunos tracts
- Geometrías validadas (`st_is_empty`)

### Robustez
- Tipping points sensibles a elección de rango de exclusión (1%-99%)
- Índices de segregación robustos a distintas agregaciones espaciales
- Correlaciones consistentes con literatura previa sobre Chicago

## Aplicaciones

Este análisis es útil para:
- **Policy makers**: Diseño de políticas de vivienda inclusiva
- **Urban planners**: Identificación de zonas de intervención prioritaria
- **Investigadores**: Estudio de dinámicas de segregación y movilidad residencial
- **ONGs**: Advocacy por equidad racial en acceso a amenidades urbanas



---

**Última actualización**: 2025  
**Curso**: Economía Urbana - Universidad de los Andes  
**Repositorio**: [carloscastillo99-econom-a-urbana-taller-2-ej2](https://github.com/CarlosCastillo99/)
