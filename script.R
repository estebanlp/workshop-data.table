#------------------------------------------#
#     Mini Workshop on data.table
#       Esteban López Ochoa, Ph.D.
#------------------------------------------#

# # # # # # # # # # # # #
#-- 1.  Introduction ----
# # # # # # # # # # # # #

# data.table is a powerful package with lots of features that enable the programmer to  make better use of their computer when using both small and large data sets. See full list of features on: https://rdatatable.gitlab.io/data.table/  

#install.packages('data.table') # to install the package

library(data.table) # to load the package into this session


# # # # # # # # # # # # 
#-- 2. Basic Syntax ----
# # # # # # # # # # # # 

# object[ ,  , by= ]
# data.table objects are both data.frame objects and data.table class objects

# object[  , .(v1_name, v2_name),by=.(id)] 
# `.()` is a direct way to call/list variables (similar to a list)

# - - - - - - - - - - - - - -
# Create a data.table object

# In this mini-workshop we will use the vaccination progress in Chile

#First dosses data
vacuna_1<-fread("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto81/vacunacion_comuna_edad_1eraDosis.csv",keepLeadingZeros = T)

#Second dosses data
vacuna_2<-fread("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto81/vacunacion_comuna_edad_2daDosis.csv",keepLeadingZeros = T)

# Basic data contents

names(vacuna_1)
str(vacuna_1)
View(vacuna_1)
View(head(vacuna_1))



# - - - - - - - - - - - - - -
# Subset rows

vacuna_1[Comuna=='Arica']

vacuna_1[,.N,by=Comuna]

vacuna_1<-vacuna_1[!Comuna%like%"Desconocido",]


# - - - - - - - - - - - - - -
# Manipulate cols
# - - - - - - - - - - - - - -
#   Extract

vacuna_1[,.(Comuna,`15`,`80`)]

vacuna_1[,c(3:5,67:71),with=F]

vacuna_1[,c(3:5,67:71),with=F]


# - - - - - - - - - - - - - -
#   Summarize

vacuna_1[,sum(`76`,`77`,`78`,`79`,`80`),by=Comuna]


# - - - - - - - - - - - - - -
#   Compute columns

vacuna_1[,.(promedio=mean(`76`,`77`,`78`,`79`,`80`,na.rm=T)),by=Comuna]

vacuna_1[,.(promedio=mean(`76`,`77`,`78`,`79`,`80`,na.rm=T),suma=sum(`76`,`77`,`78`,`79`,`80`,na.rm=T)),by=Comuna]

vacuna_1[,promedio:=mean(`76`,`77`,`78`,`79`,`80`,na.rm=T),by=Comuna]

vacuna_1[,`:=`(promedio_76a80=mean(`76`,`77`,`78`,`79`,`80`,na.rm=T),suma_76a80=sum(`76`,`77`,`78`,`79`,`80`,na.rm=T)),by=Comuna]



# - - - - - - - - - - - - - -
#   Convert column type

vacuna_1[,cod_reg2:=as.numeric(`Codigo region`)]


# - - - - - - - - - - - - - -
#   Delete

vacuna_1[,`Codigo region`:=NULL]

# - - - - - - - - - - - - - -
#   Reorder

setorder(vacuna_1,-Poblacion,Comuna)
head(vacuna_1)

# - - - - - - - - - - - - - -
#   Rename

setnames(vacuna_1,c("Codigo comuna"),c("codigo_comuna"))
names(vacuna_1)

# - - - - - - - - - - - - - -
# Chaining 

vacuna_1[,sum(`76`,`77`,`78`,`79`,`80`),by=Comuna][,sum(V1,na.rm = T)]

# For a good comparison between dplyr and data.table see: https://atrebas.github.io/post/2019-03-03-datatable-dplyr/ 

# # # # # # # # # # # # # #
#-- 3. Data wrangling ----
# # # # # # # # # # # # # #

# set keys

setkey(vacuna_1,codigo_comuna)

# Unique
uniqueN(vacuna_1$codigo_comuna)

vacuna_1[!duplicated(Region),]

