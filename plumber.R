library(plumber)

require(RPostgreSQL)

require(jsonlite)

library(DBI)

#CONFIGURACION
url_bdd <- "localhost"

port_bdd <- 5432

#PASSWORD DEL USUARIO DE LA BASE DE DATOS
pw <- {
  "password"
}

drv <- RPostgreSQL::PostgreSQL()

con <- dbConnect(drv, dbname = "tutorial_r",
                 host = url_bdd, port = port_bdd,
                 user = "postgres", password = pw)
rm(pw)


# FIN CONFIGURACION 

#RUTAS

#* Creacion de un objeto
#* @post /objeto
function(req,res){
  print(req$postBody)

  data <- as.data.frame(jsonlite::fromJSON(req$postBody))
  print(data)
  tryCatch(
    {
      #ESCRIBIMOS EN BASE DE DATOS
      dbWriteTable(con, "objetos", data, row.names=FALSE, append=TRUE)
      
      res$status <- 200 # Good request
      list(message=jsonlite::unbox("Se ha creado correctamente"))
      
    },
    #SI HAY UN ERROR, DEVOLVEMOS ESTADO 400
    error = function(e){
     
      res$status <- 400 # Bad request
      list(message=jsonlite::unbox("No se ha creado correctamente"))
    }
    
  )
  
}

#* Obtener objetos
#* @get /objetos
function(){
  
  #OBTENEMOS TODOS LOS OBJETOS Y DEVOLVEMOS
  objetos <- dbGetQuery(con, "SELECT * from objetos")
  objetos
  
}


#* Obtener objeto por id
#* @get /objetos/<id>
function(id,res){
  
  #OBTENEMOS EL OBJETO POR ID
  df_objetos <- dbGetQuery(con, paste("SELECT * from objetos WHERE id=",id,sep = ""))
  
  #SI NO EXISTE , SE ENVÍA ERROR
  if(nrow(df_objetos) == 0)
  {
    res$status <- 400 # Bad request
    list(message=jsonlite::unbox("No se ha encontrado este objeto"))
  }
  else{

    jsonlite::unbox(df_objetos[1,])#SI EXISTE, ENVIAMOS EL PRIMER OBJETO(200 AUTOMÁTICAMENTE)
  }
  
}

#* Actualizar un objeto
#* @put /actualizarobjeto/<id>
function(id,res,req){
  
  #OBTENEMOS LOS DATOS
  data <- as.data.frame(jsonlite::fromJSON(req$postBody))
  
  #OBTENEMOS LOS DATOS QUE PODEMOS MODIFICAR DE UN OBJETO
  nombre <- data[1,"nombre"]
  descripcion <- data[1,"descripcion"]
  
  consulta <- paste("UPDATE objetos SET nombre='",nombre,"', descripcion = '",descripcion,"' WHERE id=",id,sep = "")
  
  #ACTUALIZAMOS EL OBJETO
  dbSendQuery(con,consulta)
  
  #OBTENEMOS EL OBJETO POR ID
  df_objetos <- dbGetQuery(con, paste("SELECT * from objetos WHERE id=",id,sep = ""))
  
  #SI NO EXISTE , SE ENVÍA ERROR
  if(nrow(df_objetos) == 0)
  {
    res$status <- 400 # Bad request
    list(message=jsonlite::unbox("No se ha encontrado este objeto"))
  }
  else{
    
    jsonlite::unbox(df_objetos[1,])#SI EXISTE, ENVIAMOS EL PRIMER OBJETO(200 AUTOMÁTICAMENTE)
  }
  
  
}


#* Eliminar objeto por id
#* @delete /eliminarobjeto/<id>
function(id,res){
  
  #OBTENEMOS EL OBJETO POR ID
  df_objetos <- dbGetQuery(con, paste("SELECT * from objetos WHERE id=",id,sep = ""))
  
  #SI NO EXISTE , SE ENVÍA ERROR
  if(nrow(df_objetos) == 0)
  {
    res$status <- 400 # Bad request
    list(message=jsonlite::unbox("No se ha encontrado este objeto"))
  }
  
  #SI SE HA ENCONTRADO, PODEMOS ELIMINARLO
  else{
    
    consulta <- paste("DELETE FROM objetos WHERE id = ",id,sep = "")
    print(consulta)
    
    #ELIMINAMOS EL OBJETO Y ENVIAMOS EL MENSAJE CORRECTO
    dbGetQuery(con, consulta)
    res$status <- 200 # Good request
    list(message=jsonlite::unbox("Se ha eliminado correctamente"))
    
  }
  
}



