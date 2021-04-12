#------------------------------------------#
#     Mini Workshop on data.table
#       Esteban López Ochoa, Ph.D.
#------------------------------------------#

# # # # # # # # # # # # 
#-- 1.  Introduction ----
# # # # # # # # # # # # 

# data.table is a powerful package with lots of features that enable the programmer to  make better use of their computer when using both small and large data sets. See full list of features on: https://rdatatable.gitlab.io/data.table/  

install.packages('data.table') # to install the package

library(data.table) # to load the package into this session

# Basic data contents

names(vacuna_1)
str(vacuna_1)
View(vacuna_1)
View(head(vacuna_1))

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
vacuna_1<-fread("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto81/vacunacion_comuna_edad_1eraDosis.csv")

#Second dosses data
vacuna_2<-fread("https://raw.githubusercontent.com/MinCiencia/Datos-COVID19/master/output/producto81/vacunacion_comuna_edad_2daDosis.csv")

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
#   Delete

vacuna_1[,`Codigo region`:=NULL]

# - - - - - - - - - - - - - -
#   Convert column type

vacuna_1[,cod_reg2:=as.numeric(`Codigo region`)]


# - - - - - - - - - - - - - -
#   Reorder

setorder(vacuna_1,-Poblacion,Comuna)
head(vacuna_1)

# - - - - - - - - - - - - - -
#   Rename

setnames(vacuna_1,"Codigo comuna","codigo_comuna")
names(vacuna_1)

# - - - - - - - - - - - - - -
# Chaining 

vacuna_1[,sum(`76`,`77`,`78`,`79`,`80`),by=Comuna][,sum(V1,na.rm = T)]

# For a good comparison between dplyr and data.table see: https://atrebas.github.io/post/2019-03-03-datatable-dplyr/ 

#-- 3. Data wrangling ----

# set keys
# Unique
# Merge/join
# Bind
# reshape
# Use of .SD and .SDCols and apply functions
# Sequential rows




#-- 4. Advanced ----

# Big Data Reading and writting




