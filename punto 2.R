##########################################################
# Universidad de los Andes
# Taller 2 ejericio 2
# Nombre: Carlos Castillo
##########################################################
rm(list=ls())
# cargamos paquetes
library(sf)
library(dplyr)
library(haven)
library(ggplot2)
library(scales)
#--------------------------- Punto 1---------------------------------------------------
# definimos ruta
setwd("C:/Users/pc/Downloads/taller 2 urbana ej2")
# 1. cargar bases y revisar----
# cargamos el shapefile
tracts_chi <- st_read("Boundaries - Census Tracts - 2010 (1)/geo_export_a4ade1ed-743c-4dd8-ad1a-89b46b222cec.shp") %>%
  mutate(geoid10 = as.character(geoid10))  # asegurar que sea character

# Ver información básica
tracts_chi
names(tracts_chi)
head(tracts_chi)

# Veamos el mapa
plot(st_geometry(tracts_chi))

# Carguemos el panel con demografía por tract-año
panel <- read_dta("Combined_data_Panel (1).dta")

# Mira los nombres para ubicar ID y variables raciales:
names(panel)
# 2. Construcción de ID de tract y shares raciales (black / hispanos)----
panel <- panel %>%
  mutate(
    geoid10 = as.character(FIPS),            # ID del census tract en formato character (mismo que en el shapefile)
    share_black    = Black_Pop    / Total_Pop,   # fracción de población afroamericana en el tract
    share_hispanic = Hispanic_Pop / Total_Pop    # fracción de población hispana en el tract
  )
#revisemos
panel                    # inspección rápida del panel completo
names(panel)             # nombres de las variables disponibles
head(panel)              # primeras filas para verificar que los shares se calcularon bien


# merge: panel demográfico + geometría
chi_panel <- panel %>%
  left_join(tracts_chi, by = "geoid10") %>%  # unimos por geoid10 para añadir la geometría del tract
  st_as_sf()                                 # convertimos el resultado a objeto sf

# Chequeos rápidos del merge
sum(is.na(chi_panel$geometry))  # cuántas observaciones quedaron sin geometría
table(chi_panel$year)           # número de tracts por año después del merge

# Miramos cómo quedó el objeto combinado
chi_panel
names(chi_panel)
head(chi_panel)

# Nos quedamos solo con observaciones que sí tienen geometría válida
chi_panel_sf <- chi_panel %>%
  filter(!st_is_empty(geometry))

# Chequeos sobre el sf final
nrow(chi_panel_sf)                       # total de filas con geometría
sum(st_is_empty(chi_panel_sf$geometry))  # debería ser 0
table(chi_panel_sf$year)                 # distribución por año en el objeto final

# Revisión final del objeto que usaremos para mapas y regresiones
chi_panel_sf
names(chi_panel_sf)
head(chi_panel_sf)

# 3.1 Mapas para 2000: % población afroamericana por tract----
# Filtramos solo año 2000 y con dato de share_black
chi_black_2000 <- chi_panel_sf %>%
  filter(year == 2000, !is.na(share_black))
#revisemos
chi_black_2000
names(chi_black_2000)
head(chi_black_2000)

# Mapa afroamericanos, 2000

ggplot(chi_black_2000) +
  geom_sf(aes(fill = share_black),
          color = "grey30",  # bordes de los tracts
          size  = 0.1) +     # grosor de la línea
  coord_sf(datum = NA) +    # quita el grid de lat/long
  scale_fill_viridis_c(
    option   = "magma",
    direction = -1,
    limits   = c(0, 1),
    labels   = percent_format(accuracy = 1),
    name     = "% afroamericanos"
  ) +
  labs(
    title = "Chicago – % población afroamericana por census tract (2000)",
    x = NULL, y = NULL
  ) +
  theme_void() +            # sin ejes ni fondo
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 3.2 Mapas para 2000: % población hispana por tract----
# Ahora filtramos hispanos año 2000
chi_hisp_2000 <- chi_panel_sf %>%
  filter(year == 2000, !is.na(share_hispanic))
# Mapa hispanos, 2000

ggplot(chi_hisp_2000) +
  geom_sf(aes(fill = share_hispanic),
          color = "grey30",
          size  = 0.1) +
  coord_sf(datum = NA) +
  scale_fill_viridis_c(
    option   = "magma",
    direction = -1,
    limits   = c(0, 1),
    labels   = scales::percent_format(accuracy = 1),
    name     = "% hispanos"
  ) +
  labs(
    title = "Chicago – % población hispana por census tract (2000)",
    x = NULL, y = NULL
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )
# 3.3Ahora hagamos uno conjunto para afroamericanos e hispanos----
# 3.3.a Mapa afroamericanos para 2000,2015 y 2020----
chi_black_all <- chi_panel_sf %>%
  filter(!is.na(share_black))