# reshape (wide to long)

vacuna_1_long<-melt(data = vacuna_1,id.vars = c("Region","Comuna","codigo_comuna","Poblacion"),measure.vars = as.character(15:80),variable.name = "edad")

#example 1: First Doses vaccination percentage by municipality (comuna)

tab_A<-vacuna_1_long[,.(vacuna_1era_dosis=sum(value)),by=.(codigo_comuna,Comuna,Poblacion)][,.(Porcentaje_1era_Dosis=(vacuna_1era_dosis/Poblacion)),by=.(codigo_comuna,Comuna)]

# example 2: Second Doses vaccination percentage by municipalit

setnames(vacuna_2,"Codigo comuna","codigo_comuna")
setkey(vacuna_2,codigo_comuna)
head(vacuna_2)

vacuna_2<-vacuna_2[!Comuna%like%"Desconocido",]

vacuna_2_long<-melt(data = vacuna_2,id.vars = c("Region","Comuna","codigo_comuna","Poblacion"),measure.vars = as.character(15:80),variable.name = "edad")

tab_B<-vacuna_2_long[,.(vacuna_2da_dosis=sum(value)),by=.(codigo_comuna,Poblacion)][,.(Porcentaje_2da_Dosis=(vacuna_2da_dosis/Poblacion)),by=.(codigo_comuna)]


# Bind

cbind(tab_A,tab_B)


# Merge/join

tabla1<-tab_A[tab_B,on=.(codigo_comuna)] #join (one-direction)

#or

merge(tab_A,tab_B,by='codigo_comuna') #merge (allows for all directions, check argument `all`)

# Use of .SD and .SDCols and apply functions

vacuna_1_long[,.SD[1],by=.(Region)] # first observation within group(regional capitals in this specific case)

vacuna_1_long[,.SD[.N],by=.(Region)] # last observation within group

vacuna_1_long[,.SD[c(1,2,3,.N-1,.N)],by=.(Region)] # first 3 and last 2 observations within group

#Use of SD and SDcols
columnas<-as.character(15:80)

tab_A2<-vacuna_1[,rowSums(.SD),.SDcols=columnas,by=.(codigo_comuna)]

vacuna_1_long[,.(vacuna_1era_dosis=sum(value)),by=.(codigo_comuna)][
  tab_A2,on=.(codigo_comuna)
  ]

# A plot to see it all

install.packages('leaflet')
install.packages('chilemapas')
library(leaflet)
library(chilemapas)
help(package="chilemapas")

mapa1<-merge(mapa_comunas,tabla1,by='codigo_comuna',all.x = T,sort = F)

mapa1<-st_sf(mapa1)

bins<-seq(0,1,0.2)
col_pal_1<-colorBin(palette = 'Reds',domain = tabla1$Porcentaje_1era_Dosis,bins = bins)

labels <- sprintf(
  "<strong>%s</strong><br/>%g Porc. 1era Dosis",
  mapa1$Comuna, mapa1$Porcentaje_1era_Dosis
) %>% lapply(htmltools::HTML)

leaflet(mapa1)%>%
  addProviderTiles(provider = providers$CartoDB.DarkMatter)%>%
  addPolygons(color = ~col_pal_1(Porcentaje_1era_Dosis),weight = 1, fillOpacity = 0.8,label = labels)

#-- 4. Advanced ----

# Big Data Reading and writing
download.file(url = "https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto81/vacunacion_comuna_edad_1eraDosis.csv",destfile = "vacunacion_comuna_edad_1eraDosis.csv")

vacuna_1_filtered<-fread("grep -v Desconocido vacunacion_comuna_edad_1eraDosis.csv",keepLeadingZeros = T)

vacuna_1_filtered[Comuna%like%"Desconocido",]

vacuna_1_filtered_Arica<-fread("grep -w Arica vacunacion_comuna_edad_1eraDosis.csv",keepLeadingZeros = T)

# more on https://github.com/Rdatatable/data.table/wiki/Convenience-features-of-fread 

#grep cmd https://linuxcommand.org/lc3_man_pages/grep1.html 
