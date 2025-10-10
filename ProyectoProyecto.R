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
    
      /* Contenedor principal centrado */
  .login-container {
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    background: #f4f6f9;
  }

  /* Caja del login */
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

  /* Titulo */
  .login-box h2 {
    margin-bottom: 20px;
    font-weight: 600;
    color: #333;
  }

  /* Campos de entrada */
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

  /* Botón de login */
  .login-box .btn-login {
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

  .login-box .btn-login:hover {
    background-color: #0056b3;
  }

  /* Mensajes de error o alerta */
  .login-box .login-message {
    margin-top: 10px;
    color: #e74c3c;
    font-size: 13px;
  }

    /* Fondo general */
    body {
      background-color: #f4f6fa !important;
      color: #1f2937 !important;
      font-family: 'Segoe UI', 'Roboto', sans-serif !important;
      font-size: 15px;
    }
    
    /* Tarjetas principales */
    .custom-card {
      background-color: #ffffff;
      padding: 24px;
      border-radius: 14px;
      box-shadow: 0 6px 20px rgba(0,0,0,0.08);
      margin: 20px 0;
    }
    /* Botones elegantes más pequeños */
    .btn-custom {
      background-color: #3b82f6 !important;
      color: #fff !important;
      border-radius: 8px;
      padding: 6px 14px;          /* menos padding para que sea más pequeño */
      font-weight: 600;
      font-size: 14px;            /* fuente un poco más pequeña */
      border: none;
      box-shadow: 0 3px 8px rgba(59, 130, 246, 0.3);
      transition: all 0.2s ease-in-out;
      margin: 4px 0;
    }
    .btn-custom:hover {
      background-color: #2563eb !important;
      box-shadow: 0 5px 12px rgba(37, 99, 235, 0.4);
    }
    
    /* Inputs y selects más compactos */
    select, input[type=text], .form-control {
      background-color: #ffffff !important;
      border: 1px solid #d1d5db !important;
      border-radius: 8px !important;
      padding: 6px 10px !important;  /* menos padding */
      box-shadow: 0 1px 3px rgba(0,0,0,0.05);
      transition: border 0.2s ease-in-out;
      font-size: 14px;               /* tamaño de fuente un poco más pequeño */
    }
    
    /* Estilo para tablas */
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
    .dataTable td {
      padding: 10px;
    }
    
    /* Notificaciones y mensajes */
    .swal-text {
      color: #1f2937;
      font-weight: 500;
    }
    .swal-button {
      background-color: #10b981;
    }
    .swal-button:hover {
      background-color: #059669;
    }
        
    /* Panel de control lateral */
    .panel-control {
      background-color: #f8fafc;
      padding: 24px;
      border-radius: 14px;
      box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
      margin-top: 20px;
      font-family: 'Segoe UI', sans-serif;
    }
    
    
    /* Panel principal de visualización */
    .panel-visual {
    background-color: #ffffff;
    padding: 24px;
    border-radius: 14px;
    box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
    margin-top: 20px;
    font-family: 'Segoe UI', sans-serif;
  }


  
"))
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
              tags$div("USUARIO", style = "text-align: center; font-weight: bold; margin-bottom: 5px;"),
              tags$input(
                id = "username",
                type = "text",
                class = "form-control",
                placeholder = "Ingrese su usuario",
                style = "width: 100%; padding-right: 40px; height: 35px; box-sizing: border-box;"
              )
            ),
            
            tags$div(
              style = "position: relative; margin-bottom: 20px;",
              tags$div("Contraseña", style = "text-align: center; font-weight: bold; margin-bottom: 5px;"),
              tags$input(
                id = "password",
                type = "password",
                class = "form-control",
                placeholder = "Ingrese su contraseña",
                style = "width: 100%; padding-right: 40px; height: 40px; box-sizing: border-box;"
              ),
              tags$i(
                id = "togglePassword",
                class = "fas fa-eye",
                style = " position: absolute; top: 50%; height: 65px; right: 12px; transform: translateY(-50%); cursor: pointer; color: #6b7280;"
              ),
              actionButton("login", "Iniciar Sesión"),
              tags$div(
                style = "margin-top: 10px;",
                actionLink("olvide_pass", "¿Olvidaste tu contraseña?")
              ),
              tags$div(
                style = "margin-top: 10px; text-align: center;",
                actionLink("register_link", "¿No tienes cuenta? Regístrate aquí")
              ),
              
            ))
    ),
    
    
    #---- Script para funcionalidad del ojito----
    tags$script(HTML("
  document.addEventListener('DOMContentLoaded', function () {
    const toggle = document.getElementById('togglePassword');
    const input = document.getElementById('password');
    toggle.addEventListener('click', function () {
      const type = input.getAttribute('type') === 'password' ? 'text' : 'password';
      input.setAttribute('type', type);
      this.classList.toggle('fa-eye');
      this.classList.toggle('fa-eye-slash');
    });
  });
")),
    # Cargar Font Awesome para el Ã­cono del ojo
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
                choices = c("Barras", "Puntos", "LÃ­neas", "Histograma", "Caja"),
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
  
)

#---- Back ----
server <- function(input, output, session) {
  
  
  #---- Variables reactivas----
  user_authenticated <- reactiveVal(FALSE)
  mongo_url <- reactiveVal(NULL)
  datos_reactivos <- reactiveVal(data.frame())
  
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
        bases_filtradas <- setdiff(bases, c("admin", "local"))
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
  
  # Variable para controlar cooldown
  ultima_solicitud <- reactiveVal(Sys.time() - 300)
  
  #---- Mostrar modal para restablecer contraseña----
  observeEvent(input$olvide_pass, {
    showModal(modalDialog(
      title = "Solicitud de restablecimiento",
      textInput("usuario_reset", "Ingrese su usuario"),
      textInput("correo_user", "Correo de contacto", placeholder = "ejemplo@dominio.com"),
      footer = tagList(
        modalButton("Cancelar"),
        actionButton("enviar_solicitud", "Enviar solicitud")
      ),
      size = "m",
      easyClose = TRUE,
      fade = TRUE,
      style = "border-radius: 15px; padding: 20px; background-color: #f0f8ff;"
    ))
  })
  
  
  #---- Enviar correo al administrador----
  observeEvent(input$enviar_solicitud, {
    req(input$usuario_reset, input$correo_user)
    
    # Validar formato de correo simple
    if (!grepl(".+@.+\\..+", input$correo_user)) {
      shinyalert("Correo inválido", "Por favor ingresa un correo válido al que el administrador pueda contactarte.", type = "error")
      return()
    }
    
    # Validar cooldown
    tiempo_actual <- Sys.time()
    if (difftime(tiempo_actual, ultima_solicitud(), units = "secs") < 120) {
      shinyalert("Paciencia, por favor", "Ya enviaste una solicitud hace poco. Espera un par de minutos antes de intentar de nuevo.", type = "warning")
      return()
    }
    
    removeModal()
    
    # Actualizar tiempo de Ãºltima solicitud
    ultima_solicitud(tiempo_actual)
    
    # Cuerpo del correo
    cuerpo <- glue::glue("
      El usuario **'{input$usuario_reset}'** ha solicitado restablecer su contraseña.\n\n
      Comunícate con el usuario al siguiente correo:\n
      {input$correo_user}
      ")
    # Crear el mensaje
    email <- compose_email(
      body = md(cuerpo)
    )
    
    # Enviar el correo usando las credenciales guardadas en archivo
    tryCatch({
      smtp_send(
        email,
        from = "recupecontrase@gmail.com",        # correo de envÃ­o
        to = "kecarrilloc@sanmateo.edu.co",       # correo del admin
        subject = "Solicitud de restablecimiento de contraseña",
        credentials = creds_file("gmail_creds")   # Archivo de credenciales
      )
      showNotification("Solicitud enviada. El administrador se pondrá en contacto contigo.", type = "message")
    }, error = function(e) {
      showNotification("Error al enviar la solicitud, por favor, valide usuario y correo", type = "error")
      print(e$message)
    })
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
  
  
  
}


shinyApp(ui, server)