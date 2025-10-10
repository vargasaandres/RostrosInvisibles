#---- librerias para ejecución ----
library(shiny)
library(mongolite)
library(dplyr)
library(plotly)
library(ggplot2)
library(DT)
library(DBI)
library(jsonlite)
library(shinyjs)
library(shinyalert)
library(jose)
library(base64enc)
library(shiny.router)
library(writexl)
library(blastula)
library(openxlsx)
library(glue)
library(later)
library(httpuv)
library(sass)




#---- Front ----
ui <- fluidPage(
  useShinyjs(),  # Necesario para shinyj
  
  
  tags$head(
    tags$head(
      
      # Script para manejar el JWT
      tags$script(HTML("
  $(document).on('shiny:connected', function() {
    var token = sessionStorage.getItem('jwt');
    if (token) {
      // Forzar refresco de input para disparar observeEvent
      Shiny.setInputValue('jwt_token', null);
      Shiny.setInputValue('jwt_token', token, {priority: 'event'});
    }
  });
")),
      
      # Estilos CSS para el login
      tags$style(HTML("

/* === GENERAL === */
body {
  background-color: #f4f6fa !important;
  color: #1f2937 !important;
  font-family: 'Segoe UI', 'Roboto', sans-serif !important;
  font-size: 15px;
}

/* === LOGIN === */
.login-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background: #f4f6f9;
}

.login-box {
  width: 360px;
  padding: 30px;
  background: white;
  border-radius: 16px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  text-align: center;
  font-family: 'Segoe UI', sans-serif;
  transition: box-shadow 0.3s ease;
}

.login-box:hover {
  box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
}

.login-box h2 {
  margin-bottom: 20px;
  font-weight: 600;
  color: #333;
}

.login-box input[type='text'],
.login-box input[type='password'] {
  width: 100%;
  padding: 10px 14px;
  margin-bottom: 15px;
  border: 1px solid #ccc;
  border-radius: 8px;
  background: #f9f9f9;
  transition: border-color 0.3s, background 0.3s;
  font-size: 14px;
}

.login-box input:focus {
  border-color: #007bff;
  background: #fff;
  outline: none;
}

.btn-login {
  width: 100%;
  padding: 12px;
  background-color: #007bff;
  color: white;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  transition: background-color 0.3s ease;
  cursor: pointer;
}

.btn-login:hover {
  background-color: #0056b3;
}

/* === ELEMENTOS GENERALES === */
.custom-card,
.panel-control,
.panel-visual {
  background-color: #ffffff;
  padding: 24px;
  border-radius: 14px;
  box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
  margin-top: 20px;
  font-family: 'Segoe UI', sans-serif;
}

/* === BOTONES === */
.btn-custom {
  background-color: #3b82f6 !important;
  color: #fff !important;
  border-radius: 8px !important;
  padding: 8px 16px !important;
  font-weight: 600 !important;
  border: none !important;
  box-shadow: 0 3px 8px rgba(59, 130, 246, 0.3) !important;
  transition: all 0.2s ease-in-out !important;
}

.btn-custom:hover {
  background-color: #2563eb !important;
  box-shadow: 0 5px 12px rgba(37, 99, 235, 0.4) !important;
}

.btn-cancelar {
  background-color: #9ca3af !important;
  color: white !important;
  border-radius: 8px !important;
  padding: 8px 16px !important;
  border: none !important;
  transition: all 0.2s ease-in-out !important;
}

.btn-cancelar:hover {
  background-color: #6b7280 !important;
}

/* === INPUTS === */
select, input[type=text], .form-control, textarea {
  background-color: #ffffff !important;
  border: 1px solid #d1d5db !important;
  border-radius: 8px !important;
  padding: 6px 10px !important;
  font-size: 14px !important;
  box-shadow: 0 1px 3px rgba(0,0,0,0.05);
  transition: border 0.2s ease-in-out;
}

select:focus, input:focus, textarea:focus {
  border-color: #3b82f6 !important;
  box-shadow: 0 0 0 2px rgba(59,130,246,0.2) !important;
}

/* === TABLAS === */
.table.dataTable {
  background-color: #ffffff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(0,0,0,0.07);
  font-size: 14px;
}

.dataTable th {
  background-color: #3b82f6;
  color: white;
  text-align: left;
  padding: 10px;
}

/* === MODAL ENCUESTA === */

/* Fondo con blur */
.modal-backdrop.show {
  backdrop-filter: blur(12px) brightness(0.9);
  -webkit-backdrop-filter: blur(12px) brightness(0.9);
  background-color: rgba(0, 0, 0, 0.5) !important;
  transition: all 0.3s ease-in-out !important;
}

/* Contenedor */
.modal-content {
  border-radius: 18px !important;
  border: none !important;
  background: rgba(255, 255, 255, 0.9) !important; /* ← más sólido */
  backdrop-filter: blur(15px);
  -webkit-backdrop-filter: blur(15px);
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3) !important;
  color: #111827 !important;
  font-family: 'Segoe UI', sans-serif !important;
  overflow: hidden !important;
}

/* Cabecera */
.modal-header {
  background: linear-gradient(90deg, #1e3a8a 0%, #3b82f6 100%);
  color: white !important;
  text-align: center;
  border-bottom: 3px solid #2563eb !important;
  justify-content: center !important;
  padding: 16px !important;
}

.modal-title {
  font-weight: 700 !important;
  font-size: 20px !important;
  letter-spacing: 0.3px !important;
  margin: 0 !important;
}

/* Cuerpo */
.modal-body {
  padding: 25px 35px !important;
  font-size: 15px !important;
  color: #111827 !important;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

/* Footer */
.modal-footer {
  border-top: none !important;
  padding: 20px !important;
  display: flex;
  justify-content: center;
  gap: 12px;
}

/* Animación */
.modal.fade .modal-dialog {
  transform: translate(0, -20px);
  transition: all 0.3s ease-out;
}

.modal.show .modal-dialog {
  transform: translate(0, 0);
}

/* === Encuesta interna === */
.encuesta-campos {
  display: flex;
  flex-direction: column;
  gap: 14px;
  margin-bottom: 10px;
}

.encuesta-titulo {
  text-align: center;
  color: #1e3a8a;
  font-weight: 600;
  margin-bottom: 18px;
}

/* Contenedor de botones principales */
.botones-principales {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 14px;  /* separa los botones */
  margin-top: 20px;
  margin-bottom: 20px;
}

/* Ajuste de botones dentro del contenedor */
.botones-principales .btn-custom {
  min-width: 200px;
  text-align: center;
}

  #password:focus {
    outline: none !important;
  }
  #password:focus-within {
    border-color: #3b82f6 !important;
  }
  
  
  
    .input-limpio {
    border: none !important;
    background: transparent !important;
    outline: none !important;
    box-shadow: none !important;
  }


"))
    )
    ),
    
    #---- Login Panel----
    div(id = "loginPanel", class = "login-container",
        div(class = "login-box",
            div(
              style = "text-align: center; font-weight: bold; font-size: 18px; margin-bottom: 20px;",
              "¡ROSTROS INVISIBLES, EL COSTO DEL SILENCIO!", tags$br(),
              "Inicia sesion, por favor"
            ),
            # Campo Usuario con placeholder
            tags$div(
              style = "margin-bottom: 20px;",
              tags$div("Correo", style = "text-align: center; font-weight: bold; margin-bottom: 5px;"),
              tags$input(
                id = "username",
                type = "text",
                class = "input-limpio",
                placeholder = "Ingrese su correo",
                style = "width: 100%; padding-right: 40px; height: 35px; box-sizing: border-box;"
              )
            ),
            
            # Campo Contraseña con placeholder y ojo
            
            tags$div(
              style = "position: relative; margin-bottom: 20px;",
              
              tags$div(
                "Contraseña",
                style = "text-align: center; font-weight: bold; margin-bottom: 5px;"
              ),
              
              # === Contenedor con borde único y align-items:center (centra verticalmente) ===
              tags$div(
                style = "
      display: flex;
      align-items: center;           /* centra verticalmente el contenido */
      position: relative;
      border: 1px solid #ccc;
      border-radius: 8px;
      background: #f9f9f9;
      height: 40px;                  /* altura fija del recuadro */
      padding-left: 12px;            /* espacio interior izquierdo */
      box-sizing: border-box;        /* importante para que padding no aumente la altura */
      transition: border-color 0.2s ease;
      overflow: hidden;
    ",
                tags$input(
                  id = "password",
                  type = "password",
                  placeholder = 'Ingrese su contraseña',
                  # sin class="form-control" (evitamos estilos bootstrap)
                  style = "
        flex: 1;                      /* ocupa el espacio disponible */
        border: none;                 /* sin borde propio */
        background: transparent;
        padding: 0 44px 0 0;          /* padding-right amplio para no tapar con el ícono */
        height: auto;                 /* no forzar 100% */
        min-height: 24px;
        box-sizing: border-box;       /* que padding se calcule dentro del alto */
        outline: none;
        box-shadow: none;
        font-size: 14px;
        color: #1f2937;
        vertical-align: middle;       /* ayuda en algunos navegadores */
        line-height: normal;
      "
                ),
                tags$i(
                  id = "togglePassword",
                  class = "fas fa-eye",
                  style = "
        position: absolute;
        right: 12px;
        top: 50%;
        transform: translateY(-50%);
        cursor: pointer;
        color: #6b7280;
        font-size: 18px;
        transition: color 0.15s ease;
      "
                )
              )
            ),
            
            # Botón de login
            actionButton("login", "Iniciar Sesión", class = "btn-login", style = "margin-top: 15px; width: 100%;"),
            
            # Enlaces de abajo
            tags$div(
              style = "margin-top: 10px;",
              actionLink("olvide_pass", "¿Olvidaste tu contraseña?")
            ),
            tags$div(
              style = "margin-top: 10px; text-align: center;",
              actionLink("register_link", "¿No tienes cuenta? Regístrate aquí")
            ),
    ),
        ),
    
    
    #---- Script para funcionalidad del ojito----
    tags$script(HTML("
    document.addEventListener('DOMContentLoaded', function() {
      const toggle = document.getElementById('togglePassword');
      const input = document.getElementById('password');
      if (!toggle || !input) return;
      toggle.addEventListener('click', function() {
        const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
        input.setAttribute('type', type);
        this.classList.toggle('fa-eye');
        this.classList.toggle('fa-eye-slash');
        this.style.color = type === 'text' ? '#3b82f6' : '#6b7280';
      });
      toggle.addEventListener('mouseover', function() { this.style.color = '#3b82f6'; });
      toggle.addEventListener('mouseout', function() { this.style.color = '#6b7280'; });
    });
  ")),
  
  
    # Cargar Font Awesome para el ícono del ojo
    tags$head(
      tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css")
    ),
    
    #---- Contenido de la app (Cajita en la izquierda)----
    shinyjs::hidden(
      div(id = "app_content",
          sidebarLayout(
            sidebarPanel(
              class = "panel-control",
              
              # Base de Datos
              selectInput(
                inputId = "bd", 
                label = tags$span("Base de Datos", title = "Selecciona la base de datos a usar"), 
                choices = character(0),
                selectize = FALSE
              ),
              
              # Colección
              selectInput(
                inputId = "coleccion", 
                label = tags$span("Colección", title = "Selecciona la colección dentro de la base de datos"), 
                choices = character(0),
                selectize = FALSE
              ),
              
              # Variable X
              selectInput(
                inputId = "xvar", 
                label = tags$span("Variable X", title = "Selecciona la variable para el eje X"), 
                choices = character(0),
                selectize = FALSE
              ),
              
              # Botón para intercambiar ejes
              actionButton("swap_axes", "Intercambiar Ejes", class = "btn-custom"),
              
              # Variable Y
              selectInput(
                inputId = "yvar", 
                label = tags$span("Variable Y", title = "Selecciona la variable para el eje Y"), 
                choices = character(0),
                selectize = FALSE
              ),
              
              # Tipo de gráfico
              selectInput(
                inputId = "grafico", 
                label = tags$span("Tipo de gráfico", title = "Elige el tipo de gráfico a generar"), 
                choices = c("Barras", "Puntos", "Líneas", "Histograma", "Caja"),
                selected = "Barras",
                selectize = FALSE
              ),
              
              # Botones
              tags$div(
                style = "margin-top: 10px;",
                actionButton("generar", "Generar Gráfico", class = "btn-custom"),
                downloadButton("descargar_excel", "Descargar Excel", class = "btn-custom"),
                downloadButton("descargar_zip", "Descargar carpeta de archivos", class = "btn-custom"),
                actionButton("support", "Soporte", class = "btn-custom"),
                actionButton("btn_encuesta", "Realizar encuesta", class = "btn-custom"),
                actionButton("actualizar_info", "Actualizar información", class = "btn-custom"),
                actionButton("logout", "Cerrar Sesión", class = "btn-custom")
              )
            ),
            
            mainPanel(
              class = "panel-visual",
              plotlyOutput("graficoSalida")
            )
          ),
          
          div(
            class = "custom-card",
            DTOutput("tablaDatos")
          )
      )
    )
    )
    

#---- Back ----
server <- function(input, output, session) {
  
  
  #---- Variables reactivas----
  user_authenticated <- reactiveVal(FALSE)
  mongo_url <- reactiveVal(NULL)
  datos_reactivos <- reactiveVal(data.frame())
  datos_casos_extorsion <- reactiveVal(data.frame())
  correo_en_verificacion <- reactiveVal(NULL)
  
  #---- Variable para controlar cooldown----
  ultima_solicitud <- reactiveVal(Sys.time() - 300)
  
  #---- Llave secreta para JWT (asegÃºrate que está seteada en tu entorno)----
  jwt_secret <- Sys.getenv("JWT_SECRET")
  if (jwt_secret == "") stop("JWT_SECRET no está definido en variables de entorno")
  
  #---- Crear token----
  crear_token <- function(username, mongo_url, bd = NULL, coleccion = NULL, xvar = NULL, yvar = NULL) {
    # Sanitizar el 'sub' (subject) para cumplir con el formato JWT
    safe_sub <- gsub("[^A-Za-z0-9_-]", "_", username)
    
    # Crear el claim, manteniendo el correo real en otro campo
    claim <- jwt_claim(
      sub = safe_sub,                  # ID interno seguro (sin caracteres inválidos)
      email = username,                # Guardamos el correo real del usuario
      mongo_url = mongo_url,
      bd = bd,
      coleccion = coleccion,
      xvar = xvar,
      yvar = yvar,
      iat = as.numeric(Sys.time()),    # tiempo de creación
      exp = as.numeric(Sys.time()) + 3600,  # expira en 1 hora
      jti = paste0(sample(c(0:9, letters), 16, replace = TRUE), collapse = "")
    )
    
    # Firmar el token con tu secreto
    jwt_encode_hmac(claim, secret = jwt_secret)
  }
  
  
  #---- Verificar token----
  verificar_token <- function(token) {
    tryCatch({
      decoded <- jwt_decode_hmac(token, secret = jwt_secret)
      payload <- decoded$payload
      if (is.null(payload$exp) || payload$exp < as.numeric(Sys.time())) return(NULL)
      return(payload)
    }, error = function(e) NULL)
  }
  
  
  #---- Función para obtener bases de datos----
  get_databases <- function(url_mongo) {
    tryCatch({
      conexion <- mongo(collection = "$cmd", db = "admin", url = url_mongo)
      resultado <- conexion$run('{"listDatabases": 1}')
      if (!is.null(resultado$databases)) {
        bases <- resultado$databases$name
        # Quitar "admin" y "local"
        bases_filtradas <- setdiff(bases, c("admin", "local", "UsuariosApp"))
        return(bases_filtradas)
      } else {
        return(NULL)
      }
    }, error = function(e) {
      return(NULL)
    })
  }
  
  #---- Función para obtener colecciones----
  get_collections <- function(db_name, url_mongo) {
    tryCatch({
      conexion <- mongo(db = db_name, url = url_mongo)
      conexion$run('{ "listCollections": 1 }')$cursor$firstBatch$name
    }, error = function(e) {
      return(NULL)
    })
  }
  
  #---- Función para obtener columnas de una colección----
  get_columns <- function(db_name, collection_name, url_mongo) {
    conexion <- mongo(collection = collection_name, db = db_name, url = url_mongo)
    if (!conexion$count()) return(NULL)
    datos <- conexion$find('{}', limit = 5)
    colnames(datos)
  }
  
  #---- Función para generar la URL de conexión a MongoDB----
  generate_mongo_url <- "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"

  
  #---- Verificar el token al cargar la app----
  observe({
    if (user_authenticated()) {
      hide("loginPanel")
      show("app_content")
    } else {
      show("loginPanel")
      hide("app_content")
    }
  })
  
  #---- Actualizar el selectInput de bases de datos----
  observeEvent(input$bd, {
    req(input$bd, mongo_url())
    updateSelectInput(session, "coleccion", choices = get_collections(input$bd, mongo_url()))
  })
  
  observeEvent(list(input$bd, input$coleccion, mongo_url()), {
    req(input$bd, input$coleccion, mongo_url())
    
    #---- Actualizar selects xvar y yvar basados en las columnas----
    cols <- tryCatch({
      get_columns(input$bd, input$coleccion, mongo_url())
    }, error = function(e) {
      showNotification("Error al obtener columnas para los selects", type = "error")
      return(character(0))  # Vacio para evitar error en updateSelectInput
    })
    
    updateSelectInput(session, "xvar", choices = cols)
    updateSelectInput(session, "yvar", choices = cols)
    
    #---- Intentar conectar y traer datos----
    conexion <- tryCatch({
      mongo(collection = input$coleccion, db = input$bd, url = mongo_url())
    }, error = function(e) {
      showNotification("Error al conectar con MongoDB para cargar datos", type = "error")
      return(NULL)
    })
    
    if (!is.null(conexion)) {
      datos <- tryCatch({
        conexion$find('{}')
      }, error = function(e) {
        showNotification("Error al obtener datos de la colección", type = "error")
        return(data.frame())
      })
      
      datos_reactivos(datos)
    }
  })
  
  #---- Actualizar tabla de datos----
  output$tablaDatos <- renderDT({
    req(datos_reactivos())
    datatable(datos_reactivos(), selection = "single")
  })
  
  
  #---- Verifica si el token es válido al cargar la app----
  observeEvent(input$login, {
    req(input$username, input$password)
    
    # Conexión con las credenciales fijas
    url <- "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
    
    # Conexión a la colección de usuarios
    usuarios_collection <- mongo(collection = "User", db = "UsuariosApp", url = url)
    
    # Buscar usuario por correo
    usuario_encontrado <- usuarios_collection$find(
      query = sprintf('{"Correo": "%s"}', input$username),
      fields = '{"Nombre": 1, "Apellido": 1, "Correo": 1, "Contrasena": 1, "_id": 0}'
    )
    
    # Validar existencia y contraseña
    if (nrow(usuario_encontrado) == 1 &&
        usuario_encontrado$Contrasena == input$password) {
      
      # Autenticación exitosa
      user_authenticated(TRUE)
      
      # Guardar la URL de conexión técnica
      mongo_url(url)
      
      # Cargar bases disponibles para selects
      bases <- get_databases(url)
      updateSelectInput(session, "bd", choices = bases, selected = NULL)
      
      # Ocultar login y mostrar app
      shinyjs::hide("loginPanel")
      shinyjs::show("app_content")
      
      # Crear token con datos del usuario
      token <- crear_token(
        usuario_encontrado$Correo,
        url,
        list(
          nombre = usuario_encontrado$Nombre,
          apellido = usuario_encontrado$Apellido
        )
      )
      
      runjs(sprintf("sessionStorage.setItem('jwt', '%s');", token))
      
    } else {
      showNotification("Correo o contraseña incorrectos", type = "error")
      user_authenticated(FALSE)
    }
  })
  
  
  # Enviar al servidor el token guardado en sessionStorage al iniciar la app o refrescar
  observe({
    # Enviar token del sessionStorage a shiny (se ejecuta siempre que app carga o se refresca)
    runjs("Shiny.setInputValue('jwt_token', sessionStorage.getItem('jwt') || '', {priority: 'event'});")
  })
  
  
  #----JWT_TOKEN----    
  observeEvent(input$jwt_token, {
    req(input$jwt_token)
    
    claim <- verificar_token(input$jwt_token)
    
    if (!is.null(claim)) {
      user_authenticated(TRUE)
      mongo_url(claim$mongo_url)
      
      # Cargar bases y seleccionar bd guardada
      bases <- get_databases(claim$mongo_url)
      updateSelectInput(session, "bd", choices = bases, selected = claim$bd)
      
      # Delay para cargar colecciones despuÃ©s de que bd se actualice
      later::later(function() {
        if (!is.null(claim$bd) && claim$bd != "") {
          colls <- get_collections(claim$bd, claim$mongo_url)
          updateSelectInput(session, "coleccion", choices = colls, selected = claim$coleccion)
        }
      }, 0.5)
      
      # Luego cargar columnas y actualizar selects xvar, yvar
      later::later(function() {
        if (!is.null(claim$bd) && !is.null(claim$coleccion) && claim$coleccion != "") {
          cols <- get_columns(claim$bd, claim$coleccion, claim$mongo_url)
          updateSelectInput(session, "xvar", choices = cols, selected = claim$xvar)
          updateSelectInput(session, "yvar", choices = cols, selected = claim$yvar)
        }
      }, 1)
      
      shinyjs::show("app_content")
      shinyjs::hide("loginPanel")
      
    } else {
      user_authenticated(FALSE)
      runjs("sessionStorage.removeItem('jwt');")
      shinyjs::hide("app_content")
      shinyjs::show("loginPanel")
    }
  })
  
  # ---- SINCRONIZAR TOKEN CON SELECCIONES ----
  observe({
    req(user_authenticated())
    # Solo actualizar token si mongo_url y bd existen
    if (is.null(mongo_url()) || is.null(input$bd) || input$bd == "") return()
    
    token <- crear_token(
      username = NULL,  # Puedes guardar si la guardas en reactive o input
      mongo_url = mongo_url(),
      bd = input$bd,
      coleccion = input$coleccion,
      xvar = input$xvar,
      yvar = input$yvar
    )
    runjs(sprintf("sessionStorage.setItem('jwt', '%s');", token))
  })
  
  
  #---- ACTUALIZACIÓN DE COLECCIONES Y COLUMNAS ----
  observeEvent(input$bd, {
    req(input$bd, mongo_url())
    colls <- get_collections(input$bd, mongo_url())
    updateSelectInput(session, "coleccion", choices = colls, selected = NULL)
  })
  
  # Actualizar columnas cuando cambie la colección 
  observeEvent(input$coleccion, {
    req(input$coleccion, input$bd, mongo_url())
    cols <- get_columns(input$bd, input$coleccion, mongo_url())
    updateSelectInput(session, "xvar", choices = cols, selected = NULL)
    updateSelectInput(session, "yvar", choices = cols, selected = NULL)
    
    # Cargar datos en reactive
    conexion <- mongo(collection = input$coleccion, db = input$bd, url = mongo_url())
    datos <- conexion$find('{}')
    datos_reactivos(datos)
  })
  
  #---- Cargar datos cuando cambien bd, coleccion o url----
  observeEvent(list(input$bd, input$coleccion, mongo_url()), {
    req(input$bd, input$coleccion, mongo_url())
    conexion <- tryCatch(mongo(collection = input$coleccion, db = input$bd, url = mongo_url()), error = function(e) NULL)
    if (!is.null(conexion)) {
      datos <- tryCatch(conexion$find('{}'), error = function(e) data.frame())
      datos_reactivos(datos)
    }
  })
  
  # --- GRÁFICO ---
  output$graficoSalida <- renderPlotly({
    req(input$coleccion, input$xvar, input$yvar, mongo_url())
    
    conexion <- mongo(collection = input$coleccion, db = input$bd, url = mongo_url())
    datos <- conexion$find('{}')
    datos_reactivos(datos)
    
    if (!(input$xvar %in% colnames(datos)) || !(input$yvar %in% colnames(datos))) {
      return(
        plot_ly() %>% 
          layout(
            xaxis = list(visible = FALSE),
            yaxis = list(visible = FALSE),
            annotations = list(
              text = "La magia está sucediendo âœ¨\n(Verifica tu selección)",
              showarrow = FALSE,
              font = list(size = 18, color = "grey"),
              xref = "paper",
              yref = "paper",
              x = 0.5,
              y = 0.5,
              xanchor = "center",
              yanchor = "middle"
            ),
            plot_bgcolor = 'rgba(0,0,0,0)',
            paper_bgcolor = 'rgba(0,0,0,0)'
          )
      )
    }
    
    colores_pastel <- c("#AEC6CF", "#FFB347", "#B39EB5", "#77DD77", "#FF6961", "#FDFD96", "#CB99C9", "#FFD1DC", "#CFCFC4")
    
    # Crear vector de colores repetidos segÃºn la longitud de datos
    colores_asignados <- rep(colores_pastel, length.out = nrow(datos))
    
    p <- plot_ly(datos)
    
    if (input$grafico == "Barras") {
      p <- p %>% add_bars(
        x = ~.data[[input$xvar]],
        y = ~.data[[input$yvar]],
        marker = list(color = colores_asignados),
        showlegend = FALSE
      )
    } else if (input$grafico == "Puntos") {
      p <- p %>% add_markers(
        x = ~.data[[input$xvar]],
        y = ~.data[[input$yvar]],
        marker = list(color = colores_asignados),
        showlegend = FALSE
      )
    } else if (input$grafico == "LÃ­neas") {
      p <- p %>% add_lines(
        x = ~.data[[input$xvar]],
        y = ~.data[[input$yvar]],
        line = list(color = colores_pastel[1]),
        showlegend = FALSE
      )
    } else if (input$grafico == "Histograma") {
      p <- plot_ly(
        datos, 
        x = ~.data[[input$xvar]],
        type = "histogram",
        marker = list(color = "#AEC6CF", line = list(color = "gray", width = 1)),
        showlegend = FALSE
      )
    } else if (input$grafico == "Caja") {
      p <- p %>% add_boxplot(
        x = ~.data[[input$xvar]],
        y = ~.data[[input$yvar]],
        marker = list(color = colores_asignados),
        showlegend = FALSE
      )
    }
    
    p %>% layout(
      xaxis = list(title = input$xvar),
      yaxis = list(title = input$yvar),
      title = paste("Gráfico de", input$grafico),
      showlegend = FALSE
    )
  })  
  
  
  #---- Cambiar variables X e Y----
  observeEvent(input$swap_axes, {
    req(input$xvar, input$yvar)
    updateSelectInput(session, "xvar", selected = input$yvar)
    updateSelectInput(session, "yvar", selected = input$xvar)
  })
  
  
  #----DESCARGAR EXCEL----
  output$descargar_excel <- downloadHandler(
    filename = function() {
      paste0("datos_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      req(datos_reactivos())
      library(openxlsx)
      
      datos <- datos_reactivos()
      
      # Detectar columnas tipo texto y aplicar saltos de lÃ­nea
      insertar_saltos <- function(x, n = 50) {
        vapply(x, function(celda) {
          if (is.na(celda)) return("")
          gsub(sprintf("(.{%d})", n), "\\1\n", as.character(celda), perl = TRUE)
        }, character(1))
      }
      
      columnas_texto <- sapply(datos, is.character) | sapply(datos, is.factor)
      
      datos_formateados <- datos  # Copia para modificar solo texto
      datos_formateados[, columnas_texto] <- lapply(datos[, columnas_texto, drop = FALSE], insertar_saltos)
      
      wb <- createWorkbook()
      addWorksheet(wb, "Datos")
      
      estilo_con_wrap <- createStyle(wrapText = TRUE, valign = "top")
      
      writeData(wb, "Datos", datos_formateados, withFilter = TRUE)
      
      addStyle(wb, "Datos", style = estilo_con_wrap,
               rows = 1:(nrow(datos_formateados) + 1),
               cols = which(columnas_texto),
               gridExpand = TRUE)
      
      setColWidths(wb, "Datos", cols = 1:ncol(datos), widths = "auto")
      setRowHeights(wb, "Datos", rows = 1:(nrow(datos) + 1), heights = "auto")
      
      saveWorkbook(wb, file, overwrite = TRUE)
    }
  )
  
  
  #----DESCARGAR ZIP----
  output$descargar_zip <- downloadHandler(
    filename = function() {
      paste0("PI_", Sys.Date(), ".zip")
    },
    content = function(file) {
      # Ruta dentro del proyecto (se sube a shinyapps.io o tu servidor)
      archivo_origen <- "www/PI.zip"
      
      # Copia el archivo directamente
      file.copy(from = archivo_origen, to = file)
    }
  )
  
  #----CONTRASEñA OLVIDADA----
  
  # helper: conexión (tu cadena intacta)
  mongo_conn <- function(collection) {
    mongo(
      collection = collection,
      db = "UsuariosApp",
      url = "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
    )
  }
  
  # Generar código (6 dígitos)
  generar_codigo6 <- function() sprintf("%06d", sample(0:999999, 1))
  
  # Único observe para flujo: pedir correo -> enviar código -> pedir código -> verificar y cambiar
  observeEvent(input$olvide_pass, {
    showModal(modalDialog(
      title = "Restablecimiento de contraseña",
      textInput("correo_reset", "Ingrese su correo", placeholder = "ejemplo@dominio.com"),
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("enviar_codigo", "Enviar código", class = "btn-custom")
      ),
      size = "m",
      easyClose = TRUE
    ))
  })
  
  # Enviar código
  observeEvent(input$enviar_codigo, {
    req(input$correo_reset)
    m <- mongo_conn("User")
    
    # Buscar por campo 'Correo' (case-insensitive)
    usuario <- m$find(
      query = paste0('{"Correo": {"$regex": "^', tolower(input$correo_reset), '$", "$options": "i"}}'),
      limit = 1
    )
    
    if (nrow(usuario) == 0) {
      showNotification("Correo no encontrado", type = "error")
      return()
    }
    
    codigo <- generar_codigo6()
    expiracion <- as.integer(Sys.time()) + 60  # 60 segundos
    
    # Sobrescribir código anterior (atomic)
    m$update(
      query = paste0('{"Correo": {"$regex": "^', tolower(input$correo_reset), '$", "$options": "i"}}'),
      update = paste0('{"$set": {"codigo_reset": "', codigo, '", "codigo_expira": ', expiracion, '}}'),
      upsert = FALSE, multiple = FALSE
    )
    
    # Enviar correo (blastula). Asume creds_file("gmail_creds") existe
    email <- blastula::compose_email(
      body = md(glue::glue("
      Hola,\n\nHas solicitado cambiar tu contraseña.\n\nTu código de verificación es: **{codigo}**\n\nEste código expira en 1 minuto.\n\nSi no solicitaste esto, ignora este correo.
    "))
    )
    
    tryCatch({
      blastula::smtp_send(
        email,
        from = "recupecontrase@gmail.com",
        to = input$correo_reset,
        subject = "Código de verificación para cambiar contraseña",
        credentials = blastula::creds_file("gmail_creds")
      )
      showNotification("Código enviado. Revisa tu correo.", type = "message")
      removeModal()
      
      # Mostrar modal para ingresar código y nueva contraseña
      showModal(modalDialog(
        title = "Ingresa el código recibido",
        textInput("codigo_input", "Código de verificación"),
        passwordInput("nueva_pass", "Nueva contraseña"),
        passwordInput("nueva_pass2", "Confirma la contraseña"),
        footer = tagList(
          modalButton("Cancelar"),
          actionButton("verificar_codigo", "Verificar y guardar", class = "btn-custom")
        ),
        easyClose = TRUE
      ))
      
    }, error = function(e) {
      showNotification("Error al enviar el correo", type = "error")
      print(e$message)
    })
  })
  
  # Verificar y actualizar contraseña
  observeEvent(input$verificar_codigo, {
    req(input$codigo_input, input$nueva_pass, input$nueva_pass2)
    if (input$nueva_pass != input$nueva_pass2) {
      showNotification("Las contraseñas no coinciden", type = "error"); return()
    }
    
    m <- mongo_conn("User")
    # Buscar por Correo (case-insensitive) y codigo_reset exacto
    usuario <- m$find(
      query = paste0('{"Correo": {"$regex": "^', tolower(input$correo_reset), '$", "$options": "i"}, "codigo_reset": "', input$codigo_input, '"}'),
      limit = 1
    )
    
    if (nrow(usuario) == 0) {
      showNotification("Código inválido o correo no encontrado", type = "error"); return()
    }
    
    # Asegurarse que codigo_expira sea numérico y comparar
    expira <- as.numeric(usuario$codigo_expira[1])
    if (is.na(expira) || expira < as.integer(Sys.time())) {
      showNotification("Código inválido o expirado", type = "error"); return()
    }
    
    # Actualizar password (aquí deberías hashear la contraseña)
    m$update(
      query = paste0('{"Correo": {"$regex": "^', tolower(input$correo_reset), '$", "$options": "i"}}'),
      update = paste0('{"$set": {"Contrasena": "', input$nueva_pass, '"}, "$unset": {"codigo_reset": "", "codigo_expira": ""}}')
    )
    
    showNotification("Contraseña cambiada correctamente", type = "message")
    removeModal()
  })
  
  
  
  
  #---- Soporte tecnico ----
  
  observeEvent(input$support, {
    showModal(modalDialog(
      title = tags$strong("Crear/Seguir Ticket"),
      easyClose = TRUE,
      footer = modalButton("Cerrar"),
      size = "m",
      tags$div(
        style = "line-height: 1.6; font-size: 16px;",
        "Para contactar con soporte y crear tickets debe hacer click en el siguiente enlace.",
        tags$br(), tags$br(),
        "Recuerde, para ingresar al software de tickets debe hacerlo con su usuario y contraseña.",
        tags$br(),
        "Si no tiene usuario creado en el software de tickets, contacte al administrador por medio del siguiente correo:",
        tags$br(), tags$br(),
        tags$a(
          href = "mailto:rostrosinvisiblessoporte@gmail.com",
          "rostrosinvisiblessoporte@gmail.com",
          style = "font-weight: bold;"
        ),
        tags$br(), tags$br(),
        tags$a(
          href = "https://punditic.sd.cloud.invgate.net/portal",
          "Abrir portal de soporte",
          target = "_blank",
          style = "font-size: 18px; color: #007bff; font-weight: bold;"
        )
      )
    ))
  })
  
  
  
  #---- Cerrar sesión----
  observeEvent(input$logout, {
    shinyalert(
      title = "¿Cerrar sesión?",
      text = "¿Estás seguro de que deseas cerrar la sesión?",
      type = "warning",
      showCancelButton = TRUE,
      confirmButtonText = "Sí",
      cancelButtonText = "No",
      callbackR = function(confirm) {
        if (confirm) {
          # Borra JWT del navegador (sessionStorage + cookie)
          runjs("
          sessionStorage.removeItem('jwt');
          document.cookie = 'jwt=; expires=Thu, 01 Jan 2050 00:00:00 UTC; path=/;';
        ")
          
          # Limpia estado de la sesión
          user_authenticated(FALSE)
          
          # Limpia URL MongoDB y cualquier otro reactive relacionado
          try({
            mongo_url(NULL)
          }, silent = TRUE)
          
          # Oculta el contenido protegido y muestra el login
          shinyjs::hide("app_content")
          shinyjs::show("loginPanel")
          
          # Opcional: recargar sesión para limpiar completamente y evitar estados residuales
          # session$reload()
        }
      }
    )
  })
  
  #---- Abrir modal de registro ----
  observeEvent(input$register_link, {
    showModal(modalDialog(
      title = "Registro de nuevo usuario",
      easyClose = TRUE,
      footer = NULL,
      fluidPage(
        textInput("reg_nombre", "Nombre"),
        textInput("reg_apellido", "Apellido"),
        textInput("reg_correo", "Correo electrónico"),
        passwordInput("reg_pass1", "Contraseña"),
        passwordInput("reg_pass2", "Confirmar contraseña"),
        div(style = "text-align: center; margin-top: 15px;",
            actionButton("registrar_btn", "Registrar", class = "btn-primary"),
            modalButton("Cancelar")
        )
      )
    ))
  })
  
  
  #---- Botón de registrar ----
  observeEvent(input$registrar_btn, {
    # Sanitización básica
    nombre <- trimws(gsub("[^[:alnum:] ÁÉÍÓÚáéíóúñÑ]", "", input$reg_nombre))
    apellido <- trimws(gsub("[^[:alnum:] ÁÉÍÓÚáéíóúñÑ]", "", input$reg_apellido))
    correo <- trimws(tolower(input$reg_correo))
    pass1 <- input$reg_pass1
    pass2 <- input$reg_pass2
    
    # Validaciones
    if (correo == "" || nombre == "" || apellido == "" || pass1 == "" || pass2 == "") {
      showNotification("Por favor completa todos los campos.", type = "error")
      return()
    }
    
    if (!grepl("^[[:alnum:]._%+-]+@[[:alnum:].-]+\\.[A-Za-z]{2,}$", correo)) {
      showNotification("El correo no tiene un formato válido.", type = "error")
      return()
    }
    
    if (pass1 != pass2) {
      showNotification("Las contraseñas no coinciden.", type = "error")
      return()
    }
    
    # Conexión técnica
    url <- "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
    usuarios_collection <- mongo(collection = "User", db = "UsuariosApp", url = url)
    
    # Verificar si ya existe el correo
    existente <- usuarios_collection$find(
      query = sprintf('{"Correo": "%s"}', correo),
      fields = '{"Correo": 1, "_id": 0}'
    )
    
    if (nrow(existente) > 0) {
      showNotification("Este correo ya está registrado.", type = "error")
      return()
    }
    
    # Inserción del nuevo usuario
    nuevo_usuario <- list(
      Nombre = nombre,
      Apellido = apellido,
      Correo = correo,
      Contrasena = pass1
    )
    
    usuarios_collection$insert(nuevo_usuario)
    
    removeModal()
    showNotification("Registro exitoso. Ya puedes iniciar sesión.", type = "message")
  })
  
  
  #---- Modal de autorización para encuesta ----
  observeEvent(input$btn_encuesta, {
    showModal(modalDialog(
      title = "Autorización de manejo de datos personales",
      easyClose = FALSE,
      footer = NULL,
      size = "l",
      fluidPage(
        p("De acuerdo con la Ley 1581 de 2012 y el Decreto 1377 de 2013, 
         autorizo de manera libre, previa, expresa e informada el tratamiento 
         de mis datos personales con fines de investigación estadística, 
         divulgación a entidades gubernamentales y potenciales programas de ayuda."),
        checkboxInput("autoriza_datos", "Autorizo el manejo y tratamiento de mis datos personales", FALSE),
        div(style = "text-align:center; margin-top:15px;",
            actionButton("continuar_encuesta", "Continuar", class = "btn-custom"),
            # Usamos modalButton simple o tag button sin clase extra:
            tags$button("Cancelar", type = "button", class = "btn btn-cancelar", `data-dismiss` = "modal")
        )
      )
    ))
  })
  
  

  #---- Continuar a la encuesta si autoriza ----
  observeEvent(input$continuar_encuesta, {
    if (!isTRUE(input$autoriza_datos)) {
      showNotification("Debes autorizar el manejo de datos para continuar.", type = "error")
      return()
    }
    removeModal()
    
    showModal(modalDialog(
      title = NULL,
      easyClose = FALSE,
      footer = NULL,
      size = "m",
      tags$div(class = "encuesta-modal",
         tags$h3("Encuesta sobre casos de extorsión", class = "encuesta-titulo"),
         div(class = "encuesta-campos",
             selectInput("q_genero", "Género de la víctima:", choices = c("Masculino", "Femenino", "Otro")),
             selectInput("q_edad", "Rango de edad:", choices = c("Menor de 18", "18-25", "26-35", "36-45", "46-60", "Mayor de 60")),
             selectInput("q_zona", "Zona donde ocurrió la extorsión:", choices = c("Urbana", "Rural")),
             selectInput("q_tipo_extorsion", "Tipo de extorsión sufrida:", choices = c("Telefónica", "Virtual (redes sociales)", "Presencial", "Otra")),
             selectInput("q_frecuencia", "¿Con qué frecuencia ha sido contactado?", choices = c("Una vez", "Varias veces", "Frecuentemente")),
             selectInput("q_monto", "Monto exigido (rango aproximado en COP):", choices = c("Menos de 100.000", "100.000 - 500.000", "500.000 - 1.000.000", "Más de 1.000.000")),
             selectInput("q_denuncia", "¿Denunció el hecho ante las autoridades?", choices = c("Sí", "No")),
             selectInput("q_resultado", "¿Recibió algún tipo de respuesta o apoyo?", choices = c("Sí", "No")),
             sliderInput("q_afectacion", "Nivel de afectación emocional (1 a 10):", min = 1, max = 10, value = 5),
             textAreaInput("q_observaciones", "Observaciones adicionales (opcional):", "", width = "100%")
         ),
         div(class = "modal-footer", style = "width:100%;",
             actionButton("guardar_encuesta", "Guardar respuestas", class = "btn-custom"),
             tags$button("Cancelar", type = "button", class = "btn btn-cancelar", `data-dismiss` = "modal")
         )
      )
    ))
  })

#---- Guardar respuestas de la encuesta ----

observeEvent(input$guardar_encuesta, {
  req(input$q_genero, input$q_edad, input$q_zona, input$q_tipo_extorsion,
      input$q_frecuencia, input$q_monto, input$q_denuncia, input$q_resultado, input$q_afectacion)
  
  url <- "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0"
  casos_collection <- mongo(collection = "Casos", db = "CasosExtorsion", url = url)
  
  registro <- list(
    FechaRegistro = as.character(Sys.time()),
    Genero = input$q_genero,
    Edad = input$q_edad,
    Zona = input$q_zona,
    TipoExtorsion = input$q_tipo_extorsion,
    Frecuencia = input$q_frecuencia,
    Monto = input$q_monto,
    Denuncia = input$q_denuncia,
    Resultado = input$q_resultado,
    Afectacion = input$q_afectacion,
    Observaciones = input$q_observaciones
  )
  
  casos_collection$insert(registro)
  
  removeModal()
  showNotification("Encuesta guardada correctamente. ¡Gracias por tu participación!", type = "message")
})
  
  
  #---- Actualizar información ----
  observeEvent(input$actualizar_info, {
    showNotification("Actualizando información...", type = "message")
    
    mongo_conn <- mongo(collection = "Casos", db = "CasosExtorsion", url <- "mongodb+srv://kecarrilloc:Proyecto080225@cluster0.1ti18.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")
    datos_actualizados <- mongo_conn$find()
    datos_casos_extorsion(datos_actualizados)
    
    showNotification("Datos actualizados correctamente ✅", type = "message")
  })
  
}

shinyApp(ui, server)