ggplot(chi_black_all) +
  geom_sf(aes(fill = share_black),
          color = "grey30",
          size  = 0.1) +
  coord_sf(datum = NA) +
  scale_fill_viridis_c(
    option    = "magma",
    direction = -1,
    limits    = c(0, 1),
    labels    = scales::percent_format(accuracy = 1),
    name      = "% afroamericanos"
  ) +
  facet_wrap(~ year) +
  labs(
    title = "Chicago – % población afroamericana por census tract",
    x = NULL, y = NULL
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 3.3.b Mapa hispanos para 2000,2015 y 2020----

chi_hisp_all <- chi_panel_sf %>%
  filter(!is.na(share_hispanic))

ggplot(chi_hisp_all) +
  geom_sf(aes(fill = share_hispanic),
          color = "grey30",
          size  = 0.1) +
  coord_sf(datum = NA) +
  scale_fill_viridis_c(
    option    = "magma",      # misma paleta que black
    direction = -1,
    limits    = c(0, 1),
    labels    = scales::percent_format(accuracy = 1),
    name      = "% hispanos"
  ) +
  facet_wrap(~ year) +
  labs(
    title = "Chicago – % población hispana por census tract",
    x = NULL, y = NULL
  ) +
  theme_void() +
  theme(
    plot.title = element_text(hjust = 0.5)
  )

# 4. Correlaciones con el ingreso mediano del census tract----
# 4.1 Correlación share_black vs ingreso----
corr_black <- chi_panel_sf %>%
  st_drop_geometry() %>%              
  filter(!is.na(share_black), !is.na(Median_Inc)) %>%
  group_by(year) %>%
  summarise(
    cor_black_inc = cor(share_black, Median_Inc, use = "complete.obs"),
    .groups = "drop"
  )

corr_black
names(corr_black)
head(corr_black)

# Afroamericanos vs ingreso por tract y año

ggplot(
  chi_panel_sf %>% filter(!is.na(share_black), !is.na(Median_Inc)),
  aes(x = share_black, y = Median_Inc)
) +
  geom_point(alpha = 0.4, size = 1) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  facet_wrap(~ year) +
  scale_x_continuous(labels = percent_format(accuracy = 1),
                     name   = "% afroamericanos en el tract") +
  scale_y_continuous(labels = comma,
                     name   = "Ingreso mediano del census tract (USD)") +
  labs(title = "Relación entre % afroamericanos e ingreso mediano por census tract") +
  theme_minimal()

# 4.2 Correlación share_hispanic vs ingreso----
corr_hisp <- chi_panel_sf %>%
  st_drop_geometry() %>%
  filter(!is.na(share_hispanic), !is.na(Median_Inc)) %>%
  group_by(year) %>%
  summarise(
    cor_hisp_inc = cor(share_hispanic, Median_Inc, use = "complete.obs"),
    .groups = "drop"
  )

corr_hisp
names(corr_hisp)
head(corr_hisp)

#Hispanos vs ingreso por tract y año
ggplot(
  chi_panel_sf %>% filter(!is.na(share_hispanic), !is.na(Median_Inc)),
  aes(x = share_hispanic, y = Median_Inc)
) +
  geom_point(alpha = 0.4, size = 1) +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  facet_wrap(~ year) +
  scale_x_continuous(labels = percent_format(accuracy = 1),
                     name   = "% hispanos en el tract") +
  scale_y_continuous(labels = comma,
                     name   = "Ingreso mediano del census tract (USD)") +
  labs(title = "Relación entre % hispanos e ingreso mediano por census tract") +
  theme_minimal()


#--------------------------- Punto 2 ---------------------------------------------------
# 1. Índices de disimilitud y aislamiento a lo largo del tiempo ----

chi_nogeo <- chi_panel_sf %>%
  st_drop_geometry()

## 1.1 Afroamericanos (A) vs Blancos (B) ----------------------------

chi_bw <- chi_nogeo %>%
  mutate(
    POP_A    = Black_Pop,
    POP_B    = White_Pop,
    POP_pair = POP_A + POP_B
  ) %>%
  filter(
    !is.na(POP_A), !is.na(POP_B),
    POP_pair > 0
  )

seg_bw <- chi_bw %>%
  group_by(year) %>%
  summarise(
    A_tot = sum(POP_A, na.rm = TRUE),
    B_tot = sum(POP_B, na.rm = TRUE),
    
    # Índice de disimilitud (Duncan & Duncan, 1955)
    D_bw = 0.5 * sum(
      abs(
        (POP_A / sum(POP_A, na.rm = TRUE)) -
          (POP_B / sum(POP_B, na.rm = TRUE))
      ),
      na.rm = TRUE
    ),
    
    # Índice de aislamiento del grupo A (afroamericanos)
    Iso_black = sum(
      (POP_A / sum(POP_A, na.rm = TRUE)) * (POP_A / POP_pair),
      na.rm = TRUE
    ),
    
    # (opcional) aislamiento de blancos
    Iso_white = sum(
      (POP_B / sum(POP_B, na.rm = TRUE)) * (POP_B / POP_pair),
      na.rm = TRUE
    ),
    .groups = "drop"
  ) %>%
  mutate(
    D_bw      = 100 * D_bw,
    Iso_black = 100 * Iso_black,
    Iso_white = 100 * Iso_white
  )

seg_bw


## 1.2 Hispanos (A) vs Blancos (B) ----

chi_hw <- chi_nogeo %>%
  mutate(
    POP_A    = Hispanic_Pop,
    POP_B    = White_Pop,
    POP_pair = POP_A + POP_B
  ) %>%
  filter(
    !is.na(POP_A), !is.na(POP_B),
    POP_pair > 0
  )

seg_hw <- chi_hw %>%
  group_by(year) %>%
  summarise(
    A_tot = sum(POP_A, na.rm = TRUE),
    B_tot = sum(POP_B, na.rm = TRUE),
    
    D_hw = 0.5 * sum(
      abs(
        (POP_A / sum(POP_A, na.rm = TRUE)) -
          (POP_B / sum(POP_B, na.rm = TRUE))
      ),
      na.rm = TRUE
    ),
    
    Iso_hisp = sum(
      (POP_A / sum(POP_A, na.rm = TRUE)) * (POP_A / POP_pair),
      na.rm = TRUE
    ),
    Iso_white = sum(
      (POP_B / sum(POP_B, na.rm = TR
                   


